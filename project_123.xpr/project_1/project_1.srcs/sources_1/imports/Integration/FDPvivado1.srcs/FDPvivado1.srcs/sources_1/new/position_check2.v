module position_check2(
    input clk,
    input signed [8:0] anchor_x,
    input [6:0] anchor_y,
    input [6:0] x,y,
    input shot_state,
    output reg enemy_flag

);


wire within_flag;
wire [3:0] image_x,image_y;
reg [7:0] image [0:7]; //8 rows, each row is 8 bits (8 pixels)
parameter image_width=4'd8;
parameter image_height=4'd8;

initial begin

    image[0] = 8'b00000111;
    image[1] = 8'b00001110;
    image[2] = 8'b00011100;
    image[3] = 8'b11111110;
    image[4] = 8'b11111110;
    image[5] = 8'b00011100;
    image[6] = 8'b00001110;
    image[7] = 8'b00000111;

end


assign within_flag = (x>=anchor_x) && (x<anchor_x+image_width) && (y>=anchor_y) && (y<anchor_y+image_height);
assign image_x = x - anchor_x;
assign image_y = y - anchor_y;


always @(posedge clk) begin
    if (shot_state)
        enemy_flag <= 1'b0;
    else if (x == 7'd95)
        enemy_flag <= 1'b0;
    else if (within_flag)
        enemy_flag <= image[image_y][7-image_x];
    
    else 
        enemy_flag <= 1'b0;
end

endmodule