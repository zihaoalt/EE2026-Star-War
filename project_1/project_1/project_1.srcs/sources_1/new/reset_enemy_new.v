`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/27 11:05:34
// Design Name: 
// Module Name: reset_enemy_new
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reset_enemy_new #(
    parameter integer CLK_HZ  = 6_250_000  // input clock frequency
)(
    input  wire        clk,
    input  wire        reset_enemy_module,   // treated as start/seed event (not zeroing)
    input  wire [1:0]  level_state,          // 00/01/10/11 ->     ?  
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

    // =========================
    // ?  ?  
    // =========================
    // ?  ?  :
    // reset_state = 00 -> 0.8  Hz
    // reset_state = 01 -> 1.2  Hz
    // reset_state = 10 -> 1.5  Hz
    // reset_state = 11 -> 1.8  Hz
    //
    // divider = CLK_HZ / freq
    // 0.8 Hz  -> 6_250_000 / 0.8     7_812_500
    // 1.2 Hz  -> 6_250_000 / 1.2     5_208_333
    // 1.5 Hz  -> 6_250_000 / 1.5     4_166_667
    // 1.8 Hz  -> 6_250_000 / 1.8     3_472_222
    //
    //   ?    ? ?   ? ?       ??  ?               

    localparam integer DIV_0P8HZ = 7_000_000;  // reset_state = 2'b00
    localparam integer DIV_1P2HZ = 5_000_000;  // reset_state = 2'b01
    localparam integer DIV_1P5HZ = 4_000_000;  // reset_state = 2'b10
    localparam integer DIV_1P8HZ = 3_000_000;  // reset_state = 2'b11

    // ?   ?          ?  
    localparam integer MAX_DIV     = DIV_0P8HZ;
    localparam integer CNT_W       = $clog2(MAX_DIV);
    reg    [CNT_W-1:0] cnt = {CNT_W{1'b0}};

    //     reset_state ?  ?divider
    reg [CNT_W-1:0] cur_divider;
    always @(*) begin
        case (level_state)
            2'b00: cur_divider = DIV_0P8HZ[CNT_W-1:0];
            2'b01: cur_divider = DIV_1P2HZ[CNT_W-1:0];
            2'b10: cur_divider = DIV_1P5HZ[CNT_W-1:0];
            default: cur_divider = DIV_1P8HZ[CNT_W-1:0];
        endcase
    end

    //      ?(  ?divider-1)?    tick
    wire tick = (cnt == (cur_divider - 1));

    //  ? channel     tick     (0..4?  )
    reg  [2:0] idx = 3'd0;

    always @(posedge clk) begin
        if (!pause) begin
        //       
        if (tick)
            cnt <= {CNT_W{1'b0}};
        else
            cnt <= cnt + {{(CNT_W-1){1'b0}},1'b1};

        // ÿ  tick    ?  channel
        if (tick)
            idx <= (idx == 3'd4) ? 3'd0 : (idx + 3'd1);
        end
       
    end


    // =========================
    // helper functions
    // =========================
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


    // =========================
    // 2)   LFSR            (      ?   ? )
    // =========================
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


    // =========================
    // 3) start  ? + ?       +        
    // =========================

    //    reset_enemy_module       ?   ??  "?       ¼ "
    reg  start_q = 1'b0;
    wire start_evt = (~start_q) & reset_enemy_module;
    always @(posedge clk) start_q <= reset_enemy_module;

    // kill_all:   start_evt?  ?  1  clk      
    assign kill_all = start_evt;

    // ?start_evt?   ? ?
    wire [5:0] base_start        = (last_rand == 6'd0) ? 6'd1 : last_rand;
    wire       shift_plus1_start = is_forbidden_base(base_start);

    //       ?      ?     reset_enemy_X     
    reg        pulse_valid_d = 1'b0, pulse_valid_q = 1'b0;
    reg  [2:0] pulse_idx_d   = 3'd0, pulse_idx_q   = 3'd0;

    assign reset_enemy_1 = pulse_valid_q && (pulse_idx_q == 3'd0);
    assign reset_enemy_2 = pulse_valid_q && (pulse_idx_q == 3'd1);
    assign reset_enemy_3 = pulse_valid_q && (pulse_idx_q == 3'd2);
    assign reset_enemy_4 = pulse_valid_q && (pulse_idx_q == 3'd3);
    assign reset_enemy_5 = pulse_valid_q && (pulse_idx_q == 3'd4);

    always @(posedge clk) begin
        // ? ?     pulse                 ?
        pulse_valid_d <= 1'b0;
        pulse_idx_d   <= pulse_idx_q;

        //    1  start_evt?     ? 5  random_num?    ?  
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
            // start_evt  ²          reset_enemy_X     

        end else if (tick) begin
            //    2    tick   ?             ?  channel
            case (idx)
              3'd0: random_num_1 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd1: random_num_2 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd2: random_num_3 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              3'd3: random_num_4 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
              default: random_num_5 <= {1'b0, (last_rand==6'd0) ? 6'd1 : last_rand};
            endcase

            //     ? ?? ?channel  ?  1clk    
            pulse_idx_d   <= idx;
            pulse_valid_d <= 1'b1;
        end

        //       ?   õ pulse_*    ? ??    
        pulse_valid_q <= pulse_valid_d;
        pulse_idx_q   <= pulse_idx_d;
    end

endmodule

