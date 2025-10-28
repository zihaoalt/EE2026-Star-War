module reset_enemy_new2 #(
    parameter integer CLK_HZ  = 6_250_000  // input clock frequency (6.25 MHz)
)(
    input  wire        clk,
    input  wire        reset_enemy_module,   // treated as start/seed event (not zeroing)
    input  wire [1:0]  level_state,          // 00/01/10/11
    input  wire        pause,

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

    // =========================================================
    // 1) Frequency control
    //
    // Requirement now:
    //   level_state = 00 -> disabled (no spawn)
    //   level_state = 01 -> disabled (no spawn)
    //   level_state = 10 -> 0.2 Hz (one event every 5s)
    //   level_state = 11 -> 0.5 Hz (one event every 2s)
    //
    // divider = CLK_HZ / freq
    // 0.2 Hz -> 6_250_000 / 0.2 = 31_250_000
    // 0.5 Hz -> 6_250_000 / 0.5 = 12_500_000
    // =========================================================

    localparam integer DIV_0P2HZ = 30_000_000;  // level_state = 2'b10
    localparam integer DIV_0P5HZ = 15_000_000;  // level_state = 2'b11

    // choose the *largest* divider for counter width
    localparam integer MAX_DIV = DIV_0P2HZ;
    localparam integer CNT_W   = $clog2(MAX_DIV);

    reg [CNT_W-1:0] cnt = {CNT_W{1'b0}};

    // select active divider + enable
    reg [CNT_W-1:0] cur_divider;
    reg             enable_gen; // whether we are allowed to generate enemies at all

    always @(*) begin
        case (level_state)
            2'b10: begin
                cur_divider = DIV_0P2HZ[CNT_W-1:0]; // 0.2 Hz
                enable_gen  = 1'b1;
            end
            2'b11: begin
                cur_divider = DIV_0P5HZ[CNT_W-1:0]; // 0.5 Hz
                enable_gen  = 1'b1;
            end
            default: begin
                // 00 / 01 -> disabled
                cur_divider = {CNT_W{1'b0}};
                enable_gen  = 1'b0;
            end
        endcase
    end

    // tick fires when counter reaches (cur_divider-1), BUT ONLY if enabled
    wire tick_raw = (cnt == (cur_divider - 1'b1));
    wire tick     = enable_gen && tick_raw;

    // which channel (0..4) gets updated next
    reg  [2:0] idx = 3'd0;

    always @(posedge clk) begin
        if (!pause) begin
            if (enable_gen) begin
                // normal counting
                if (tick_raw)
                    cnt <= {CNT_W{1'b0}};
                else
                    cnt <= cnt + {{(CNT_W-1){1'b0}},1'b1};

                // step through 0..4 on each tick
                if (tick_raw)
                    idx <= (idx == 3'd4) ? 3'd0 : (idx + 3'd1);
            end else begin
                // disabled: hold counter and idx stable
                cnt <= cnt;
                idx <= idx;
            end
        end
        // if pause==1, we freeze cnt/idx (no spawn timing progress)
    end

    // =========================================================
    // 2) LFSR-based random number generator (unchanged logic)
    //    We continuously run the LFSR so last_rand is always fresh.
    // =========================================================
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
        if (accept)
            last_rand <= cand56;         // update whenever we get a valid sample
    end

    // =========================================================
    // 3) Helper functions / constants
    // =========================================================
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
            // (ban certain spawn zones)
            is_forbidden_base = (b==6'd0) || (b==6'd12) || (b==6'd23)
                              || (b==6'd34) || (b==6'd45);
        end
    endfunction

    // =========================================================
    // 4) start_evt handling (global kill_all + full refresh)
    // =========================================================
    reg  start_q = 1'b0;
    wire start_evt = (~start_q) & reset_enemy_module;
    always @(posedge clk) start_q <= reset_enemy_module;

    // kill_all is a 1-cycle pulse on global reset_enemy_module rising edge
    assign kill_all = start_evt;

    // base position for the 5 enemies on start_evt
    wire [5:0] base_start        = (last_rand == 6'd0) ? 6'd1 : last_rand;
    wire       shift_plus1_start = is_forbidden_base(base_start);

    // =========================================================
    // 5) Per-channel update + 1-cycle pulses reset_enemy_1..5
    // =========================================================
    reg        pulse_valid_d = 1'b0, pulse_valid_q = 1'b0;
    reg  [2:0] pulse_idx_d   = 3'd0, pulse_idx_q   = 3'd0;

    assign reset_enemy_1 = pulse_valid_q && (pulse_idx_q == 3'd0);
    assign reset_enemy_2 = pulse_valid_q && (pulse_idx_q == 3'd1);
    assign reset_enemy_3 = pulse_valid_q && (pulse_idx_q == 3'd2);
    assign reset_enemy_4 = pulse_valid_q && (pulse_idx_q == 3'd3);
    assign reset_enemy_5 = pulse_valid_q && (pulse_idx_q == 3'd4);

    always @(posedge clk) begin
        // default: no pulse unless we explicitly set it
        pulse_valid_d <= 1'b0;
        pulse_idx_d   <= pulse_idx_q;

        // Case A: global start_evt -> refresh ALL 5 randoms at once
        // Note: this ignores pause/enable_gen on purpose, so pressing the
        //       button always forces new enemies + kill_all.
        if (start_evt) begin
            random_num_1 <= {1'b0,
                add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP0})}
                          + {6'd0, shift_plus1_start})};
            random_num_2 <= {1'b0,
                add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP1})}
                          + {6'd0, shift_plus1_start})};
            random_num_3 <= {1'b0,
                add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP2})}
                          + {6'd0, shift_plus1_start})};
            random_num_4 <= {1'b0,
                add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP3})}
                          + {6'd0, shift_plus1_start})};
            random_num_5 <= {1'b0,
                add_mod56({1'b0, add_mod56({1'b0, base_start} + {1'b0, STEP4})}
                          + {6'd0, shift_plus1_start})};

            // no per-channel pulse here; kill_all handles global clear

        end else if (tick && !pause) begin
            // Case B: timed spawn/update
            // Only happens if enable_gen=1 and we are not paused
            // Update ONE channel's random_num and assert its reset_enemy_X
            case (idx)
              3'd0: random_num_1 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd1: random_num_2 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd2: random_num_3 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd3: random_num_4 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              default:
                   random_num_5 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
            endcase

            pulse_idx_d   <= idx;
            pulse_valid_d <= 1'b1;
        end

        // register pulse_* so outputs are 1-cycle pulses
        pulse_valid_q <= pulse_valid_d;
        pulse_idx_q   <= pulse_idx_d;
    end

endmodule
