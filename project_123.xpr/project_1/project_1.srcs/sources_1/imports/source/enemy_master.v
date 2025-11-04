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
    input  wire        boss_appear,
    output wire        enemy_flag,
    output wire        boss_flag,
    output wire        HP_deduct,
    output wire        boss_fire
);
    // ONLY declarations, no "= 0" here:
    wire reset_enemy_1, reset_enemy_2, reset_enemy_3, reset_enemy_4, reset_enemy_5;
    wire [6:0] random_num_1, random_num_2, random_num_3, random_num_4, random_num_5;
    wire reset_enemy_21, reset_enemy_22, reset_enemy_23, reset_enemy_24, reset_enemy_25;
    wire [6:0] random_num_21, random_num_22, random_num_23, random_num_24, random_num_25;
    
    wire enemy_flag_1, enemy_flag_2, enemy_flag_3, enemy_flag_4, enemy_flag_5;
    wire HP_deduct_1, HP_deduct_2, HP_deduct_3, HP_deduct_4, HP_deduct_5;
    wire enemy_flag_21, enemy_flag_22, enemy_flag_23, enemy_flag_24, enemy_flag_25;
    wire HP_deduct_21, HP_deduct_22, HP_deduct_23, HP_deduct_24, HP_deduct_25;
    wire kill_all;
    wire kill_all2;
    reg  shot_1, shot_2, shot_3, shot_4, shot_5;
    reg  shot_21, shot_22, shot_23, shot_24, shot_25;
    
    
    reg shot_boss;

    
    
    assign enemy_flag = enemy_flag_1 | enemy_flag_2 | enemy_flag_3 | enemy_flag_4 | enemy_flag_5 | enemy_flag_21 | enemy_flag_22 | enemy_flag_23 | enemy_flag_24 | enemy_flag_25;
    assign HP_deduct = HP_deduct_1 | HP_deduct_2 | HP_deduct_3 | HP_deduct_4 | HP_deduct_5 | HP_deduct_21 | HP_deduct_22 | HP_deduct_23 | HP_deduct_24 | HP_deduct_25;

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
    always @* begin
        shot_21=1'b0; shot_22=1'b0; shot_23=1'b0; shot_24=1'b0; shot_25=1'b0;
        if (shot_flag) begin
            if      (enemy_flag_21) shot_21=1'b1;
            else if (enemy_flag_22) shot_22=1'b1;
            else if (enemy_flag_23) shot_23=1'b1;
            else if (enemy_flag_24) shot_24=1'b1;
            else if (enemy_flag_25) shot_25=1'b1;
        end
    end

    always @* begin
        shot_boss=1'b0;
        if (shot_flag) begin
            if      (boss_flag) shot_boss=1'b1;  
            else shot_boss=1'b0;
        end
    end


    
    boss_unit  boss_unit_inst (
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_boss),
    .boss_appear(boss_appear),
    .kill_all(reset_enemy_module),
    .x(x),
    .y(y),
    .boss_flag(boss_flag),
    .boss_fire(boss_fire)
  );

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

    reset_enemy_new2 #(
        .CLK_HZ (6_250_000)
    ) u_reset2 (
        .clk               (clk),
        .reset_enemy_module(reset_enemy_module),
        .kill_all(kill_all2), 
        .level_state(level_state), 
        .pause(pause), 
        .reset_enemy_1     (reset_enemy_21),
        .reset_enemy_2     (reset_enemy_22),
        .reset_enemy_3     (reset_enemy_23),
        .reset_enemy_4     (reset_enemy_24),
        .reset_enemy_5     (reset_enemy_25),
        .random_num_1      (random_num_21),
        .random_num_2      (random_num_22),
        .random_num_3      (random_num_23),
        .random_num_4      (random_num_24),
        .random_num_5      (random_num_25)
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
enemy_unit2 enemy21(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_21),
    .random_num(random_num_21),
    .reset_enemy(reset_enemy_21),
    .kill_all(kill_all2),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_21),
    .HP_deduct(HP_deduct_21)
);

enemy_unit2 enemy22(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_22),
    .random_num(random_num_22),
    .reset_enemy(reset_enemy_22),
    .kill_all(kill_all2),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_22),
    .HP_deduct(HP_deduct_22)
);

enemy_unit2 enemy23(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_23),
    .random_num(random_num_23),
    .reset_enemy(reset_enemy_23),
    .kill_all(kill_all2),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_23),
    .HP_deduct(HP_deduct_23)
);

enemy_unit2 enemy24(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_24),
    .random_num(random_num_24),
    .reset_enemy(reset_enemy_24),
    .kill_all(kill_all2),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_24),
    .HP_deduct(HP_deduct_24)
);

enemy_unit2 enemy25(
    .clk(clk),
    .clk_move(clk_move),
    .shot(shot_25),
    .random_num(random_num_25),
    .reset_enemy(reset_enemy_25),
    .kill_all(kill_all2),
    .x(x),
    .y(y),
    .enemy_flag(enemy_flag_25),
    .HP_deduct(HP_deduct_25)
);
endmodule
`default_nettype wire
