`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 15:44:38
// Design Name: 
// Module Name: on_press
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


module on_press(
    input btn_raw,          
    input clk_625m,
    output reg btn_pulse
);

    reg [22:0] counter = 0;
    reg stable = 0;

    (* ASYNC_REG="TRUE" *) reg btn_sync0 = 1'b0;
    (* ASYNC_REG="TRUE" *) reg btn_sync1 = 1'b0;
    always @(posedge clk_625m) begin
        btn_sync0 <= btn_raw;
        btn_sync1 <= btn_sync0;
    end

    always @(posedge clk_625m) begin
        if (btn_sync1 && !stable && counter == 0) begin
            btn_pulse <= 1;         
            stable <= 1;
            counter <= 1250000;  
        end else begin
            btn_pulse <= 0;
            if (counter > 0) counter <= counter - 1;
            else if (!btn_sync1) stable <= 0; 
        end
    end
endmodule