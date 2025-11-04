module move_pulse(
    input clk625,
    input [1:0] level_state,
    input pause,
    output reg move_pulse
);



reg [31:0] period = 32'd220000;
reg [31:0] cnt = 0;

always @(*) begin
    case (level_state)
    2'b00: period <= 32'd220000;
    2'b01: period <= 32'd200000;
    2'b10: period <= 32'd180000;
    2'b11: period <= 32'd160000;
    endcase

end

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
