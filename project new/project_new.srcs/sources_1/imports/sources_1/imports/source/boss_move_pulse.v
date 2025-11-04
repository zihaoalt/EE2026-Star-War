module boss_move_pulse(
    input clk625,
    input pause,
    output reg move_pulse
);



reg [31:0] period = 32'd200000;
reg [31:0] cnt = 0;


always @(posedge clk625) begin
    if (!pause) begin
        if (cnt >= period-1 ) begin
            cnt      <= 32'd0;
            move_pulse <= 1; 
        end else begin
            cnt <= cnt + 1;
            move_pulse <= 0;
        end
    end else begin
        cnt <= cnt;
        move_pulse <= 0;
    end
    
    end

endmodule