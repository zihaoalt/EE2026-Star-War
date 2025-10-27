`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/21 12:15:52
// Design Name: 
// Module Name: difficulty_choose
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


module difficulty_choose(
    input clk,
    input [1:0] state,
    input SW15,
    input SW14,
    input SW13,
    input SW12,
    output reg [1:0] level_state = 2'b00
    );
    
    parameter easy = 2'b00;
    parameter normal = 2'b01;
    parameter hard = 2'b10;
    parameter expert = 2'b11;
    
    always @(posedge clk) begin
        if (state == 2'b00) begin
            if (SW14 == 1 && SW15 != 1) begin
                level_state <= normal;
            end else if (SW13 == 1 && SW14 == 0 && SW15 == 0) begin
                level_state <= hard;
            end else if (SW12 == 1 && SW13 == 0 && SW14 == 0 && SW15 == 0) begin
                level_state <= expert;
            end else begin 
                level_state <= easy;
            end
        end
    end
endmodule
