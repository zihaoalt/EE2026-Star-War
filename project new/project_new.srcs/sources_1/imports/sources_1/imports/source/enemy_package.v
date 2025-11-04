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
    input [1:0] level_state,
    input pause,
    input boss_appear,
    output enemy_flag,
    output boss_flag,
    output HP_deduct,
    output boss_fire

);

wire move_pulse;

move_pulse  u_move_pulse (
    .pause(pause),
    .clk625(clk625),
    .level_state(level_state),
    .move_pulse(move_pulse)

  );



    // ========= ???? =========
enemy_master u_enemy_master(
    .clk           (clk625),        // 6.25 MHz ????
    .clk_move      (move_pulse),    // ?"??"??????????????????
    .shot_flag     (shot_flag),
    .x             (x),
    .y             (y),
    .reset_enemy_module(reset_enemy_module),
    .boss_appear(boss_appear),
    .enemy_flag(enemy_flag),
    .boss_flag(boss_flag),
    .HP_deduct(HP_deduct),
    .level_state(level_state),
    .pause(pause),
    .boss_fire(boss_fire)
);


endmodule
