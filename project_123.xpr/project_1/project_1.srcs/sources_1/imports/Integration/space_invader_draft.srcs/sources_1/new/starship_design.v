`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 10:42:04
// Design Name: 
// Module Name: starship_design
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


module starship_design(
    input clk,
    input [6:0] anchor_x,
    input [6:0] anchor_y,
    input [6:0] x,y,
    output reg starship_flag,
    output reg starship_bullet_flag
);

always@(*)begin
    starship_flag=0;
    starship_bullet_flag=0;
    if((x==anchor_x+2) && (y == anchor_y))
        starship_bullet_flag = 1;
    if ((x==anchor_x+4)&& ((y == anchor_y - 3) || (y == anchor_y + 3)))
        starship_flag = 1;
    else if ((x==anchor_x+3) && ( (y == anchor_y - 2) || (y == anchor_y + 2)))
        starship_flag =1;
    else if ((x==anchor_x+2) && ( (y > anchor_y - 3) && (y < anchor_y + 3)))
        starship_flag =1;
    else if ((x==anchor_x+1) && ( ((y > anchor_y - 4) && (y < anchor_y + 4)) && (y!= anchor_y -2)&&(y!= anchor_y+2)))
        starship_flag =1;
    else if ((x==anchor_x) && ((y > anchor_y - 4) && (y < anchor_y + 4)))
        starship_flag =1;
    else if ((x==anchor_x-1) && ((y > anchor_y - 3) && (y < anchor_y + 3)))
        starship_flag =1;
    else if ((x==anchor_x-2) && ( (y == anchor_y - 3) || (y == anchor_y + 3)))
        starship_flag =1;
    else if ((x==anchor_x-3) && ( (y == anchor_y - 2) || (y == anchor_y + 2)|| (y == anchor_y - 1) || (y == anchor_y + 1)))
        starship_flag =1;      
end

endmodule
