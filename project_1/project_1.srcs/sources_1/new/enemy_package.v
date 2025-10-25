`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/17 16:52:57
// Design Name: 
// Module Name: enemy_package
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


module enemy_package (
    input clk625,//6.25MHz
    input reset_enemy_module,
    input shot_flag,
    input [6:0] x,y,
    input frame_begin,
    output enemy_flag,
    output HP_deduct

);


    // ========= ????? =========

    wire        clk_move_64_raw; // 64 Hz?? 100 MHz ????
    wire        clk_move_64_sync; // ??? 6.25 MHz ???"??"
    wire        move_pulse;      // ????????? 1clk ???6.25MHz ??





    // ========= 100MHz -> 64Hz ????50%?=========
    // ???? 64Hz ????? clk_div_64hz??????
    clk_div_n_hz u_clk64 (
        .frame_begin      (frame_begin),     // 100 MHz
        .clk_move (clk_move_64_raw)
    );

    // ========= CDC?? 64Hz ??? 6.25MHz ????????? =========
    reg sync_ff1, sync_ff2, sync_ff2_d;
    always @(posedge clk625) begin
        sync_ff1   <= clk_move_64_raw;
        sync_ff2   <= sync_ff1;
        sync_ff2_d <= sync_ff2;
    end
    assign clk_move_64_sync = sync_ff2;
    assign move_pulse       =  clk_move_64_sync & ~sync_ff2_d; // 6.25MHz ?? 1 ? clk ???


    // ========= ???? =========
enemy_master u_enemy_master(
    .clk           (clk625),        // 6.25 MHz ????
    .clk_move      (move_pulse),    // ?"??"??????????????????
    .shot_flag     (shot_flag),
    .x             (x),
    .y             (y),
    .reset_enemy_module(reset_enemy_module),
    .enemy_flag(enemy_flag),
    .HP_deduct(HP_deduct)
);


endmodule
