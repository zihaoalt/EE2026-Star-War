`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/21 13:50:00
// Design Name: 
// Module Name: clk_250
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


module clk_250(
    input clk_625,
    output reg clk_250
    );
    
    reg [15 : 0] counter = 0;
    always @ (posedge clk_625) begin
        counter <= counter == 12499 ? 0 : counter + 1;
        if (counter == 12499) begin
            clk_250 <= ~clk_250;
        end
    end
endmodule
