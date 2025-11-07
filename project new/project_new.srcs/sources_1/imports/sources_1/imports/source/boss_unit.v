`default_nettype none
module boss_unit(
    input  wire        clk,           
    input  wire        clk_move,      
    input  wire        shot,
    input  wire        boss_appear,   
    input  wire        kill_all,      
    input  wire [6:0]  x,
    input  wire [6:0]  y,
    output wire        boss_flag,    
    output wire         boss_fire
);
    // Sync/edge-detect local controls (robust even if levels)
    reg shot_q=1'b0, ba_q=1'b0, ka_q=1'b0;
    always @(posedge clk) begin
        shot_q <= shot;
        ba_q   <= boss_appear;
        ka_q   <= kill_all;
    end
    wire shot_pulse        = shot        & ~shot_q;
    wire boss_appear_pulse = boss_appear & ~ba_q;
    wire kill_all_pulse    = kill_all    & ~ka_q;

    
    reg alive = 1'b0;       // visible/active on screen
    reg shot_state = 1'b0;  // has this enemy been shot
    reg [3:0] shot_count = 11'b0;

    always @(posedge clk) begin
        if (kill_all_pulse) begin
            alive      <= 1'b0;       
            shot_state <= 1'b0; 
            shot_count <= 4'b0;
        end else if (boss_appear_pulse) begin
            alive      <= 1'b1;       
            shot_state <= 1'b0;
            shot_count <= 4'b0;
        end else if (shot_pulse) begin
            if (shot_count == 10) begin
                shot_state <= 1'b1;
                alive <= 1'b0;
                shot_count <= 4'b0;
            end else begin
                shot_count <= shot_count + 1;
                shot_state <= shot_state;
                alive <= alive;
            end
        end
    end

  
    wire signed [8:0] anchor_x;
    wire        [6:0] anchor_y;

    boss_move boss_move_inst(
        .clk        (clk),               
        .clk_move_ce(clk_move),          
        .reset_enemy(boss_appear_pulse), 
        .kill_all   (kill_all_pulse),    
        .anchor_x   (anchor_x),
        .anchor_y   (anchor_y)
    );

    // Visibility mask into flag: only report if alive
    wire enemy_flag_raw;
    boss_position_check boss_position_check_inst(
        .clk        (clk),
        .anchor_x   (anchor_x),
        .anchor_y   (anchor_y),
        .x          (x),
        .y          (y),
        .shot_state (shot_state),
        .boss_appear(boss_appear),
        .enemy_flag (enemy_flag_raw),
        .boss_fire  (boss_fire)
    );

    assign boss_flag = alive ? enemy_flag_raw : 1'b0;


endmodule
`default_nettype wire


