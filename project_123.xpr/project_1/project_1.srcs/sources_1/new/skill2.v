`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/28 16:36:33
// Design Name: 
// Module Name: skill2
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


module skill2(
    input clk,
    input [6:0] x,
    input [6:0] y,
    input [15:0] oled_data_play,
    output reg [15:0] pixel_data = 16'h0000
    );
    
    always @ (posedge clk) begin
        pixel_data <= oled_data_play; // Add if-else logic. Put this line as the lowest priority
    end
endmodule
