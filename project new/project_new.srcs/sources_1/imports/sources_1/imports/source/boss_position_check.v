module boss_position_check(
    input clk,
    input signed [8:0] anchor_x,
    input [6:0] anchor_y,
    input [6:0] x,y,
    input shot_state,
    input boss_appear,
    output reg enemy_flag,
    output reg boss_fire

);

wire within_flag;
wire [3:0] image_x,image_y;
reg [11:0] image [0:11]; //12 rows, each row is 12 bits (12 pixels)
parameter image_width=4'd12;
parameter image_height=4'd12;
reg boss_appear_state;

always@(*)begin
if (boss_appear)
boss_appear_state = 1;
else
boss_appear_state = boss_appear_state;
end

initial begin

    image[0] = 12'b000001111111;
    image[1] = 12'b000011110000;
    image[2] = 12'b000111100000;
    image[3] = 12'b001111110000;
    image[4] = 12'b000001111111;
    image[5] = 12'b111111111100;
    image[6] = 12'b111111111100;
    image[7] = 12'b000001111111;
    image[8] = 12'b001111110000;
    image[9] = 12'b000111100000;
    image[10]= 12'b000011110000;
    image[11]= 12'b000001111111;

end


assign within_flag = (x>=anchor_x) && (x<anchor_x+image_width) && (y>=anchor_y) && (y<anchor_y+image_height);
assign image_x = x - anchor_x;
assign image_y = y - anchor_y;

reg bf_q = 1'b0;
always @(posedge clk) begin
if (shot_state == 0 && boss_appear_state == 1)begin
    if (image_x == 4'd0 && image_y == 4'd5 && enemy_flag) begin
        if (bf_q == 1'b0) begin
            boss_fire <= 1'b1;
            bf_q <= 1'b1;
        end
        else begin
            boss_fire <= 1'b0;
            bf_q <= bf_q;
        end
    end else begin
        bf_q <= 1'b0;
        boss_fire <= 1'b0;
        end
end else
    boss_fire <= 1'b0;
           
end

always @(posedge clk) begin
    if (shot_state)
        enemy_flag <= 1'b0;
    else if (x == 7'd95)
        enemy_flag <= 1'b0;
    else if (within_flag)
        enemy_flag <= image[image_y][11-image_x];
    
    else 
        enemy_flag <= 1'b0;
end

endmodule
