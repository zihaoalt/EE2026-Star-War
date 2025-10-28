`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/28 20:14:49
// Design Name: 
// Module Name: intro3
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


module intro3 (
    input  wire        clk,
    input  wire [6:0]  x,  // pixel x: 0..95
    input  wire [6:0]  y,  // pixel y: 0..63
    output reg  [15:0] pixel_data
);

    // ================================
    // Colors
    // ================================
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;

    // ================================
    // Font / layout assumptions
    // ================================
    // Stroke thickness: 1
    // Logical glyph box: 5x7 pixels
    localparam integer FONT_W = 5;
    localparam integer FONT_H = 7;

    // Spacing:
    // - 1px gap between characters
    // - 2px gap between lines
    localparam integer CHAR_GAP_X  = 1;
    localparam integer LINE_GAP_Y  = 2;
    localparam integer CHAR_STEP_X = FONT_W + CHAR_GAP_X; // 6 px advance
    localparam integer LINE_STEP_Y = FONT_H + LINE_GAP_Y; // 9 px advance

    // Anchor position (top-left of line 0)
    localparam integer X0 = 4;
    localparam integer Y0 = 8;

    // Line definitions:
    // line1: "INTRODUCTION"
    // line2: "led display HP"
    // line3: "segments display"
    // line4: "killed enemy"
    // line5: "next page: btnL"
    localparam integer LINE0_LEN = 12; // INTRODUCTION
    localparam integer LINE1_LEN = 14; // led display HP
    localparam integer LINE2_LEN = 15; // segment display
    localparam integer LINE3_LEN = 12; // killed enemy
    localparam integer LINE4_LEN = 15; // next page: btnL

    localparam integer NUM_LINES = 5;

    // =====================================
    // get_line_char(line_idx, char_idx)
    // Returns ASCII for each (line, character position)
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

                // line 1: "led display HP"
                3'd1: begin
                    case (char_idx)
                        0:  get_line_char = "l";
                        1:  get_line_char = "e";
                        2:  get_line_char = "d";
                        3:  get_line_char = " ";
                        4:  get_line_char = "d";
                        5:  get_line_char = "i";
                        6:  get_line_char = "s";
                        7:  get_line_char = "p";
                        8:  get_line_char = "l";
                        9:  get_line_char = "a";
                        10: get_line_char = "y";
                        11: get_line_char = " ";
                        12: get_line_char = "H";
                        13: get_line_char = "P";
                        default: get_line_char = " ";
                    endcase
                end

                // line 2: "segment display"
                3'd2: begin
                    case (char_idx)
                        0:  get_line_char = "s";
                        1:  get_line_char = "e";
                        2:  get_line_char = "g";
                        3:  get_line_char = "m";
                        4:  get_line_char = "e";
                        5:  get_line_char = "n";
                        6:  get_line_char = "t";
                        7:  get_line_char = " ";
                        8:  get_line_char = "d";
                        9: get_line_char = "i";
                        10: get_line_char = "s";
                        11: get_line_char = "p";
                        12: get_line_char = "l";
                        13: get_line_char = "a";
                        14: get_line_char = "y";
                        default: get_line_char = " ";
                    endcase
                end

                // line 3: "killed enemy"
                3'd3: begin
                    case (char_idx)
                        0:  get_line_char = "k";
                        1:  get_line_char = "i";
                        2:  get_line_char = "l";
                        3:  get_line_char = "l";
                        4:  get_line_char = "e";
                        5:  get_line_char = "d";
                        6:  get_line_char = " ";
                        7:  get_line_char = "e";
                        8:  get_line_char = "n";
                        9:  get_line_char = "e";
                        10: get_line_char = "m";
                        11: get_line_char = "y";
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
                        default: get_line_char = " ";
                    endcase
                end

                default: get_line_char = " ";
            endcase
        end
    endfunction

    // helper: get how many chars are in a line
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
    // font_row_bits(ch,row)
    // 5-bit wide row for the given character.
    // bit4 = leftmost pixel column of the glyph,
    // bit0 = rightmost.
    //
    // Only glyphs that appear in the 5 lines are included:
    //
    // Uppercase: I N T R O D U C H P L
    // Lowercase: l e d s p a y i g m n t k b x next...
    //            (covers: l,e,d, ,d,i,s,p,l,a,y, ,H,P,... etc)
    // Punctuation: space ' ', colon ':'
    // =====================================
    function [4:0] font_row_bits;
        input [7:0] ch;
        input [2:0] row;
        begin
            case (ch)

                // SPACE ' '
                8'h20: font_row_bits = 5'b00000;

                // ':'
                8'h3A: case (row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b00100;
                    3'd2: font_row_bits = 5'b00100;
                    3'd3: font_row_bits = 5'b00000;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b00000;
                    default: font_row_bits = 5'b00000;
                endcase

                // ======================
                // UPPERCASE LETTERS
                // ======================

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

                // 'H'
                8'h48: case(row)
                    3'd0: font_row_bits = 5'b10001;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b11111;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b10001;
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

                // ======================
                // LOWERCASE LETTERS
                // ======================

                // 'l'
                8'h6C: case(row)
                    3'd0: font_row_bits = 5'b01000;
                    3'd1: font_row_bits = 5'b01000;
                    3'd2: font_row_bits = 5'b01000;
                    3'd3: font_row_bits = 5'b01000;
                    3'd4: font_row_bits = 5'b01000;
                    3'd5: font_row_bits = 5'b01000;
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

                // 'y'
                8'h79: case(row)
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10001;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b01111;
                    3'd5: font_row_bits = 5'b00001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'i'
                8'h69: case(row)
                    3'd0: font_row_bits = 5'b00100;
                    3'd1: font_row_bits = 5'b00000;
                    3'd2: font_row_bits = 5'b01100;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b01110;
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

                // 't'
                8'h74: case(row)
                    3'd0: font_row_bits = 5'b00100;
                    3'd1: font_row_bits = 5'b00100;
                    3'd2: font_row_bits = 5'b11111;
                    3'd3: font_row_bits = 5'b00100;
                    3'd4: font_row_bits = 5'b00100;
                    3'd5: font_row_bits = 5'b00100;
                    3'd6: font_row_bits = 5'b00011;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'k'
                8'h6B: case(row)
                    3'd0: font_row_bits = 5'b10000;
                    3'd1: font_row_bits = 5'b10000;
                    3'd2: font_row_bits = 5'b10010;
                    3'd3: font_row_bits = 5'b10100;
                    3'd4: font_row_bits = 5'b11000;
                    3'd5: font_row_bits = 5'b10100;
                    3'd6: font_row_bits = 5'b10010;
                    default: font_row_bits = 5'b00000;
                endcase

                // 'b'
                8'h62: case(row)
                    3'd0: font_row_bits = 5'b10000;
                    3'd1: font_row_bits = 5'b10000;
                    3'd2: font_row_bits = 5'b11110;
                    3'd3: font_row_bits = 5'b10001;
                    3'd4: font_row_bits = 5'b10001;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b11110;
                    default: font_row_bits = 5'b00000;
                endcase

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

                // 'y' handled above (8'h79)

                default: font_row_bits = 5'b00000;
            endcase
        end
    endfunction

    // =====================================
    // pixel_on_text(x,y)
    //
    // For each pixel (x,y):
    //   1. figure out which line it's in
    //   2. figure out which character cell it's in
    //   3. index into glyph bitmap (5x7) and return 1 if lit
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

        // Loop through each of the 5 lines
        for (line_idx = 0; line_idx < NUM_LINES; line_idx = line_idx + 1) begin
            if (!hit) begin
                // Origin of this line
                line_x0 = X0;
                line_y0 = Y0 + line_idx * LINE_STEP_Y;

                // Check vertical fit first
                if ((py >= line_y0) && (py < line_y0 + FONT_H)) begin
                    rel_y = py - line_y0;

                    // Horizontal offset from start of line
                    rel_x = px - line_x0;

                    if (rel_x >= 0) begin
                        // figure out which character index this pixel falls in
                        char_idx = rel_x / CHAR_STEP_X;
                        line_len = get_line_len(line_idx[2:0]);

                        if ((char_idx >= 0) && (char_idx < line_len)) begin
                            glyph_x = rel_x % CHAR_STEP_X;
                            glyph_y = rel_y;

                            // only within the 5x7 box, not the gap column
                            if ((glyph_x < FONT_W) && (glyph_y < FONT_H)) begin
                                font_col = glyph_x; // 0..4
                                font_row = glyph_y; // 0..6

                                // which ASCII character
                                ch = get_line_char(line_idx[2:0], char_idx);

                                // look up bitmap row for that char+row
                                rowbits = font_row_bits(ch, font_row[2:0]);

                                // bit4 is leftmost column (font_col=0)
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
    // output pixel_data (registered)
    // =====================================
    always @(posedge clk) begin
        if (pixel_on_text(x, y))
            pixel_data <= WHITE;
        else
            pixel_data <= BLACK;
    end

endmodule

