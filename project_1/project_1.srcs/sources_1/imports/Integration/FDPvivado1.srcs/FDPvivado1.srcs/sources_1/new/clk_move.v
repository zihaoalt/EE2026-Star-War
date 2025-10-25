module clk_div_n_hz (
    input  wire frame_begin,   
    output reg  clk_move = 1'b0    // 64 Hz Êä³öÊ±ÖÓ
);
parameter period = 1;
reg [2:0] cnt;

always @(posedge frame_begin) begin
        if (cnt >= period ) begin
            cnt      <= 32'd0;
            clk_move <= ~clk_move; 
        end else begin
            cnt <= cnt + 1;
        end
    end


endmodule
