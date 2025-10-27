`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 14:37:52
// Design Name: 
// Module Name: xy_coordinate
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


module xy_coordinate(
    input [12:0] pixel_index,
    output [6:0] x,
    output [6:0] y
    );
    assign x = pixel_index % 96; // width of 96 pixels
    assign y = pixel_index / 96; // height of 64 pixels
endmodule
