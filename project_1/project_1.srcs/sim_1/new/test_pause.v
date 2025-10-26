`timescale 1ns / 1ps

module test_pause ();

    // --- ?? ---
    // 625 MHz ????? (1 / 625e6) = 1.6 ns
    parameter CLK_PERIOD = 1.6;

    // --- ?? ---
    // DUT (Device Under Test) ???
    reg [1:0] state;
    reg [6:0] x; // ?? x ?? 7 (??????? 68)
    reg [6:0] y; // ?? y ?? 6 (??????? 51)
    reg clk_625m;

    // DUT ???
    wire red_flag;
    wire white_flag;

    // --- ??????? (DUT) ---
    pulse uut (
        .state(state),
        .x(x),
        .y(y),
        .clk_625m(clk_625m),
        .red_flag(red_flag),
        .white_flag(white_flag)
    );

    // --- ????? ---
    initial begin
        clk_625m = 0;
        // forever ???? 0.8 ns ?????? (??? 1.6 ns)
        forever #(CLK_PERIOD / 2) clk_625m = ~clk_625m;
    end

    // --- ???? (Stimulus) ---
    initial begin
        $display("--- Testbench Starting ---");
        $display("Time: %0t: Initializing inputs.", $time);

        // 1. ???
        state = 2'b00;
        x = 0;
        y = 0;
        @(posedge clk_625m); // ????????
        
        // 2. ?? RED FLAG
        $display("Time: %0t: Setting state=2'b10, y=13, x=45 (Red Zone).", $time);
        state = 2'b10;
        x = 45; // (y=13, x ? 44..52 ??)
        y = 13;
        
        // ???????DUT ??? 'if' ????
        @(posedge clk_625m); 
        
        // ????????red_flag <= 1 ??????????
        @(posedge clk_625m); 
        #1; // ???????????????????

        // 3. ?? red_flag
        $display("Time: %0t: Checking red_flag...", $time);
        if (red_flag == 1) begin
            $display("    ...PASS: red_flag is 1.");
        end else begin
            $display("    ...FAIL: red_flag is 0. (Expected 1)");
        end
        $display("    (Current values: red_flag=%b, white_flag=%b)", red_flag, white_flag);

        
        // 4. ?? WHITE FLAG
        @(posedge clk_625m);
        $display("Time: %0t: Setting state=2'b10, y=30, x=41 (White Zone).", $time);
        state = 2'b10;
        x = 41; // (y=30, x ? 40..43 ??)
        y = 30;

        // ???????????????????????
        @(posedge clk_625m); // ?? 1: ??????
        @(posedge clk_625m); // ?? 2: ???????
        #1;

        // 5. ?? white_flag
        $display("Time: %0t: Checking white_flag...", $time);
        if (white_flag == 1) begin
            $display("    ...PASS: white_flag is 1.");
        end else begin
            $display("    ...FAIL: white_flag is 0. (Expected 1)");
        end
        $display("    (Current values: red_flag=%b, white_flag=%b)", red_flag, white_flag);


        // 6. ??
        #10;
        $display("--- Testbench Finished ---");
        $finish;
    end

endmodule