`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 17:47:37
// Design Name: 
// Module Name: Top_student
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


module Top_student(
    input btnR,
    input SW15, SW14, SW13, SW12,
    input bullet_skill,
    input up,
    input down,
    input clk,
    input btn,
    input SW0,
    input reset,
    output [7:0] JB,
    output [3:0] anode,
    output [6:0] seg,
    output [15:0] led
    );
    
    wire [15:0] oled_data;
    wire frame_begin;
    wire [12:0] pixel_index;
    wire sending_pixels;
    wire sample_pixel;
    wire clk_625;
    wire [1:0] state;
    
    clk_625m cl (clk, clk_625);
    Oled_Display oled(
        .clk(clk_625),
        .reset(0),
        .pixel_data(oled_data),
        .cs(JB[0]),
        .sdin(JB[1]),
        .sclk(JB[3]),
        .d_cn(JB[4]),
        .resn(JB[5]),
        .vccen(JB[6]),
        .pmoden(JB[7]),
        .frame_begin(frame_begin),
        .pixel_index(pixel_index),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel)
    );
    
    state_crl st (btnR, SW15, SW14, SW13, SW12, bullet_skill, up, down, pixel_index, clk, btn, clk_625, frame_begin, sample_pixel, reset, oled_data, anode, seg, led);
endmodule
