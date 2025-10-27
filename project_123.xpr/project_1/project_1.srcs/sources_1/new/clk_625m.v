`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 14:41:22
// Design Name: 
// Module Name: clk_625m
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


module clk_625m(
    input clk,
    output clk_625m
);

reg [2:0] counter = 0;
reg clk_625m = 0;

always @(posedge clk) begin
    if (counter == 7) begin
        clk_625m <= ~clk_625m;
        counter <= 0;
    end else begin
        counter <= counter + 1;
    end
end
endmodule
