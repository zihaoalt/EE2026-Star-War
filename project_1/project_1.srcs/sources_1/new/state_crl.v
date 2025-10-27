`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 15:45:27
// Design Name: 
// Module Name: state_crl
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


module state_crl(
    input SW15, SW14, SW13, SW12,
    input bullet_skill,
    input up, 
    input down,
    input [12:0] pixel_index,
    input clk,
    input btn,
    input clk_625m,
    input frame_begin,
    input sample_pixel,
    input reset_manual,
    output reg [15:0] oled_data,
    output [3:0] anode,
    output [6:0] seg,
    output [15:0] led
    );
    
    parameter start = 2'b00;
    parameter gameplay = 2'b01;
    parameter pause = 2'b10;
    parameter over = 2'b11;
    
    wire [15:0] oled_data_start;
    wire [15:0] oled_data_play;
    wire [15:0] oled_data_end;
    wire start_finish;
    reg reset = 0;
    reg [1:0] state = 0;
    reg game_end = 0;
    wire btn_pulse;
    wire [1:0] level_state;
    wire dead_flag;
    
    difficulty_choose di (clk_625m, state, SW15, SW14, SW13, SW12, level_state);
    on_press u0 (btn, clk_625m, btn_pulse);
    Start sta (state, frame_begin, sample_pixel, clk_625m, oled_data_start, start_finish);
    End en (frame_begin,sample_pixel,clk_625m,oled_data_end);
    play pl (level_state, bullet_skill, up, down, pixel_index, reset, clk, state, frame_begin, sample_pixel, clk_625m, oled_data_play, anode, seg, led, dead_flag);
    
    always @(posedge clk_625m) begin
        if (btn_pulse) begin
            if (start_finish && (state == start)) begin
                state <= gameplay;
                reset <= 1;
            end else if (state == gameplay) begin
                state <= pause;
                reset <= 0;
            end else if (state == pause) begin 
                state <= gameplay;
            end else if (state == over) begin
                 state <= start;
            end
        end
        if ((game_end || dead_flag) && (state != over)) begin
            state <= over;
            reset <= 1;
        end     
    end
    
    always @ (posedge clk_625m) begin
        case (state)
            2'b00: oled_data <= oled_data_start;
            2'b01: oled_data <= oled_data_play;
            2'b10: oled_data <= oled_data_play;
            2'b11: oled_data <= oled_data_end;
        endcase
     end
     
     always @ (posedge clk_625m) begin //Manual end 
         if (reset_manual == 1) begin
             game_end <= 1;
         end else begin
             game_end <=0;
         end
     end
endmodule
