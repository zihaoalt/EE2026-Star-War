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
    input  wire [6:0]  x,  // pixel x: 0..95
    input  wire [6:0]  y,  // pixel y: 0..63
    output reg  [15:0] pixel_data
);

    // =====================================
    // Display / font configuration
    // =====================================
    localparam [15:0] WHITE = 16'hFFFF;
    localparam [15:0] BLACK = 16'h0000;

    // 5x7 pixel font (thickness 1)
    localparam integer FONT_W_LOG    = 5; // width of glyph in pixels
    localparam integer FONT_H_LOG    = 7; // height of glyph in pixels

    // spacing
    localparam integer CHAR_GAP_X    = 1;                        // gap between chars
    localparam integer LINE_GAP_Y    = 2;                        // gap between lines
    localparam integer CHAR_STEP_X   = FONT_W_LOG + CHAR_GAP_X;  // 6 px per char
    localparam integer LINE_STEP_Y   = FONT_H_LOG + LINE_GAP_Y;  // 9 px per line

    // top-left anchor of line 0
    localparam integer X0            = 4;
    localparam integer Y0            = 8;

    // line lengths
    localparam integer LINE0_LEN = 12; // "INTRODUCTION"
    localparam integer LINE1_LEN = 13; // "move up: btnU"
    localparam integer LINE2_LEN = 15; // "move down: btnD"
    localparam integer LINE3_LEN = 13; // "end game: sw7"
    localparam integer LINE4_LEN = 16; // "next page: btnL"

    localparam integer NUM_LINES = 5;

    // =====================================
    // Map (line_idx, char_idx) -> ASCII char
    // =====================================
    function automatic [7:0] get_line_char;
        input [2:0] line_idx;     // 0..4
        input integer char_idx;
        begin
            case (line_idx)

                // LINE 0: "INTRODUCTION"
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

                // LINE 1: "move up: btnU"
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

                // LINE 2: "move down: btnD"
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

                // LINE 3: "end game: sw7"
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

                // LINE 4: "next page: btnL"
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

                default: begin
                    get_line_char = " ";
                end
            endcase
        end
    endfunction


    // =====================================
    // font_row_bits(ch,row)
    //
    // Returns 5 bits for this character row.
    // bit4 is leftmost pixel, bit0 is rightmost.
    //
    // Includes only glyphs that appear in your 5 lines:
    //   Uppercase: I N T R O D U C L U D L
    //              plus 'U','D','L' explicitly
    //   Lowercase: m o v e u p d w n g a s x t b r c l (superset)
    //   Digits: '7'
    //   Punctuation: space ' ', colon ':'
    // =====================================
    function automatic [4:0] font_row_bits;
        input [7:0] ch;     // ASCII
        input [2:0] row;    // 0..6
        begin
            case (ch)

                // SPACE ' '
                8'h20: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b00000;
                    3'd2: font_row_bits = 5'b00000;
                    3'd3: font_row_bits = 5'b00000;
                    3'd4: font_row_bits = 5'b00000;
                    3'd5: font_row_bits = 5'b00000;
                    3'd6: font_row_bits = 5'b00000;
                    default: font_row_bits = 5'b00000;
                endcase

                // ':'
                8'h3A: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b00100;
                    3'd2: font_row_bits = 5'b00100;
                    3'd3: font_row_bits = 5'b00000;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b00000;
                    default: font_row_bits = 5'b00000;
                endcase

                // DIGIT '7'
                8'h37: case(row) // '7'
                    3'd0: font_row_bits = 5'b11111;
                    3'd1: font_row_bits = 5'b00001;
                    3'd2: font_row_bits = 5'b00010;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b01000;
                    3'd5: font_row_bits = 5'b01000;
                    3'd6: font_row_bits = 5'b01000;
                    default: font_row_bits = 5'b00000;
                endcase

                // UPPERCASE LETTERS
                // 'I'
                8'h49: case(row)
                    3'd0: font_row_bits = 5'b11111;
                    3'd1: font_row_bits = 5'b00100;
                    3'd2: font_row_bits = 5'b00100;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b11111;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'N'
                8'h4E: case(row)
                    3'd0: font_row_bits = 5'b10001;
                    3'd1: font_row_bits = 5'b11001;
                    3'd2: font_row_bits = 5'b10101;
                    3'd3: font_row_bits = 5'b10011;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'T'
                8'h54: case(row)
                    3'd0: font_row_bits = 5'b11111;
                    3'd1: font_row_bits = 5'b00100;
                    3'd2: font_row_bits = 5'b00100;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b00100;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'R'
                8'h52: case(row)
                    3'd0: font_row_bits = 5'b11110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11110;
                    3'd4: font_row_bits = 5'b10100;
                    3'd5: font_row_bits = 5'b10010;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'O'
                8'h4F: case(row)
                    3'd0: font_row_bits = 5'b01110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'D'
                8'h44: case(row)
                    3'd0: font_row_bits = 5'b11110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b11110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'U'
                8'h55: case(row)
                    3'd0: font_row_bits = 5'b10001;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'C'
                8'h43: case(row)
                    3'd0: font_row_bits = 5'b01110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10000;
                    3'd3: font_row_bits = 5'b10000;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'L'
                8'h4C: case(row)
                    3'd0: font_row_bits = 5'b10000;
                    3'd1: font_row_bits = 5'b10000;
                    3'd2: font_row_bits = 5'b10000;
                    3'd3: font_row_bits = 5'b10000;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10000;
                    3'd6: font_row_bits = 5'b11111;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'W'
                8'h57: case(row)
                    3'd0: font_row_bits = 5'b10001;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10101;
                    3'd3: font_row_bits = 5'b10101;
                    3'd4: font_row_bits = 5'b10101;
                    3'd5: font_row_bits = 5'b11011;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'B'
                8'h42: case(row)
                    3'd0: font_row_bits = 5'b11110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11110;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b11110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'P'
                8'h50: case(row)
                    3'd0: font_row_bits = 5'b11110;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11110;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10000;
                    3'd6: font_row_bits = 5'b10000;
                    default: font_row_bits = 5'b00000;
                endcase

                // LOWERCASE LETTERS
                // 'm'
                8'h6D: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b11010;
                    3'd2: font_row_bits = 5'b10101;
                    3'd3: font_row_bits = 5'b10101;
                    3'd4: font_row_bits = 5'b10101;
                    3'd5: font_row_bits = 5'b10101;
                    3'd6: font_row_bits = 5'b10101;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'o'
                8'h6F: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'v'
                8'h76: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b01010;
                    3'd4: font_row_bits = 5'b01010;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b00100;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'e'
                8'h65: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11111;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'u'
                8'h75: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10011;
                    3'd6: font_row_bits = 5'b01101;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'p'
                8'h70: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b11110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b11110;
                    3'd5: font_row_bits = 5'b10000;
                    3'd6: font_row_bits = 5'b10000;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'd'
                8'h64: case(row)
                    3'd0: font_row_bits = 5'b00001;
                    3'd1: font_row_bits = 5'b00001;
                    3'd2: font_row_bits = 5'b01111;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01111;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'w'
                8'h77: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10101;
                    3'd4: font_row_bits = 5'b10101;
                    3'd5: font_row_bits = 5'b11011;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'n'
                8'h6E: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b11110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b10001;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'g'
                8'h67: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01111;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b01111;
                    3'd5: font_row_bits = 5'b00001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'a'
                8'h61: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01110;
                    3'd2: font_row_bits = 5'b00001;
                    3'd3: font_row_bits = 5'b01111;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10011;
                    3'd6: font_row_bits = 5'b01101;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'm'
                8'h6D: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b11010;
                    3'd2: font_row_bits = 5'b10101;
                    3'd3: font_row_bits = 5'b10101;
                    3'd4: font_row_bits = 5'b10101;
                    3'd5: font_row_bits = 5'b10101;
                    3'd6: font_row_bits = 5'b10101;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'o' already defined above

                // 's'
                8'h73: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01111;
                    3'd2: font_row_bits = 5'b10000;
                    3'd3: font_row_bits = 5'b01110;
                    3'd4: font_row_bits = 5'b00001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'w' already defined above

                // 'x'
                8'h78: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b01010;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b01010;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b00000;
                    default: font_row_bits = 5'b00000;
                endcase

                default: begin
                    // Any unsupported char -> blank glyph
                    font_row_bits = 5'b00000;
                end
            endcase
        end
    endfunction


    // =====================================
    // pixel_on_text(x, y)
    //
    // Returns 1 if the pixel at (x,y) should be lit (WHITE).
    // =====================================
    function automatic pixel_on_text;
        input [6:0] px;
        input [6:0] py;

        integer line_idx;
        integer line_x0, line_y0;
        integer line_len;

        integer rel_x, rel_y;
        integer char_idx;
        integer glyph_x, glyph_y;
        integer font_col, font_row;
        integer bitpos;

        reg [7:0] ch;
        reg [4:0] bits;
        reg hit;

    begin
        hit = 1'b0;

        // Check all lines 0..4
        for (line_idx = 0; line_idx < NUM_LINES; line_idx = line_idx + 1) begin
            if (!hit) begin
                // Where this line starts
                line_x0 = X0;
                line_y0 = Y0 + line_idx * LINE_STEP_Y;

                // Get this line's length
                case (line_idx)
                    0: line_len = LINE0_LEN;
                    1: line_len = LINE1_LEN;
                    2: line_len = LINE2_LEN;
                    3: line_len = LINE3_LEN;
                    4: line_len = LINE4_LEN;
                    default: line_len = 0;
                endcase

                // Vertical bounds first
                if ((py >= line_y0) &&
                    (py <  line_y0 + FONT_H_LOG)) begin

                    rel_y = py - line_y0;

                    // Horizontal check
                    if (px >= line_x0) begin
                        rel_x    = px - line_x0;
                        char_idx = rel_x / CHAR_STEP_X;

                        if (char_idx >= 0 && char_idx < line_len) begin
                            glyph_x = rel_x % CHAR_STEP_X;
                            glyph_y = rel_y;

                            // Only draw inside glyph body (not the 1px gap)
                            if ((glyph_x < FONT_W_LOG) &&
                                (glyph_y < FONT_H_LOG)) begin

                                font_col = glyph_x; // 0..4
                                font_row = glyph_y; // 0..6

                                // Which ASCII char?
                                ch = get_line_char(line_idx[2:0], char_idx);

                                // Look up its row bits
                                bits   = font_row_bits(ch, font_row[2:0]);

                                // bit4 is leftmost pixel
                                bitpos = 4 - font_col;

                                if (bitpos >= 0 && bitpos < 5) begin
                                    if (bits[bitpos])
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
    // Registered output pixel_data
    // =====================================
    always @(posedge clk) begin
        if (pixel_on_text(x, y))
            pixel_data <= WHITE;
        else
            pixel_data <= BLACK;
    end

endmodule

