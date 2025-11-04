module boss_move(
    input  wire        clk,
    input  wire        clk_move_ce,   // CE in 'clk' domain
    input  wire        reset_enemy,   // 1-clk pulse
    input  wire        kill_all,      // 1-clk pulse
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
            // keep anchor_y (don't care)
        end else if (reset_enemy) begin
            // Respawn at right edge with new row
            anchor_x <= 9'sd95;
            anchor_y <= 26;
        end else if (clk_move_ce) begin
            if (anchor_x > 9'sd80)
                anchor_x <= anchor_x - 9'sd1;
            else begin
                if (anchor_y == 0) begin
                    y_direction <= 0;
                    anchor_y <= anchor_y + 7'd1;
                end else if (anchor_y == 51) begin
                    y_direction <= 1;
                    anchor_y <= anchor_y - 7'd1;
                end else  begin 
                    anchor_x <= anchor_x;
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
