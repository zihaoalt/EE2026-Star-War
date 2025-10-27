`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 09:39:09
// Design Name: 
// Module Name: starship
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


module starship(
    input clk,
    input [6:0] pixel_x,
    input [6:0] pixel_y,
    input reset,
    input up,
    input down,
    input [1:0] state,
    output starship_flag,
    output starship_bullet_flag
    );
    
reg[6:0] centre_x;
reg[6:0] centre_y;    
wire starship_flag_store; 
wire starship_bullet_flag_store;   
starship_design C0(clk,centre_x,centre_y,pixel_x,pixel_y,starship_flag_store,starship_bullet_flag_store); 

reg [1:0] move_dir; //up, down, stationary
parameter NONE  = 2'b00;
parameter UP    = 2'b01;
parameter DOWN  = 2'b10;
    
//update current direction according to button input
always @(posedge clk or posedge reset) begin
    if (reset)
        move_dir <= NONE;
    else if (up)
        move_dir <= UP;
    else if (down)
        move_dir <= DOWN;
    else
        move_dir <= NONE; 
end     

reg [16:0] move_counter; 
wire move_tick = (move_counter == 0);

always @(posedge clk or posedge reset) begin
    if (reset)
        move_counter <= 0;
    else if (move_counter >= 104166) //for 60hz
        move_counter <= 0;
    else
        move_counter <= move_counter + 1;
end
//movement     
    always@(posedge clk or posedge reset)begin
        if(reset)begin
            centre_x <= 5;
            centre_y <= 32;
         end
         else if(state == 2'b10) begin
            centre_x <= centre_x;
            centre_y <= centre_y;
         end
        else begin 
            if(move_tick) begin
            case(move_dir)
                    UP:   if (centre_y > 5)  centre_y <= centre_y - 1;
                    DOWN: if (centre_y < 59) centre_y <= centre_y + 1;
                    default: ; // NONE, do nothing
            endcase
          end
       end
    end

    assign starship_flag = starship_flag_store;
    assign starship_bullet_flag = starship_bullet_flag_store;
    
endmodule
