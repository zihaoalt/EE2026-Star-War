`timescale 1ns / 1ps

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 1. ????????
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
module tb_Start;

    // --- Testbench ?? ---
    reg btnR;
    reg btnL;
    reg [12:0] pixel_index;
    reg [1:0] state;
    reg frame_begin;
    reg sample_pixel;
    reg clk_625m;

    wire [15:0] pixel_data;
    wire finish;

    // ?????????? (DUT)
    Start dut (
        .btnR(btnR),
        .btnL(btnL),
        .pixel_index(pixel_index),
        .state(state),
        .frame_begin(frame_begin),
        .sample_pixel(sample_pixel),
        .clk_625m(clk_625m),
        .pixel_data(pixel_data),
        .finish(finish)
    );

    // --- ???? ---
    // (?? 10ns ???? 100MHz?????)
    parameter CLK_PERIOD = 10;
    initial begin
        clk_625m = 0;
        forever #(CLK_PERIOD / 2) clk_625m = ~clk_625m;
    end// --- 
            // --- ????????? (Stimulus) - ? Page ???
            // --- 
            initial begin
                $display("--- Testbench Started (? Page ????) ---");
                // ?????
                btnR = 0;
                btnL = 0;
                state = 2'b00; // ?? state ?? 'start' ??
                frame_begin = 0;
                sample_pixel = 0;
        
                #(CLK_PERIOD * 5); // ?? 5 ????????
        
                // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
                // +++ ????? $monitor ???"?" page ?? +++
                // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
                // ??? $time ??? dut.page ???????
                $monitor("T=%0t: [????] page ?????: %d", $time, dut.page);
                // +++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        
                // --- ?? 0: ?????? ---
                $display("T=%0t: ?? 0: ???? page ?...", $time);
                if (dut.page != 3'd1) begin
                    $error("FAIL: ?? page ???? 1. ???: %d", dut.page);
                end else begin
                    $display("PASS: ?? page ??? 1.");
                end
                #(CLK_PERIOD * 2);
        
                // --- ?? 1: ?? btnL (page 1 -> 2) ---
                $display("T=%0t: ?? 1: ?? btnL (1 -> 2)...", $time);
                @(negedge clk_625m); // ??????????
                btnL = 1;
                @(negedge clk_625m); // ??????
                btnL = 0;
                @(posedge clk_625m); // ?? FSM ????????
                
                // ... (????? PASS/FAIL ??) ...
        
                // ?? PASS/FAIL ????????? $monitor ??????
                // ??????? page ?????
                
                #(CLK_PERIOD * 100); // ????????
        
                $display("--- Testbench Finished ---");
                $stop;
            end

    // --- ?????? ---
    // (???? VGA ????????????)
    initial begin
        pixel_index = 0;
        forever #5 pixel_index = pixel_index + 1; // ????
    end

    // --- 
    // --- ????????? (Stimulus) - ? Page ???
    // --- 
    initial begin
        $display("--- Testbench Started (? Page ????) ---");
        // ?????
        btnR = 0;
        btnL = 0;
        state = 2'b00; // ?? state ?? 'start' ??
        frame_begin = 0;
        sample_pixel = 0;

        #(CLK_PERIOD * 5); // ?? 5 ????????

        // --- ?? 0: ?????? ---
        $display("T=%0t: ?? 0: ???? page ?...", $time);
        if (dut.page != 3'd1) begin
            $error("FAIL: ?? page ???? 1. ???: %d", dut.page);
        end else begin
            $display("PASS: ?? page ??? 1.");
        end
        #(CLK_PERIOD * 2);

        // --- ?? 1: ?? btnL (page 1 -> 2) ---
        $display("T=%0t: ?? 1: ?? btnL (1 -> 2)...", $time);
        @(negedge clk_625m); // ??????????
        btnL = 1;
        @(negedge clk_625m); // ??????
        btnL = 0;
        @(posedge clk_625m); // ?? FSM ????????
        
        if (dut.page != 3'd2) begin
            $error("FAIL: page ??? 1 ??? 2. ???: %d", dut.page);
        end else begin
            $display("PASS: page ????? 2.");
        end
        #(CLK_PERIOD * 5); // ????

        // --- ?? 2: ?? btnL (page 2 -> 3) ---
        $display("T=%0t: ?? 2: ?? btnL (2 -> 3)...", $time);
        @(negedge clk_625m); btnL = 1;
        @(negedge clk_625m); btnL = 0;
        @(posedge clk_625m); 
        
        if (dut.page != 3'd3) begin
            $error("FAIL: page ??? 2 ??? 3. ???: %d", dut.page);
        end else begin
            $display("PASS: page ????? 3.");
        end
        #(CLK_PERIOD * 5);

        // --- ?? 3: ?? btnL (page 3 -> 4) ---
        $display("T=%0t: ?? 3: ?? btnL (3 -> 4)...", $time);
        @(negedge clk_625m); btnL = 1;
        @(negedge clk_625m); btnL = 0;
        @(posedge clk_625m); 
        
        if (dut.page != 3'd4) begin
            $error("FAIL: page ??? 3 ??? 4. ???: %d", dut.page);
        end else begin
            $display("PASS: page ????? 4.");
        end
        #(CLK_PERIOD * 5);

        // --- ?? 4: ?? btnL (page 4 -> 5) ---
        $display("T=%0t: ?? 4: ?? btnL (4 -> 5)...", $time);
        @(negedge clk_625m); btnL = 1;
        @(negedge clk_625m); btnL = 0;
        @(posedge clk_625m); 
        
        if (dut.page != 3'd5) begin
            $error("FAIL: page ??? 4 ??? 5. ???: %d", dut.page);
        end else begin
            $display("PASS: page ????? 5.");
        end
        #(CLK_PERIOD * 5);

        // --- ?? 5: ?? btnL (page 5 -> 1) ---
        $display("T=%0t: ?? 5: ?? btnL (5 -> 1)...", $time);
        @(negedge clk_625m); btnL = 1;
        @(negedge clk_625m); btnL = 0;
        @(posedge clk_625m); 
        
        if (dut.page != 3'd1) begin
            $error("FAIL: page ??? 5 ??? 1. ???: %d", dut.page);
        end else begin
            $display("PASS: page ????? 1.");
        end
        #(CLK_PERIOD * 5);
        
        // --- ?? 6: ?? btnR (? page 1, ?????) ---
        $display("T=%0t: ?? 6: ?? btnR (? page 1, ????)...", $time);
        @(negedge clk_625m); btnR = 1;
        @(negedge clk_625m); btnR = 0;
        @(posedge clk_625m); 
        
        if (dut.page != 3'd1) begin
            $error("FAIL: page ? 1 ?? btnR ???. ???: %d", dut.page);
        end else begin
            $display("PASS: page ??? 1.");
        end
        #(CLK_PERIOD * 5);

        // --- ?? 7: ?? btnL (1 -> 2), ?? btnR (2 -> 1) ---
        $display("T=%0t: ?? 7a: ?? btnL (1 -> 2)...", $time);
        @(negedge clk_625m); btnL = 1;
        @(negedge clk_625m); btnL = 0;
        @(posedge clk_625m); 
        if (dut.page != 3'd2) $error("FAIL: page ????? 2.");

        $display("T=%0t: ?? 7b: ?? btnR (2 -> 1)...", $time);
        @(negedge clk_625m); btnR = 1;
        @(negedge clk_625m); btnR = 0;
        @(posedge clk_625m); 
        
        if (dut.page != 3'd1) begin
            $error("FAIL: page ??? 2 ??? 1. ???: %d", dut.page);
        end else begin
            $display("PASS: page ??? btnR ??? 1.");
        end
        #(CLK_PERIOD * 5);

        $display("--- Testbench Finished ---");
        $stop;
    end

endmodule

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// 2. ?? Start ????? "??" ??
// (???????????????)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
