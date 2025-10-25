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
    
    enemy_package u2 (clk_625m, reset, BE_collision, x, y, frame_begin, enemy_flag, HP_deduct);
    starship star (clk_625m, x, y, reset, up, down, 0, starship_flag, starship_bullet_flag); 
    bullet_module bu (clk_625m, x, y, starship_bullet_flag, frame_begin, bullet_skill, BE_collision, level_state, bullet_flag);
    priority_module pri (clk_625m, starship_flag, bullet_flag, enemy_flag, BE_collision, pixel_data);
    xy_coordinate xy (pixel_index, x, y);
    score_display sc (BE_collision, clk_625m, state, anode, seg);
    hp_bar hp(clk_625m,HP_deduct,state,level_state,reset,led,dead_flag);
    
endmodule
