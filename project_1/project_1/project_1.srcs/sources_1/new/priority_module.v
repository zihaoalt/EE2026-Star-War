`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 12:27:41
// Design Name: 
// Module Name: priority_module
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


module priority_module(
    input red_flag,
    input white_flag,
    input clk_625m,
    input starship_flag,
    input bullet_flag,
    input enemy_flag,
    output BE_collision,
    output reg [15:0] pixel_data
    );
    
    parameter background = 16'h0000;
    parameter starship = 16'h634D;
    parameter bullet = 16'hB841;
    parameter enemy = 16'h3B09;
    parameter red = 16'hF904;
    parameter white = 16'hFFFF;
    
    always @(posedge clk_625m) begin
        if (red_flag) begin
            pixel_data <= red;
        end else if (white_flag) begin
            pixel_data <= white;
        end else if (starship_flag) begin
            pixel_data <= starship;
        end else if (enemy_flag) begin
            pixel_data <= enemy;
        end else if (bullet_flag) begin
            pixel_data <= bullet;
        end else begin
            pixel_data <= background;
        end
    end
    assign BE_collision = enemy_flag && bullet_flag;
endmodule
