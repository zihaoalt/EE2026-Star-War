`timescale 1ns / 1ps

module test;

    // --- ???? ---
    // 625 MHz ???? = 1.6 ns
    parameter CLK_PERIOD = 1.6; 
    
    // ???????????????
    parameter background = 16'h0000;
    parameter red        = 16'hF904;
    parameter white      = 16'hFFFF;

    // --- ???? ---
    // DUT ??
    reg red_flag;
    reg white_flag;
    reg clk_625m;
    reg starship_flag;
    reg bullet_flag;
    reg enemy_flag;

    // DUT ??
    wire BE_collision;
    wire [15:0] pixel_data;

    // --- ??????? (DUT) ---
    priority_module uut (
        .red_flag(red_flag),
        .white_flag(white_flag),
        .clk_625m(clk_625m),
        .starship_flag(starship_flag),
        .bullet_flag(bullet_flag),
        .enemy_flag(enemy_flag),
        .BE_collision(BE_collision),
        .pixel_data(pixel_data)
    );

    // --- 1. ????? ---
    initial begin
        clk_625m = 0;
        // ?????? 0.8 ns ????????? 1.6 ns ???
        forever #(CLK_PERIOD / 2) clk_625m = ~clk_625m;
    end

    // --- 2. ???? (Stimulus) ---
    initial begin
        $display("--- Testbench Starting ---");
        
        // ???????? 0
        red_flag      = 0;
        white_flag    = 0;
        starship_flag = 0;
        bullet_flag   = 0;
        enemy_flag    = 0;

        // ???????????????
        @(posedge clk_625m);
        @(posedge clk_625m);
        #1; // ????????????
        $display("Time: %0t: Initial state. pixel_data = %h", $time, pixel_data);


        // --- ?? 1: RED FLAG ---
        $display("Time: %0t: TEST 1: Activating red_flag.", $time);
        red_flag = 1;
        
        // ???????????????????????
        // ?? 1: ?? red_flag=1
        @(posedge clk_625m); 
        // ?? 2: pixel_data ????
        @(posedge clk_625m); 
        #1; 

        // ????
        if (pixel_data == red) begin
            $display("    ...PASS: pixel_data is RED (%h)", pixel_data);
        end else begin
            $display("    ...FAIL: pixel_data is %h (Expected RED %h)", pixel_data, red);
        end


        // --- ?? 2: WHITE FLAG ---
        $display("Time: %0t: TEST 2: Deactivating red_flag, Activating white_flag.", $time);
        red_flag   = 0; // ???? red?????????
        white_flag = 1;
        
        @(posedge clk_625m); // ?? 1: ??
        @(posedge clk_625m); // ?? 2: ??
        #1;

        // ????
        if (pixel_data == white) begin
            $display("    ...PASS: pixel_data is WHITE (%h)", pixel_data);
        end else begin
            $display("    ...FAIL: pixel_data is %h (Expected WHITE %h)", pixel_data, white);
        end
        

        // --- ?? 3: ??? (Red > White) ---
        $display("Time: %0t: TEST 3: Activating BOTH red_flag and white_flag.", $time);
        red_flag   = 1; // ?? red
        white_flag = 1; // ?? white
        
        @(posedge clk_625m); // ?? 1
        @(posedge clk_625m); // ?? 2
        #1;

        // ????
        if (pixel_data == red) begin
            $display("    ...PASS: pixel_data is RED (%h). Priority is correct.", pixel_data);
        end else begin
            $display("    ...FAIL: pixel_data is %h (Expected RED %h). Priority is WRONG.", pixel_data, red);
        end


        // --- ?? ---
        #10;
        $display("--- Testbench Finished ---");
        $finish;
    end

endmodule