`default_nettype none
module enemy_unit2(
    input  wire        clk,           
    input  wire        clk_move,      
    input  wire        shot,
    input  wire [6:0]  random_num,
    input  wire        reset_enemy,   
    input  wire        kill_all,      
    input  wire [6:0]  x,
    input  wire [6:0]  y,
    output wire        enemy_flag,    
    output reg         HP_deduct = 1'b0
);
    
    reg shot_q=1'b0, re_q=1'b0, ka_q=1'b0;
    always @(posedge clk) begin
        shot_q <= shot;
        re_q   <= reset_enemy;
        ka_q   <= kill_all;
    end
    wire shot_pulse        = shot        & ~shot_q;
    wire reset_enemy_pulse = reset_enemy & ~re_q;
    wire kill_all_pulse    = kill_all    & ~ka_q;

   
    reg alive = 1'b0;       
    reg shot_state = 1'b0;  

    always @(posedge clk) begin
        if (kill_all_pulse) begin
            alive      <= 1'b0;       
            shot_state <= 1'b0;       
        end else if (reset_enemy_pulse) begin
            alive      <= 1'b1;       
            shot_state <= 1'b0;
        end else if (shot_pulse) begin
            shot_state <= 1'b1;
        end
    end

    // Position driver
    wire signed [8:0] anchor_x;
    wire        [6:0] anchor_y;

    enemy_move2 enemy_move2_inst(
        .clk        (clk),              
        .clk_move_ce(clk_move),        
        .reset_enemy(reset_enemy_pulse), 
        .kill_all   (kill_all_pulse), 
        .random_num (random_num),
        .anchor_x   (anchor_x),
        .anchor_y   (anchor_y)
    );

    
    wire enemy_flag_raw;
    position_check2 position_check2_inst(
        .clk        (clk),
        .anchor_x   (anchor_x),
        .anchor_y   (anchor_y),
        .x          (x),
        .y          (y),
        .shot_state (shot_state),
        .enemy_flag (enemy_flag_raw)
    );

    assign enemy_flag = alive ? enemy_flag_raw : 1'b0;

    // HP_deduct: only when alive & not shot & at left edge; one-clk pulse
    wire at_left_unshot = alive && (~shot_state) && (anchor_x == -9'sd8);
    reg  at_left_unshot_q = 1'b0;
    always @(posedge clk) begin
        at_left_unshot_q <= at_left_unshot;
        HP_deduct        <= at_left_unshot & ~at_left_unshot_q;
    end
endmodule
`default_nettype wire

