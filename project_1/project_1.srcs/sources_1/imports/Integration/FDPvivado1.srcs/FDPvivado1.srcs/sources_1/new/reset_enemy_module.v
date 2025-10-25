module reset_enemy_module #(
    parameter integer CLK_HZ  = 6_250_000, // input clock frequency
    parameter integer TICK_HZ = 1          // events per second
)(
    input  wire clk,
    input  wire reset_enemy_module,   // treated as start/seed event (not zeroing)

    // one-clock pulses, asserted exactly ONE clk AFTER the channel number updates
    output wire reset_enemy_1,
    output wire reset_enemy_2,
    output wire reset_enemy_3,
    output wire reset_enemy_4,
    output wire reset_enemy_5,
    output wire kill_all,

    // held random numbers (0..55) - now 7-bit wide
    output reg  [6:0] random_num_1,
    output reg  [6:0] random_num_2,
    output reg  [6:0] random_num_3,
    output reg  [6:0] random_num_4,
    output reg  [6:0] random_num_5
);





    // ---------------- helpers ----------------
    localparam [5:0] STEP0 = 6'd0,  STEP1 = 6'd11, STEP2 = 6'd22,
                     STEP3 = 6'd33, STEP4 = 6'd44;

    function [5:0] add_mod56;
        input [6:0] a7;  // 0..111
        begin
            add_mod56 = (a7 >= 7'd56) ? (a7 - 7'd56) : a7[5:0];
        end
    endfunction

    function is_forbidden_base;
        input [5:0] b;
        begin
            is_forbidden_base = (b==6'd0) || (b==6'd12) || (b==6'd23)
                              || (b==6'd34) || (b==6'd45);
        end
    endfunction

    // ---------------- 1) tick and rotating index ----------------
    localparam integer TICKS_PER_PULSE = CLK_HZ / TICK_HZ;
    localparam integer CNT_W = $clog2(TICKS_PER_PULSE);

    reg  [CNT_W-1:0] cnt = {CNT_W{1'b0}};
    wire tick = (cnt == TICKS_PER_PULSE-1);

    reg  [2:0] idx = 3'd0;  // which channel updates this tick (0..4)

    always @(posedge clk) begin
        cnt <= tick ? {CNT_W{1'b0}} : (cnt + {{(CNT_W-1){1'b0}},1'b1});
        if (tick)
            idx <= (idx == 3'd4) ? 3'd0 : (idx + 3'd1);
    end

    // ---------------- 2) RNG: 7-bit LFSR + rejection to 0..55 ----------------
    reg  [6:0] lfsr = 7'h5A;                     // non-zero seed
    wire       fb        = lfsr[6] ^ lfsr[5];    // x^7 + x^6 + 1
    wire [6:0] lfsr_next = {lfsr[5:0], fb};

    wire [6:0] cand7      = lfsr_next - 7'd1;    // 0..126
    wire       accept     = (cand7 < 7'd112);    // accept 0..111
    wire [6:0] cand_mod56 = (cand7 < 7'd56) ? cand7 : (cand7 - 7'd56);
    wire [5:0] cand56     = cand_mod56[5:0];

    reg  [5:0] last_rand = 6'd1; // latest accepted 0..55 (init non-zero)

    always @(posedge clk) begin
        lfsr <= lfsr_next;               // keep running continuously
        if (accept) last_rand <= cand56; // update whenever we get a valid sample
    end

    // ---------------- 3) start behavior + channel updates ----------------
    // rising edge of start signal
    reg  start_q = 1'b0;
    wire start_evt = (~start_q) & reset_enemy_module;
    always @(posedge clk) start_q <= reset_enemy_module;
// kill-all is a clean 1-clk pulse
    assign kill_all = start_evt;
    // compute base/shift for the start event OUTSIDE the always block
    wire [5:0] base_start        = (last_rand == 6'd0) ? 6'd1 : last_rand;
    wire       shift_plus1_start = is_forbidden_base(base_start);

    // schedule a pulse one clock AFTER a channel is updated
    reg        pulse_valid_d = 1'b0, pulse_valid_q = 1'b0;
    reg  [2:0] pulse_idx_d   = 3'd0, pulse_idx_q   = 3'd0;

    // registered pulses (exactly one clk after update)
    assign reset_enemy_1 = pulse_valid_q && (pulse_idx_q == 3'd0);
    assign reset_enemy_2 = pulse_valid_q && (pulse_idx_q == 3'd1);
    assign reset_enemy_3 = pulse_valid_q && (pulse_idx_q == 3'd2);
    assign reset_enemy_4 = pulse_valid_q && (pulse_idx_q == 3'd3);
    assign reset_enemy_5 = pulse_valid_q && (pulse_idx_q == 3'd4);

    // main write logic
    always @(posedge clk) begin
        // default: no pulse unless scheduled last cycle
        pulse_valid_d <= 1'b0;
        pulse_idx_d   <= pulse_idx_q;

        // 3a) On start event: write ALL channels immediately (distinct & non-zero)
        if (start_evt) begin
            random_num_1 <= {1'b0, add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP0})}
                                             + {6'd0, shift_plus1_start})};
            random_num_2 <= {1'b0, add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP1})}
                                             + {6'd0, shift_plus1_start})};
            random_num_3 <= {1'b0, add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP2})}
                                             + {6'd0, shift_plus1_start})};
            random_num_4 <= {1'b0, add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP3})}
                                             + {6'd0, shift_plus1_start})};
            random_num_5 <= {1'b0, add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP4})}
                                             + {6'd0, shift_plus1_start})};
            // pulses are for periodic updates only

        end else if (tick) begin
            // 3b) Periodic per-channel update; schedule pulse for NEXT clk
            case (idx)
              3'd0: random_num_1 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd1: random_num_2 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd2: random_num_3 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd3: random_num_4 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              default: random_num_5 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
            endcase

            pulse_idx_d   <= idx;
            pulse_valid_d <= 1'b1;  // pulse will assert on the next clk
        end

        // register the pulse control (one-clk delay)
        pulse_valid_q <= pulse_valid_d;
        pulse_idx_q   <= pulse_idx_d;
    end

endmodule
