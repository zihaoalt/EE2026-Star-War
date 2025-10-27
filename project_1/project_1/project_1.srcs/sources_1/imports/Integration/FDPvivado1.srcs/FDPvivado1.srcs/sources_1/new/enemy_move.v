module enemy_move(
    input  wire        clk,
    input  wire        clk_move_ce,   // CE in 'clk' domain
    input  wire        reset_enemy,   // 1-clk pulse
    input  wire        kill_all,      // 1-clk pulse
    input  wire [6:0]  random_num,
    output reg  signed [8:0] anchor_x,
    output reg         [6:0] anchor_y
);
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
            anchor_y <= random_num;   // 0..55 (fits 7 bits)
        end else if (clk_move_ce) begin
            if (anchor_x > -9'sd8)
                anchor_x <= anchor_x - 9'sd1;
        end
    end
endmodule
