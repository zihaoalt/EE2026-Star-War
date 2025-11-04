`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/28 18:40:40
// Design Name: 
// Module Name: intro2
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


module intro2 (
    input  wire        clk,
    input  wire [6:0]  x,  // current pixel x: 0..95
    input  wire [6:0]  y,  // current pixel y: 0..63
    output reg  [15:0] pixel_data
);

    // =====================================
    // Colors
    // =====================================
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;

    // =====================================
    // Font / layout assumptions
    // =====================================
    // 5x7 font, stroke thickness = 1
    localparam integer FONT_W = 5;  // glyph width in pixels
    localparam integer FONT_H = 7;  // glyph height in pixels

    // spacing
    localparam integer CHAR_GAP_X  = 1;                 // 1px gap between characters
    localparam integer LINE_GAP_Y  = 2;                 // 2px gap between lines
    localparam integer CHAR_STEP_X = FONT_W + CHAR_GAP_X; // 6 px advance per char
    localparam integer LINE_STEP_Y = FONT_H + LINE_GAP_Y; // 9 px advance per line

    // top-left of line 1 ("INTRODUCTION")
    localparam integer X0 = 4;
    localparam integer Y0 = 8;

    // how many characters in each line
    localparam integer LINE0_LEN = 12; // "INTRODUCTION"
    localparam integer LINE1_LEN = 13; // "move up: btnU"
    localparam integer LINE2_LEN = 15; // "move down: btnD"
    localparam integer LINE3_LEN = 13; // "end game: sw7"
    localparam integer LINE4_LEN = 16; // "next page: btnL"

    localparam integer NUM_LINES = 5;

    // =====================================
    // 1. get_line_char(line_idx, char_idx)
    // Returns ASCII character for each (line, column)
    // =====================================
    function [7:0] get_line_char;
        input [2:0] line_idx;    // 0..4
        input integer char_idx;
        begin
            case (line_idx)

                // line 0: "INTRODUCTION"
                3'd0: begin
                    case (char_idx)
                        0:  get_line_char = "I";
                        1:  get_line_char = "N";
                        2:  get_line_char = "T";
                        3:  get_line_char = "R";
                        4:  get_line_char = "O";
                        5:  get_line_char = "D";
                        6:  get_line_char = "U";
                        7:  get_line_char = "C";
                        8:  get_line_char = "T";
                        9:  get_line_char = "I";
                        10: get_line_char = "O";
                        11: get_line_char = "N";
                        default: get_line_char = " ";
                    endcase
                end

                // line 1: "move up: btnU"
                3'd1: begin
                    case (char_idx)
                        0:  get_line_char = "m";
                        1:  get_line_char = "o";
                        2:  get_line_char = "v";
                        3:  get_line_char = "e";
                        4:  get_line_char = " ";
                        5:  get_line_char = "u";
                        6:  get_line_char = "p";
                        7:  get_line_char = ":";
                        8:  get_line_char = " ";
                        9:  get_line_char = "b";
                        10: get_line_char = "t";
                        11: get_line_char = "n";
                        12: get_line_char = "U";
                        default: get_line_char = " ";
                    endcase
                end

                // line 2: "move down: btnD"
                3'd2: begin
                    case (char_idx)
                        0:  get_line_char = "m";
                        1:  get_line_char = "o";
                        2:  get_line_char = "v";
                        3:  get_line_char = "e";
                        4:  get_line_char = " ";
                        5:  get_line_char = "d";
                        6:  get_line_char = "o";
                        7:  get_line_char = "w";
                        8:  get_line_char = "n";
                        9:  get_line_char = ":";
                        10: get_line_char = " ";
                        11: get_line_char = "b";
                        12: get_line_char = "t";
                        13: get_line_char = "n";
                        14: get_line_char = "D";
                        default: get_line_char = " ";
                    endcase
                end

                // line 3: "end game: sw7"
                3'd3: begin
                    case (char_idx)
                        0:  get_line_char = "e";
                        1:  get_line_char = "n";
                        2:  get_line_char = "d";
                        3:  get_line_char = " ";
                        4:  get_line_char = "g";
                        5:  get_line_char = "a";
                        6:  get_line_char = "m";
                        7:  get_line_char = "e";
                        8:  get_line_char = ":";
                        9:  get_line_char = " ";
                        10: get_line_char = "s";
                        11: get_line_char = "w";
                        12: get_line_char = "7";
                        default: get_line_char = " ";
                    endcase
                end

                // line 4: "next page: btnL"
                3'd4: begin
                    case (char_idx)
                        0:  get_line_char = "n";
                        1:  get_line_char = "e";
                        2:  get_line_char = "x";
                        3:  get_line_char = "t";
                        4:  get_line_char = " ";
                        5:  get_line_char = "p";
                        6:  get_line_char = "a";
                        7:  get_line_char = "g";
                        8:  get_line_char = "e";
                        9:  get_line_char = ":";
                        10: get_line_char = " ";
                        11: get_line_char = "b";
                        12: get_line_char = "t";
                        13: get_line_char = "n";
                        14: get_line_char = "L";
                        15: get_line_char = " ";
                        default: get_line_char = " ";
                    endcase
                end

                default: get_line_char = " ";
            endcase
        end
    endfunction

    // helper: line length lookup
    function integer get_line_len;
        input [2:0] line_idx;
        begin
            case (line_idx)
                3'd0: get_line_len = LINE0_LEN;
                3'd1: get_line_len = LINE1_LEN;
                3'd2: get_line_len = LINE2_LEN;
                3'd3: get_line_len = LINE3_LEN;
                3'd4: get_line_len = LINE4_LEN;
                default: get_line_len = 0;
            endcase
        end
    endfunction

    // =====================================
    // 2. font_row_bits(ch,row)
    // Returns the 5-bit wide row of the glyph for 'ch'.
    // bit4 = leftmost pixel of glyph column 0
    // bit0 = rightmost pixel of glyph column 4
    //
    // We only implement characters we actually use.
    // =====================================
    function [4:0] font_row_bits;
        input [7:0] ch;    // ASCII
        input [2:0] row;   // 0..6
        begin
            case (ch)

                // space ' '
                8'h20: font_row_bits = 5'b00000;

                // ':'
                8'h3A: case (row)
                    3'd0:  font_row_bits = 5'b00000;
                    3'd1:  font_row_bits = 5'b00100;
                    3'd2:  font_row_bits = 5'b00100;
                    3'd3:  font_row_bits = 5'b00000;
                    3'd4:  font_row_bits = 5'b00100;
                    3'd5:  font_row_bits = 5'b00100;
                    3'd6:  font_row_bits = 5'b00000;
                    default: font_row_bits = 5'b00000;
                endcase

                // '7'
                8'h37: case (row)
                    3'd0: font_row_bits = 5'b11111;
                    3'd1: font_row_bits = 5'b00001;
                    3'd2: font_row_bits = 5'b00010;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b01000;
                    3'd5: font_row_bits = 5'b01000;
                    3'd6: font_row_bits = 5'b01000;
                    default: font_row_bits = 5'b00000;
                endcase

                // UPPERCASE letters we need: I N T R O D U C L U D L
                8'h49: case(row) // 'I'
                    3'd0: font_row_bits = 5'b11111;
                    3'd1: font_row_bits = 5'b00100;
                    3'd2: font_row_bits = 5'b00100;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b11111;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h4E: case(row) // 'N'
                    3'd0: font_row_bits = 5'b10001;
                    3'd1: font_row_bits = 5'b11001;
                    3'd2: font_row_bits = 5'b10101;
                    3'd3: font_row_bits = 5'b10011;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h54: case(row) // 'T'
                    3'd0: font_row_bits = 5'b11111;
                    3'd1: font_row_bits = 5'b00100;
                    3'd2: font_row_bits = 5'b00100;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b00100;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h52: case(row) // 'R'
                    3'd0: font_row_bits = 5'b11110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11110;
                    3'd4: font_row_bits = 5'b10100;
                    3'd5: font_row_bits = 5'b10010;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h4F: case(row) // 'O'
                    3'd0: font_row_bits = 5'b01110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h44: case(row) // 'D'
                    3'd0: font_row_bits = 5'b11110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b11110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h55: case(row) // 'U'
                    3'd0: font_row_bits = 5'b10001;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h43: case(row) // 'C'
                    3'd0: font_row_bits = 5'b01110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10000;
                    3'd3: font_row_bits = 5'b10000;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h4C: case(row) // 'L'
                    3'd0: font_row_bits = 5'b10000;
                    3'd1: font_row_bits = 5'b10000;
                    3'd2: font_row_bits = 5'b10000;
                    3'd3: font_row_bits = 5'b10000;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10000;
                    3'd6: font_row_bits = 5'b11111;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h57: case(row) // 'W' (used in "sw7")
                    3'd0: font_row_bits = 5'b10001;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10101;
                    3'd3: font_row_bits = 5'b10101;
                    3'd4: font_row_bits = 5'b10101;
                    3'd5: font_row_bits = 5'b11011;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h42: case(row) // 'B' (not displayed directly but here in case you later use "btnB")
                    3'd0: font_row_bits = 5'b11110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11110;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b11110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h50: case(row) // 'P' (not strictly used in text, but kept for completeness)
                    3'd0: font_row_bits = 5'b11110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11110;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10000;
                    3'd6: font_row_bits = 5'b10000;
                    default: font_row_bits = 5'b00000;
                endcase

                // lowercase letters we need:
                // m o v e u p d w n g a s x t b
                8'h6D: case(row) // 'm'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b11010;
                    3'd2: font_row_bits = 5'b10101;
                    3'd3: font_row_bits = 5'b10101;
                    3'd4: font_row_bits = 5'b10101;
                    3'd5: font_row_bits = 5'b10101;
                    3'd6: font_row_bits = 5'b10101;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h6F: case(row) // 'o'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h76: case(row) // 'v'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b01010;
                    3'd4: font_row_bits = 5'b01010;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b00100;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h65: case(row) // 'e'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11111;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h75: case(row) // 'u'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10011;
                    3'd6: font_row_bits = 5'b01101;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h70: case(row) // 'p'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b11110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b11110;
                    3'd5: font_row_bits = 5'b10000;
                    3'd6: font_row_bits = 5'b10000;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h64: case(row) // 'd'
                    3'd0: font_row_bits = 5'b00001;
                    3'd1: font_row_bits = 5'b00001;
                    3'd2: font_row_bits = 5'b01111;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01111;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h77: case(row) // 'w'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10101;
                    3'd4: font_row_bits = 5'b10101;
                    3'd5: font_row_bits = 5'b11011;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h6E: case(row) // 'n'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b11110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h67: case(row) // 'g'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01111;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b01111;
                    3'd5: font_row_bits = 5'b00001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h61: case(row) // 'a'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01110;
                    3'd2: font_row_bits = 5'b00001;
                    3'd3: font_row_bits = 5'b01111;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10011;
                    3'd6: font_row_bits = 5'b01101;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h73: case(row) // 's'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01111;
                    3'd2: font_row_bits = 5'b10000;
                    3'd3: font_row_bits = 5'b01110;
                    3'd4: font_row_bits = 5'b00001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h78: case(row) // 'x'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b01010;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b01010;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b00000;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h74: case(row) // 't'
                    3'd0: font_row_bits = 5'b00100;
                    3'd1: font_row_bits = 5'b00100;
                    3'd2: font_row_bits = 5'b11111;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b00011;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h62: case(row) // 'b'
                    3'd0: font_row_bits = 5'b10000;
                    3'd1: font_row_bits = 5'b10000;
                    3'd2: font_row_bits = 5'b11110;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b11110;
                    default: font_row_bits = 5'b00000;
                endcase

                default: font_row_bits = 5'b00000;
            endcase
        end
    endfunction

    // =====================================
    // 3. pixel_on_text(x,y)
    //
    // Returns 1 if the pixel at (x,y) should be lit white.
    // We:
    //   - figure out which line y is in
    //   - figure out which character x,y lands in
    //   - pull the 5x7 bitmap for that char
    // =====================================
    function pixel_on_text;
        input [6:0] px;
        input [6:0] py;

        integer line_idx;
        integer line_x0, line_y0;
        integer rel_x, rel_y;
        integer char_idx;
        integer glyph_x, glyph_y;
        integer font_col, font_row;
        integer line_len;

        reg [7:0] ch;
        reg [4:0] rowbits;
        integer bitpos;

        reg hit;
    begin
        hit = 1'b0;

        // check all lines
        for (line_idx = 0; line_idx < NUM_LINES; line_idx = line_idx + 1) begin
            if (!hit) begin
                // line origin
                line_x0 = X0;
                line_y0 = Y0 + line_idx * LINE_STEP_Y;

                // active line height check
                if ((py >= line_y0) && (py < line_y0 + FONT_H)) begin
                    rel_y = py - line_y0;

                    // figure out which character cell horizontally
                    rel_x    = px - line_x0;
                    if (rel_x >= 0) begin
                        char_idx = rel_x / CHAR_STEP_X;
                        line_len = get_line_len(line_idx[2:0]);

                        if ((char_idx >= 0) && (char_idx < line_len)) begin

                            glyph_x = rel_x % CHAR_STEP_X;
                            glyph_y = rel_y;

                            // only draw if we're inside the 5px glyph, not in the 1px gap
                            if ((glyph_x < FONT_W) && (glyph_y < FONT_H)) begin
                                font_col = glyph_x; // 0..4
                                font_row = glyph_y; // 0..6

                                // get character
                                ch = get_line_char(line_idx[2:0], char_idx);

                                // look up bitmap row for that char/row
                                rowbits = font_row_bits(ch, font_row[2:0]);

                                // bit4 is leftmost pixel column 0
                                bitpos = 4 - font_col;

                                if ((bitpos >= 0) && (bitpos < 5)) begin
                                    if (rowbits[bitpos])
                                        hit = 1'b1;
                                end
                            end
                        end
                    end
                end
            end
        end

        pixel_on_text = hit;
    end
    endfunction

    // =====================================
    // 4. Registered pixel output
    // =====================================
    always @(posedge clk) begin
        if (pixel_on_text(x, y))
            pixel_data <= WHITE;
        else
            pixel_data <= BLACK;
    end

endmodule
