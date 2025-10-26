`default_nettype none
module enemy_master(
    input  wire        clk,
    input  wire        clk_move,
    input  wire        shot_flag,
    input  wire [6:0]  x,
    input  wire [6:0]  y,
    input  wire        reset_enemy_module,
    input  wire [1:0]  level_state,
    input  wire        pause,
    output wire        enemy_flag,
    output wire        HP_deduct
);
    // ONLY declarations, no "= 0" here:
    wire reset_enemy_1, reset_enemy_2, reset_enemy_3, reset_enemy_4, reset_enemy_5;
    wire [6:0] random_num_1, random_num_2, random_num_3, random_num_4, random_num_5;

    wire enemy_flag_1, enemy_flag_2, enemy_flag_3, enemy_flag_4, enemy_flag_5;
    wire HP_deduct_1, HP_deduct_2, HP_deduct_3, HP_deduct_4, HP_deduct_5;
    
    wire kill_all;

    reg  shot_1, shot_2, shot_3, shot_4, shot_5;

    assign enemy_flag = enemy_flag_1 | enemy_flag_2 | enemy_flag_3 | enemy_flag_4 | enemy_flag_5;
    assign HP_deduct = HP_deduct_1 | HP_deduct_2 | HP_deduct_3 | HP_deduct_4 | HP_deduct_5;

    always @* begin
        shot_1=1'b0; shot_2=1'b0; shot_3=1'b0; shot_4=1'b0; shot_5=1'b0;
        if (shot_flag) begin
            if      (enemy_flag_1) shot_1=1'b1;
            else if (enemy_flag_2) shot_2=1'b1;
            else if (enemy_flag_3) shot_3=1'b1;
            else if (enemy_flag_4) shot_4=1'b1;
            else if (enemy_flag_5) shot_5=1'b1;
        end
    end



    reset_enemy_new #(
        .CLK_HZ (6_250_000)
    ) u_reset (
        .clk               (clk),
        .reset_enemy_module(reset_enemy_module),
        .kill_all(kill_all), 
        .level_state(level_state), 
        .pause(pause), 
        .reset_enemy_1     (reset_enemy_1),
        .reset_enemy_2     (reset_enemy_2),
        .reset_enemy_3     (reset_enemy_3),
        .reset_enemy_4     (reset_enemy_4),
        .reset_enemy_5     (reset_enemy_5),
        .random_num_1      (random_num_1),
        .random_num_2      (random_num_2),
        .random_num_3      (random_num_3),
        .random_num_4      (random_num_4),
        .random_num_5      (random_num_5)
    );


enemy_unit enemy1(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_1),
    .random_num(random_num_1),
    .reset_enemy(reset_enemy_1),
    .kill_all(kill_all),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_1),
    .HP_deduct(HP_deduct_1)
);

enemy_unit enemy2(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_2),
    .random_num(random_num_2),
    .reset_enemy(reset_enemy_2),
    .kill_all(kill_all),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_2),
    .HP_deduct(HP_deduct_2)
);

enemy_unit enemy3(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_3),
    .random_num(random_num_3),
    .reset_enemy(reset_enemy_3),
    .kill_all(kill_all),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_3),
    .HP_deduct(HP_deduct_3)
);

enemy_unit enemy4(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_4),
    .random_num(random_num_4),
    .reset_enemy(reset_enemy_4),
    .kill_all(kill_all),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_4),
    .HP_deduct(HP_deduct_4)
);

enemy_unit enemy5(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_5),
    .random_num(random_num_5),
    .reset_enemy(reset_enemy_5),
    .kill_all(kill_all),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_5),
    .HP_deduct(HP_deduct_5)
);

endmodule
`default_nettype wire
