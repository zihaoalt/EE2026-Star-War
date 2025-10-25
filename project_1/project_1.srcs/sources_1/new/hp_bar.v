`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 20:35:30
// Design Name: 
// Module Name: hp_bar
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


module hp_bar(
    input clk,
    input deduct_HP,
    input pause,
    input reset,
    output reg [15:0] starship_hp,
    output reg dead_flag
    );
    
    reg [5:0] HP = 6'd16;
    reg prev_deduct;
    wire hit_pulse = deduct_HP & ~prev_deduct; // one-hit per edge

    always @(posedge clk) begin
        prev_deduct <= deduct_HP;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            HP <= 6'd16;
            dead_flag <= 0;
        end else if (!pause) begin
            if (hit_pulse && HP > 0)
                HP <= HP - 1;
            dead_flag <= (HP <= 1); //when HP is 1 or 0, set flag to 1, otherwise 0
        end
    end
    
    always@(*)begin
        case(HP)
            6'd0: starship_hp = 16'b0;
            6'b1: starship_hp = 16'b0000000000000001;
            6'd2: starship_hp = 16'b0000000000000011;
            6'd3: starship_hp = 16'b0000000000000111;
            6'd4: starship_hp = 16'b0000000000001111;
            6'd5: starship_hp = 16'b0000000000011111;
            6'd6: starship_hp = 16'b0000000000111111;
            6'd7: starship_hp = 16'b0000000001111111;
            6'd8: starship_hp = 16'b0000000011111111;
            6'd9: starship_hp = 16'b0000000111111111;
            6'd10: starship_hp = 16'b0000001111111111;
            6'd11: starship_hp = 16'b0000011111111111;
            6'd12: starship_hp = 16'b0000111111111111;
            6'd13: starship_hp = 16'b0001111111111111;
            6'd14: starship_hp = 16'b0011111111111111;
            6'd15: starship_hp = 16'b0111111111111111;
            6'd16: starship_hp = 16'b1111111111111111;
            default: starship_hp = 16'b1111111111111111;
        endcase
    end
endmodule
