`timescale 1ns / 1ps

module End(
    input frame_begin,
    input sample_pixel,
    input clk_625m,
    output reg [15:0] pixel_data
);

    reg [6:0] x;
    reg [5:0] y;
    parameter color = 16'hFFFF; // white


    wire G_pixel = (y>=10 && y<=16) &&
                   ((y==10 && x>=10 && x<=16) || 
                    (y==11 && (x==10 || x==16)) ||
                    (y==12 && x==10) ||
                    (y==13 && (x==10 || x>=13 && x<=16)) ||
                    (y==14 && (x==10 || x==16)) ||
                    (y==15 && (x==10 || x==16)) ||
                    (y==16 && x>=10 && x<=16));

    wire A_pixel = (y>=10 && y<=16) &&
                   ((y==10 && x>=18 && x<=24) ||
                    (y>=11 && y<=16 && (x==18 || x==24)) ||
                    (y==13 && x>=18 && x<=24));

    wire M_pixel = (y>=10 && y<=16) &&
                   ((x==26 || x==32) ||
                    ((y==11 || y==12) && (x==28 || x==30)));

    wire E1_pixel = (y>=10 && y<=16) &&
                    (((y==10 || y==13 || y==16) && x>=34 && x<=40) ||
                     (x==34 && y>=11 && y<=15));

    wire O_pixel = (y>=10 && y<=16) &&
                   (((y==10 || y==16) && x>=42 && x<=48) ||
                    ((x==42 || x==48) && y>=11 && y<=15));

    wire V_pixel = (y>=10 && y<=16) &&
                   (((y<=14) && (x==50 || x==56)) ||
                    (y==14 && (x==51 || x==55)) ||
                    (y==15 && (x==52 || x==54)) ||
                    (y==16 && x==53));

    wire E2_pixel = (y>=10 && y<=16) &&
                    (((y==10 || y==13 || y==16) && x>=58 && x<=64) ||
                     (x==58 && y>=11 && y<=15));

    wire R_pixel = (y>=10 && y<=16) &&
                   (((y==10 || y==13) && x>=66 && x<=72) ||
                    (x==66 && y>=11 && y<=16) ||
                    ((y==11 || y==12) && x==72) ||
                    ((y==14 && x==69) ||
                     (y==15 && x==70) ||
                     (y==16 && x==71)));


    wire P_pixel = (y>=30 && y<=36) &&
                   (((y==30 || y==33) && x>=10 && x<=16) ||
                    (x==10 && y>=31 && y<=36) ||
                    (x==16 && y>=31 && y<=32));

    wire R2_pixel = (y>=30 && y<=36) &&
                    (((y==30 || y==33) && x>=18 && x<=24) ||
                     (x==18 && y>=31 && y<=36) ||
                     ((y==31 || y==32) && x==24) ||
                     ((y==34 && x==21) ||
                      (y==35 && x==22) ||
                      (y==36 && x==23)));

    wire E3_pixel = (y>=30 && y<=36) &&
                    (((y==30 || y==33 || y==36) && x>=26 && x<=32) ||
                     (x==26 && y>=31 && y<=35));

    wire S1_pixel = (y>=30 && y<=36) &&
                    (((y==30 || y==33 || y==36) && x>=34 && x<=40) ||
                     (x==34 && (y==31 || y==32)) ||
                     (x==40 && (y==34 || y==35)));

    wire S2_pixel = (y>=30 && y<=36) &&
                    (((y==30 || y==33 || y==36) && x>=42 && x<=48) ||
                     (x==42 && (y==31 || y==32)) ||
                     (x==48 && (y==34 || y==35)));

    // space of 5 pixels, then L (now starting at x=54)
    wire L_pixel = (y>=30 && y<=36) &&
                   (x==54 || (y==36 && x>=54 && x<=60));

    // Main pixel assignment

    always @(posedge clk_625m) begin
        if(frame_begin) begin
            x <= 0;
            y <= 0;
            pixel_data <= 16'h0000; // black
        end else if(sample_pixel) begin
            if (G_pixel || A_pixel || M_pixel || E1_pixel || O_pixel || V_pixel || E2_pixel || R_pixel ||
                P_pixel || R2_pixel || E3_pixel || S1_pixel || S2_pixel || L_pixel)
                pixel_data <= color;
            else
                pixel_data <= 16'h0000;

            // Pixel scanning
            if(x==95) begin
                x<=0;
                if(y==63) y<=0;
                else y<=y+1;
            end else begin
                x<=x+1;
            end
        end
    end
endmodule
