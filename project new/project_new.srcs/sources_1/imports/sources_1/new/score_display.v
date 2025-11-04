`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/21 12:13:07
// Design Name: 
// Module Name: score_display
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


module score_display(
    input BE_collision,
    input clk,
    input [1:0] state,
    output reg [3:0] anode = 4'b1111,
    output reg [6:0] seg = 7'b1111111,
    output reg boss_appear = 0
    );
    
    reg [3:0] a = 0;
    reg [3:0] b = 0;
    reg [3:0] c = 0;
    reg [3:0] d = 0;
    reg [15:0] counter = 0;
    reg [17:0] counter_ = 0;
    reg start_count = 0;
    reg [6:0] seg1 = 7'b1111111;
    reg [6:0] seg2 = 7'b1111111;
    reg [6:0] seg3 = 7'b1111111;
    reg [6:0] seg4 = 7'b1111111;

    always @ (posedge clk) begin
        if ( BE_collision && !counter_ && state == 2'b01) begin
            a <= a == 9 ? 0 : a + 1;
            b <= b == 9 ?  (a == 9 ? 0 : b) : (a == 9 ? b + 1 : b);
            c <= c == 9 ? (b == 9 ? (a == 9 ? 0 : c) : c ) : (b == 9 ? (a == 9 ? c + 1 : c) : c );
            d <= d == 9 ? ( c == 9 ? (b == 9 ? (a == 9 ? 0 : d) : d ) : d) : (c == 9 ? (b == 9 ? (a == 9 ? d + 1 : d) : d ) : d);
            start_count <= 1;
            counter_ <= counter_ + 1;
        end
        if (start_count) begin
            counter_ <= counter_ + 1;
            if (counter_ == 62500) begin
                start_count <= 0;
                counter_ <= 0;
            end
        end
            
        if (state == 2'b00) begin
            a <= 0;
            b <= 0;
            c <= 0;
            d <= 0;
        end
        
        counter <= counter == 24999 ? 0 : counter + 1;
        if (counter == 24999) begin
            if (anode == 4'b1110) begin
                anode <= 4'b1101;
                seg <= seg2;
            end else if (anode == 4'b1101) begin
                anode <= 4'b1011;
                seg <= seg3;
            end else if (anode == 4'b1011) begin
                anode <= 4'b0111;
                seg <= seg4;
            end else begin
                anode <= 4'b1110;
                seg <= seg1;
            end
        end
        if (a==1) begin
            seg1 <= 7'b1111001;
        end else if (a==2) begin
            seg1 <= 7'b0100100;
        end else if (a==3) begin
            seg1 <= 7'b0110000;
        end else if (a==4) begin
            seg1 <= 7'b0011001;
        end else if (a==5) begin
            seg1 <= 7'b0010010;
        end else if (a==6) begin
            seg1 <= 7'b0000010;
        end else if (a==7) begin
            seg1 <= 7'b1111000;
        end else if (a==8) begin
            seg1 <= 7'b0000000;
        end else if (a==9) begin
            seg1 <= 7'b0010000;
        end else begin
            seg1 <= 7'b1000000;
        end
        
        if (b==1) begin
            seg2 <= 7'b1111001;
        end else if (b==2) begin
            seg2 <= 7'b0100100;
        end else if (b==3) begin
            seg2 <= 7'b0110000;
        end else if (b==4) begin
            seg2 <= 7'b0011001;
        end else if (b==5) begin
            seg2 <= 7'b0010010;
        end else if (b==6) begin
            seg2 <= 7'b0000010;
        end else if (b==7) begin
            seg2 <= 7'b1111000;
        end else if (b==8) begin
            seg2 <= 7'b0000000;
        end else if (b==9) begin
            seg2 <= 7'b0010000;
        end else begin
            seg2 <= 7'b1000000;
        end
                        
        if (c==1) begin
            seg3 <= 7'b1111001;
        end else if (c==2) begin
            seg3 <= 7'b0100100;
        end else if (c==3) begin
            seg3 <= 7'b0110000;
        end else if (c==4) begin
            seg3 <= 7'b0011001;
        end else if (c==5) begin
            seg3 <= 7'b0010010;
        end else if (c==6) begin
            seg3 <= 7'b0000010;
        end else if (c==7) begin
            seg3 <= 7'b1111000;
        end else if (c==8) begin
            seg3 <= 7'b0000000;
        end else if (c==9) begin
            seg3 <= 7'b0010000;
        end else begin
            seg3 <= 7'b1000000;
        end
        
        if (d==1) begin
            seg4 <= 7'b1111001;
        end else if (d==2) begin
            seg4 <= 7'b0100100;
        end else if (d==3) begin
            seg4 <= 7'b0110000;
        end else if (d==4) begin
            seg4 <= 7'b0011001;
        end else if (d==5) begin
            seg4 <= 7'b0010010;
        end else if (d==6) begin
            seg4 <= 7'b0000010;
        end else if (d==7) begin
            seg4 <= 7'b1111000;
        end else if (d==8) begin
            seg4 <= 7'b0000000;
        end else if (d==9) begin
            seg4 <= 7'b0010000;
        end else begin
            seg4 <= 7'b1000000;
        end
        
        if ( ((d*1000 + c*100 + b*10 + a) % 100 == 30) && counter_ == 1) begin
            boss_appear <= 1;
        end else begin
            boss_appear <= 0;
        end
    end
    
    
endmodule
