`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/16 17:19:59
// Design Name: 
// Module Name: Start
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


module Start(
    input [15:0] oled_data_play,
    input btnR,
    input btnL,
    input [12:0] pixel_index,
    input [1:0] state,
    input frame_begin,
    input sample_pixel,
    input clk_625m,
    output reg [15:0] pixel_data = 16'h0000,
    output reg finish = 0
    );
    
    wire [6:0] x;
    wire [6:0] y;
    wire [15:0] page1;
    wire [15:0] page2;
    wire [15:0] page3;
    wire [15:0] page4;
    wire [15:0] skill1_page;
    wire [15:0] skill2_page;
    reg [2:0] page = 3'b001;
    
    xy_coordinate xy (pixel_index, x, y);
    begining be (x, y, clk_625m, page1);
    intro in (clk_625m, x, y, page2);
    introduction1 int1 (clk_625m, x, y, page3);
    intro2 int2 (clk_625m, x, y, page4);
    skill1 u12 (clk_625m, x, y, oled_data_play, skill1_page);
    skill2 u134 (clk_625m, x, y, oled_data_play, skill2_page);
    
    always @(posedge clk_625m) begin
      if (state == 2'b00) begin
        if (btnL && page == 1) begin
            page <= 2;
        end else if (page == 2 && btnR) begin
            finish <= 1;
        end
        else if (page == 2 && btnL) begin
            page <= 3;
        end
        else if (page == 3 && btnL) begin
            page <= 4;
        end
        else if (page == 4 && btnL) begin
            page <= 5;
        end
        else if (page == 5 && btnL) begin
            page <= 6;
        end
        else if (page == 6 && btnL) begin
            finish <= 1;
        end
      end else begin
        finish <= 0;
        page <= 1;
      end
    end
    
    always @(posedge clk_625m) begin
        case (page)
            3'd1:    pixel_data <= page1;
            3'd2:    pixel_data <= page2;
            3'd3:    pixel_data <= page3;
            3'd4:    pixel_data <= page4;
            3'd5:    pixel_data <= skill1_page;
            3'd6:    pixel_data <= skill2_page;
            default: pixel_data <= 16'h0000; // Default to black
        endcase
    end
endmodule
