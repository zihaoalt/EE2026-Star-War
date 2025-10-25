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
    
    wire [2:0] info = {starship_flag, bullet_flag, enemy_flag};
    always @(posedge clk_625m) begin
        case (info)
            3'b000: pixel_data <= background;
            3'b001: pixel_data <= enemy;
            3'b010: pixel_data <= bullet;
            3'b011: pixel_data <= enemy;
            3'b100: pixel_data <= starship;
            3'b101: pixel_data <= starship;
            3'b110: pixel_data <= starship;
            3'b111: pixel_data <= starship;
            default : pixel_data <= background;
        endcase
    end
    assign BE_collision = enemy_flag && bullet_flag;
endmodule
