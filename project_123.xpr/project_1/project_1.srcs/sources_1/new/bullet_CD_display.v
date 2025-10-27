`timescale 1ns / 1ps

module bullet_CD_display(
    input [6:0] x,
    input [6:0] y,
    input [24:0] CD,
    output bullet_CD_flag
);

    localparam [24:0] MAX_COUNT = 25'd31249999;

    wire [25:0] remaining = MAX_COUNT - CD;

    wire [5:0]  bar_len = (remaining * 30) / MAX_COUNT;// scale to 30 bits long linearly

    localparam integer CENTER = 95 >> 1; // divide by 2 to get center
    wire [6:0] x_left  = CENTER - (bar_len >> 1);
    wire [6:0] x_right = x_left + bar_len;

    wire y_in = (y >= 60) && (y < 62);
    wire x_in = (bar_len != 0) && (x >= x_left) && (x < x_right);

    assign bullet_CD_flag = y_in && x_in;
endmodule

