`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 19:09:16
// Design Name: 
// Module Name: play
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


module play(
    input [1:0] level_state,
    input bullet_skill,
    input shield_skill,
    input up,
    input down,
    input [12:0] pixel_index,
    input reset,
    input clk,
    input [1:0] state,
    input frame_begin,
    input sample_pixel,
    input clk_625m,
    output wire [15:0] pixel_data,
    output [3:0] anode,
    output [6:0] seg,
    output [15:0] led,
    output dead_flag
    );
    
    wire BE_collision;
    wire enemy_flag;
    wire HP_deduct;
    wire [6:0] x;
    wire [6:0] y;
    wire starship_bullet_flag;
    wire starship_flag;
    wire bullet_flag;
    wire bullet_CD_flag;
    wire white_flag;
    wire red_flag;
    wire [24:0] CD;
    wire shield_active; 
    wire shield_flag; 
    wire boss_appear;
    wire boss_flag;
    wire boss_bullet_flag;
    wire boss_fire;
    
    enemy_package  enemy_package_inst (
    .clk625(clk_625m),
    .reset_enemy_module(reset),
    .shot_flag(BE_collision),
    .x(x),
    .y(y),
    .level_state(level_state),
    .pause(state[1]),
    .boss_appear(boss_appear),
    .enemy_flag(enemy_flag),
    .boss_flag(boss_flag),
    .HP_deduct(HP_deduct),
    .boss_fire(boss_fire)
  );
    starship star (clk_625m, x, y, reset, up, down, state, shield_active, starship_flag, starship_bullet_flag, shield_flag); 
    priority_module pri (boss_flag, bullet_CD_flag, red_flag, white_flag, clk_625m, starship_flag, shield_flag, bullet_flag, enemy_flag, BE_collision, pixel_data);
    bullet_module bu (clk_625m, x, y, starship_bullet_flag, frame_begin, bullet_skill, BE_collision, level_state, state, CD, bullet_flag);
    bullet_CD_display bu_cd (x, y, CD, bullet_CD_flag);
    boss_bullet boss_bu (clk_625m, x, y, boss_fire, frame_begin, BE_collision, level_state, state, boss_bullet_flag);
    xy_coordinate xy (pixel_index, x, y);
    score_display sc (BE_collision, clk_625m, state, anode, seg, boss_appear);
    hp_bar hp(clk_625m,HP_deduct,state,level_state,reset,shield_skill,led,dead_flag,shield_active);
    pulse pu (state, x, y, clk_625m, red_flag, white_flag); //Pause
    
endmodule
