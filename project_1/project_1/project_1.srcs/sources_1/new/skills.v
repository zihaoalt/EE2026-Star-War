`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/21 11:55:03
// Design Name: 
// Module Name: skills
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


module skills(
    input clk,
    input [1:0] state,
    input SW0, SW1, SW2, SW3,
    output reg skill0 = 0, reg skill1 = 0, reg skill2 = 0, reg skill3 = 0
    );
    
    always @ (posedge clk) begin
        if (state == 2'b01) begin
            skill0 <= SW0;
            skill1 <= SW1;
            skill2 <= SW2;
            skill3 <= SW3;
        end else begin
            skill0 <= 0;
            skill1 <= 0;
            skill2 <= 0;
            skill3 <= 0;
        end
    end
endmodule
