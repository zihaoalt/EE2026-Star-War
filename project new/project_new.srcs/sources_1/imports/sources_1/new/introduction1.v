`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/28 18:39:58
// Design Name: 
// Module Name: introduction1
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


module introduction1 (
    input  wire        clk,
    input  wire [6:0]  x,  // current pixel x: 0..95
    input  wire [6:0]  y,  // current pixel y: 0..63
    output reg  [15:0] pixel_data
);

    // =====================================
    // Display / font configuration
    // =====================================
    localparam [15:0] WHITE = 16'hFFFF;
    localparam [15:0] BLACK = 16'h0000;

    // 5x7 font (logical), stroke thickness = 1
    localparam integer FONT_W_LOG    = 5;  // glyph width in pixels
    localparam integer FONT_H_LOG    = 7;  // glyph height in pixels

    // Spacing
    localparam integer CHAR_GAP_X    = 1;                        // 1px between chars
    localparam integer LINE_GAP_Y    = 2;                        // 2px between lines
    localparam integer CHAR_STEP_X   = FONT_W_LOG + CHAR_GAP_X;  // 6 px advance per char
    localparam integer LINE_STEP_Y   = FONT_H_LOG + LINE_GAP_Y;  // 9 px advance per line

    // Top-left of line 0 ("INTRODUCTION")
    localparam integer X0            = 4;
    localparam integer Y0            = 8;

    // line lengths
    localparam integer LINE0_LEN = 12; // "INTRODUCTION"
    localparam integer LINE1_LEN = 12; // "pause: btnL"
    localparam integer LINE2_LEN = 13; // "resume: btnL"
    localparam integer LINE3_LEN = 16; // "next page: btnL"

    localparam integer NUM_LINES = 4;

    // =====================================
    // get_line_char(line_idx, char_idx)
    // Returns the ASCII code of the character at [line_idx][char_idx]
    // =====================================
    function automatic [7:0] get_line_char;
        input [1:0] line_idx;
        input integer char_idx;
        begin
            case (line_idx)

                // LINE 0: "INTRODUCTION"
                2'd0: begin
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

                // LINE 1: "pause: btnL"
                2'd1: begin
                    case (char_idx)
                        0:  get_line_char = "p";
                        1:  get_line_char = "a";
                        2:  get_line_char = "u";
                        3:  get_line_char = "s";
                        4:  get_line_char = "e";
                        5:  get_line_char = ":";
                        6:  get_line_char = " ";
                        7:  get_line_char = "b";
                        8:  get_line_char = "t";
                        9:  get_line_char = "n";
                        10: get_line_char = "L";
                        11: get_line_char = " ";
                        default: get_line_char = " ";
                    endcase
                end

                // LINE 2: "resume: btnL"
                2'd2: begin
                    case (char_idx)
                        0:  get_line_char = "r";
                        1:  get_line_char = "e";
                        2:  get_line_char = "s";
                        3:  get_line_char = "u";
                        4:  get_line_char = "m";
                        5:  get_line_char = "e";
                        6:  get_line_char = ":";
                        7:  get_line_char = " ";
                        8:  get_line_char = "b";
                        9:  get_line_char = "t";
                        10: get_line_char = "n";
                        11: get_line_char = "L";
                        12: get_line_char = " ";
                        default: get_line_char = " ";
                    endcase
                end

                // LINE 3: "next page: btnL"
                2'd3: begin
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
    // Returns a 5-bit row (bit4=leftmost, bit0=rightmost) for given character.
    //
    // Only includes glyphs we actually need:
    //   Uppercase: I N T R O D U C L
    //   Lowercase: p a u s e b t n r m x g o l c
    //              (and reused ones like 'u','e','n','t','a','g','e', etc.)
    //   Colon ':'
    //   Space ' '
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

                // UPPERCASE WE NEED: I N T R O D U C L
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

                // LOWERCASE WE NEED:
                // p a u s e b t n r m x g o l c
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

                8'h72: case(row) // 'r'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b10110;
                    3'd2: font_row_bits = 5'b11001;
                    3'd3: font_row_bits = 5'b10000;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10000;
                    3'd6: font_row_bits = 5'b10000;
                    default: font_row_bits = 5'b00000;
                endcase

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

                8'h6C: case(row) // 'l'
                    3'd0: font_row_bits = 5'b01000;
                    3'd1: font_row_bits = 5'b01000;
                    3'd2: font_row_bits = 5'b01000;
                    3'd3: font_row_bits = 5'b01000;
                    3'd4: font_row_bits = 5'b01000;
                    3'd5: font_row_bits = 5'b01000;
                    3'd6: font_row_bits = 5'b00100;
                    default: font_row_bits = 5'b00000;
                endcase

                8'h63: case(row) // 'c'
                    3'd0: font_row_bits = 5'b00000;
                    3'd1: font_row_bits = 5'b01110;
                    3'd2: font_row_bits = 5'b10001;
                    3'd3: font_row_bits = 5'b10000;
                    3'd4: font_row_bits = 5'b10000;
                    3'd5: font_row_bits = 5'b10001;
                    3'd6: font_row_bits = 5'b01110;
                    default: font_row_bits = 5'b00000;
                endcase

                default: begin
                    // unsupported char => blank
                    font_row_bits = 5'b00000;
                end
            endcase
        end
    endfunction


    // =====================================
    // pixel_on_text(x, y)
    // Returns 1 if pixel (x,y) should be white (inside text glyph)
    // =====================================
    function automatic pixel_on_text;
        input [6:0] px;
        input [6:0] py;

        integer line_idx;
        integer rel_y;
        integer char_idx;
        integer line_x0, line_y0;
        integer line_len;

        integer rel_x;
        integer glyph_x, glyph_y;
        integer font_col, font_row;
        integer bitpos;

        reg [7:0] ch;
        reg [4:0] bits;
        reg hit;

    begin
        hit = 1'b0;

        // Check each of the 4 lines
        for (line_idx = 0; line_idx < NUM_LINES; line_idx = line_idx + 1) begin
            if (!hit) begin
                // Compute this line's origin
                line_x0 = X0;
                line_y0 = Y0 + line_idx * LINE_STEP_Y;

                // How long this line is
                case (line_idx)
                    0: line_len = LINE0_LEN;
                    1: line_len = LINE1_LEN;
                    2: line_len = LINE2_LEN;
                    3: line_len = LINE3_LEN;
                    default: line_len = 0;
                endcase

                // Check vertical coverage
                if ((py >= line_y0) &&
                    (py <  line_y0 + FONT_H_LOG)) begin

                    rel_y = py - line_y0;

                    // Check horizontal coverage
                    if (px >= line_x0) begin
                        rel_x    = px - line_x0;
                        char_idx = rel_x / CHAR_STEP_X;

                        if (char_idx >= 0 && char_idx < line_len) begin
                            glyph_x = rel_x % CHAR_STEP_X;
                            glyph_y = rel_y;

                            // inside the glyph box (exclude the 1px char gap)
                            if ((glyph_x < FONT_W_LOG) &&
                                (glyph_y < FONT_H_LOG)) begin

                                font_col = glyph_x; // 0..4
                                font_row = glyph_y; // 0..6

                                // which character are we drawing?
                                ch = get_line_char(line_idx[1:0], char_idx);

                                // get its bitmap row
                                bits   = font_row_bits(ch, font_row[2:0]);

                                // bit4 is leftmost column
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
    // Registered pixel output
    // =====================================
    always @(posedge clk) begin
        if (pixel_on_text(x, y))
            pixel_data <= WHITE;
        else
            pixel_data <= BLACK;
    end

endmodule
