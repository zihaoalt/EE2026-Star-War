`timescale 1ns / 1ps



module bullet_module (
    input clk,
    input [6:0] x,
    input [6:0] y,
    input starship_head_flag,
    input frame_begin,
    input starship_skill_en, // SW1
    input BE_collision,
    input [1:0] level_state,
    input [1:0] state,
    output reg [24:0] CD = 25'd0,
    output reg bullet_flag

);
    localparam max_bullets_normal = 4;
    localparam max_bullets_skill = 7;

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
    reg [5:0] frame_count = 6'd0;
    reg [5:0] frame_count_comparator = 6'd29; // default shooting slowest, change based on difficulty levels
    reg fire = 1'b0;
    reg break;
    reg [24:0] skill_counter;
    reg starship_skill;
    
    always @(posedge clk) begin
        if (need_to_reset) begin
            CD <= 25'd0;
            starship_skill <= 1'b0;
        end else if (!need_to_pause) begin
            if (starship_skill) begin
                if (CD != 25'd0) begin
                    CD <= CD - 25'd1;
                end else begin
                    starship_skill <= 1'b0;
                end
            end else begin
                if (CD == 25'd31249999) begin
                    if (starship_skill_en) begin
                        starship_skill <= 1'b1;
                    end
                end else begin
                    CD <= CD + 25'd1;
                end
            end
        end
    end

    // bullet corrdinates: [x(7),y(7)] per bullet
    // bullet store should be upper middle and lower if starship_skill is enabled.
    reg  [25 * 14 - 1 :0] bullet_xy_array = 0;
    
    wire [3:0] max_bullets =
        (level_state == 2'b00) ? 4'd4:
        (level_state == 2'b01) ? 4'd5:
        (level_state == 2'b10) ? 4'd6:
                                 4'd7;

    
    always @(posedge clk) begin
        case(level_state)
            2'b00: frame_count_comparator <= 6'd44;
            2'b01: frame_count_comparator <= 6'd40;
            2'b10: frame_count_comparator <= 6'd36;
            2'b11: frame_count_comparator <= 6'd32;
            default: frame_count_comparator <= 6'd32;
        endcase
    end

    always @(posedge clk) begin
        if (fb_rise && !need_to_pause) begin
            if (frame_count == frame_count_comparator) begin
                frame_count <= 6'd0;
                fire <= 1'b1; 
            end else begin
                frame_count <= frame_count + 6'd1;
            end
        end
        if (need_to_pause || need_to_reset) begin
            fire <= 1'b0;
        end
        if (need_to_reset) begin
            bullet_xy_array <= 350'b0;
        end
        if (fire && starship_head_flag && !need_to_pause) begin 
            break = 1'b0;
            for (j = 0; j < max_bullets_skill; j = j + 1) begin
                if (!break && (j < max_bullets)) begin
                    if ( starship_skill &&
                        (bullet_xy_array[j*42 +:14] == 14'd0) &&
                        (bullet_xy_array[j*42 + 14 +:14] == 14'd0) &&
                        (bullet_xy_array[j*42 + 28 +:14] == 14'd0) ) begin
                            bullet_xy_array[j*42 +:14] <= {x, y};      // bottom-right
                            bullet_xy_array[j*42 +14 +:14] <= {x, y};      // straight-right
                            bullet_xy_array[j*42 +28 +:14] <= {x, y};      // upper-right
                            break = 1'b1;
                    end else if (bullet_xy_array[j*42 + 14 +:14] == 14'd0) begin
                        bullet_xy_array[j*42 + 14 +:14] <= {x, y};
                        break = 1'b1;
                    end
                end
            end
            fire <= 1'b0;
        end

        // Move once per frame (right by 1 px). Clear when leaving screen.
        if (fb_rise && !need_to_pause) begin
            for (i = 0; i < max_bullets_skill; i = i + 1) begin
               
                    if ((bullet_xy_array[i*42+14+7 +: 7] >= 7'd95) || bullet_xy_array[i*42+14 +: 7] >= 7'd63 || bullet_xy_array[i*42+14 +: 7] <= 7'd0) begin
                        bullet_xy_array[i*42+14 +: 14] <= 14'd0;  // this should check for x and y 
                    end else begin 
                        bullet_xy_array[i*42+14+7 +: 7] <= bullet_xy_array[i*42+14+7 +: 7] + 7'd1; // move right by 1
                    end



                    if ((bullet_xy_array[i*42 +7 +: 7] >= 7'd95) || bullet_xy_array[i*42 +: 7] >= 7'd63 || bullet_xy_array[i*42 +: 7] <= 7'd0) begin // bottom bullet
                        bullet_xy_array[i*42 +: 14] <= 14'd0;
                    end else begin 
                        bullet_xy_array[i*42 +7 +: 7] <= bullet_xy_array[i*42 +7 +: 7] + 7'd1;
                        bullet_xy_array[i*42 +: 7] <= bullet_xy_array[i*42 +: 7] - 7'd1;
                    end
                    if ((bullet_xy_array[i*42 +28+7 +: 7] >= 7'd95) || bullet_xy_array[i*42 +28 +: 7] >= 7'd63 || bullet_xy_array[i*42 +28 +: 7] <= 7'd0) begin // upper bullet
                        bullet_xy_array[i*42 +28 +: 14] <= 14'd0;
                    end else begin 
                        bullet_xy_array[i*42 +28+7 +: 7] <= bullet_xy_array[i*42 +28+7 +: 7] + 7'd1;
                        bullet_xy_array[i*42 +28 +: 7] <= bullet_xy_array[i*42 +28 +: 7] + 7'd1;
                    end

                
            end
        end

        // collision handling: clear bullet if collision detected
        if (BE_collision) begin : clear_on_collision
            reg [6:0] bx, by;
            for (k = 0; k < 25; k = k + 1) begin
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
        bullet_flag = 1'b0;
        
            for (m = 0; m < 25; m = m + 1) begin
                bx = bullet_xy_array[m*14+7 +: 7];
                by = bullet_xy_array[m*14 +: 7];
                if (!bullet_flag && |bullet_xy_array[m*14 +: 14]) begin
                    if (x < 7'd95 && y < 7'd63) begin
                            if ( ((x==bx) || (bx!=0 && x==bx-7'd1)) &&
                                ((y==by) || (by!=0 && y==by-7'd1)) )
                                bullet_flag = 1'b1;             
                    end
                end
            end
    end
endmodule