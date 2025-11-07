module enemy_move2(
    input  wire        clk,
    input  wire        clk_move_ce,   
    input  wire        reset_enemy,   
    input  wire        kill_all,      
    input  wire [6:0]  random_num,
    output reg  signed [8:0] anchor_x,
    output reg         [6:0] anchor_y
);
    reg y_direction = 0;
    initial begin
        anchor_x = -9'sd10;
        anchor_y = 7'd0;
    end

    always @(posedge clk) begin
        if (kill_all) begin
            // Instantly disappear: park off-screen left
            anchor_x <= -9'sd10;
            
        end else if (reset_enemy) begin
            
            anchor_x <= 9'sd95;
            anchor_y <= random_num;   
        end else if (clk_move_ce) begin
            if (anchor_x > -9'sd8)begin
                anchor_x <= anchor_x - 9'sd1;
                if (anchor_y == 0) begin
                    y_direction <= 0;
                    anchor_y <= anchor_y + 7'd1;
                end else if (anchor_y == 55) begin
                    y_direction <= 1;
                    anchor_y <= anchor_y - 7'd1;
                end else  begin 
                    if (y_direction == 0)
                        anchor_y <= anchor_y + 7'd1;
                    else if (y_direction == 1)
                        anchor_y <= anchor_y - 7'd1;
                    else
                        anchor_y <= anchor_y;
                end
            end

        end
    end
endmodule

