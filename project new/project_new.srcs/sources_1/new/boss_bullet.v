`timescale 1ns / 1ps


module boss_bullet(
    input clk,
    input [6:0] x,
    input [6:0] y,
    input boss_fire,
    input frame_begin,
    input BE_collision,
    input [1:0] level_state,
    input [1:0] state,
    output reg boss_bullet_flag

);

    reg fb_0, fb_1;
    reg [1:0] state_sync;
    always @(posedge clk) begin
        fb_0 <= frame_begin;
        fb_1 <= fb_0;
        state_sync <= state;
    end
    wire need_to_pause = (state_sync == 2'b10);
    wire need_to_reset = (state_sync == 2'b11);
    wire fb_rise = fb_0 & ~fb_1;
    integer i,j,k,m;
    reg [4:0] frame_count = 5'd0;
    reg [4:0] frame_count_comparator = 8'd29; // default shooting slowest, change based on difficulty levels
    reg fire = 1'b0;
    reg break;
    
    
    reg [11*14-1:0] bullet_xy_array = 154'b0;
    reg move_toggle = 1'b0;
   
    always @(posedge clk) begin
      if (need_to_reset) begin 
        move_toggle <= 1'b0;
      end
      else if (fb_rise && !need_to_pause) begin 
        move_toggle <= ~move_toggle;
      end
    end
    
    wire move_ce = fb_rise && move_toggle && !need_to_pause;

    
    
    always @(posedge clk) begin
        if (fb_rise && !need_to_pause) begin
            if (frame_count == frame_count_comparator) begin
                frame_count <= 5'd0;
                fire <= 1'b1; 
            end else begin
                frame_count <= frame_count + 5'd1;
            end
        end
        if (need_to_pause || need_to_reset) begin
            fire <= 1'b0;
        end
        if (need_to_reset) begin
            bullet_xy_array <= 154'b0;
        end
        if (fire && boss_fire && !need_to_pause) begin 
            break = 1'b0;
            for (j = 0; j < 11; j = j + 1) begin
                if (!break && (j < 4)) begin
                    if (bullet_xy_array[j*14 +:14] == 14'd0) begin
                        bullet_xy_array[j*14 +:14] <= {x, y};
                        break = 1'b1;
                    end
                end
            end
            fire <= 1'b0;
        end

        // Move once every 2 frames (right by 1 px). Clear when leaving screen.
        if (move_ce) begin
            for (i = 0; i < 11; i = i + 1) begin
               
                    if ((bullet_xy_array[i*14+7 +: 7] <= 7'd0) || bullet_xy_array[i*14 +: 7] >= 7'd63 || bullet_xy_array[i*14 +: 7] <= 7'd0) begin
                        bullet_xy_array[i*14 +: 14] <= 14'd0;  // this should check for x and y 
                    end else begin 
                        bullet_xy_array[i*14+7 +: 7] <= bullet_xy_array[i*14+7 +: 7] - 7'd1; // move left by 1
                    end
                
            end
        end

        // collision handling: clear bullet if collision detected
        if (BE_collision) begin : clear_on_collision
            reg [6:0] bx, by;
            for (k = 0; k < 11; k = k + 1) begin
                bx = bullet_xy_array[k*14+7 +: 7];
                by = bullet_xy_array[k*14 +: 7];
                if (|bullet_xy_array[k*14 +: 14]) begin
                    if (x < 7'd95 && y < 7'd63) begin
                            if ( ((x==bx) || (bx!=0 && x==bx-7'd1)) &&
                                ((y==by) || (by!=0 && y==by-7'd1)) )
                                bullet_xy_array[k*14 +: 14] <= 14'd0;             
                    end
                end
            end
        end
    end
    
        // Draw 2*2 square
    always @(*) begin : draw
        reg [6:0] bx, by;
        boss_bullet_flag = 1'b0;
        
            for (m = 0; m < 11; m = m + 1) begin
                bx = bullet_xy_array[m*14+7 +: 7];
                by = bullet_xy_array[m*14 +: 7];
                if (!boss_bullet_flag && |bullet_xy_array[m*14 +: 14]) begin
                    if (x < 7'd95 && y < 7'd63) begin
                            if ( ((x==bx) || (bx!=0 && x==bx-7'd1)) &&
                                ((y==by) || (by!=0 && y==by-7'd1)) )
                                boss_bullet_flag = 1'b1;             
                    end
                end
            end
    end
endmodule
