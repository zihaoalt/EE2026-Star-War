`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/27 11:03:35
// Design Name: 
// Module Name: move_pulse
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


module move_pulse(
    input clk625,
    input [1:0] level_state,
    input pause,
    output reg move_pulse
);



reg [31:0] period = 32'd150000;
reg [31:0] cnt = 0;

always @(*) begin
    case (level_state)
    2'b00: period <= 32'd170000;
    2'b01: period <= 32'd150000;
    2'b10: period <= 32'd120000;
    2'b11: period <= 32'd100000;
    endcase

end

always @(posedge clk625) begin
    if (!pause) begin
        if (cnt >= period-1 ) begin
            cnt      <= 32'd0;
            move_pulse <= 1; 
        end else begin
            cnt <= cnt + 1;
            move_pulse <= 0;
        end
    end else begin
        cnt <= cnt;
        move_pulse <= 0;
    end
    
    end

endmodule

