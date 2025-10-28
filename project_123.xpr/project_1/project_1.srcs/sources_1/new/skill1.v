`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/28 16:30:46
// Design Name: 
// Module Name: skill1
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


module skill1(
    input clk,
    input [6:0] x,
    input [6:0] y,
    input [15:0] oled_data_play,
    output reg [15:0] pixel_data = 16'h0000
    );
    
    always @ (posedge clk) begin
        pixel_data <= oled_data_play;
    end
endmodule
