`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/18 16:22:50
// Design Name: 
// Module Name: bullet_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bullet_module (
    input clk,
    input [6:0] x,
    input [6:0] y,
    input starship_head_flag,
    input frame_begin,
    input starship_skill, // SW1
    input BE_collision,
    input [1:0] level_state,
    output reg bullet_flag
);
    localparam max_bullets_normal = 4;
    localparam max_bullets_skill = 7;

    reg fb_d;
    always @(posedge clk) begin
        fb_d <= frame_begin;
    end
    wire fb_rise = frame_begin & ~fb_d;  // only one clk cycle of frame_begin synced in clk domain
    integer i,j,k,m;
    reg [4:0] frame_count = 5'd0;
    reg [4:0] frame_count_comparator = 5'd29; // default shooting slowest, change based on difficulty levels
    reg fire = 1'b0;
    reg break;

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
            2'b00: frame_count_comparator <= 5'd29;
            2'b01: frame_count_comparator <= 5'd24;
            2'b10: frame_count_comparator <= 5'd19;
            2'b11: frame_count_comparator <= 5'd14;
            default: frame_count_comparator <= 5'd29;
        endcase
    end

    always @(posedge clk) begin
        if (fb_rise) begin
            if (frame_count == frame_count_comparator) begin
                frame_count <= 5'd0;
                fire <= 1'b1; 
            end else begin
                frame_count <= frame_count + 5'd1;
            end
        end

        if (fire && starship_head_flag) begin 
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
        if (fb_rise) begin
            for (i = 0; i < max_bullets_skill; i = i + 1) begin
                if (i < max_bullets)  begin
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
        end

        // collision handling: clear bullet if collision detected
        if (BE_collision) begin
            for (k = 0; k < max_bullets_skill; k = k + 1) begin
                if (k < max_bullets) begin
                    if (|bullet_xy_array[k*42+14 +: 14] && bullet_xy_array[k*42+14 +: 14] == {x, y}) begin
                        bullet_xy_array[k*42+14 +: 14] <= 14'd0;
                    end
                    if (|bullet_xy_array[k*42 +: 14] && bullet_xy_array[k*42 +: 14] == {x, y}) begin
                        bullet_xy_array[k*42 +: 14] <= 14'd0;
                    end
                    if (|bullet_xy_array[k*42 +28 +: 14] && bullet_xy_array[k*42 +28 +: 14] == {x, y}) begin
                        bullet_xy_array[k*42 +28 +: 14] <= 14'd0;
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
//        end else begin
//            for (m = 0; m < 7; m = m + 1) begin
//                bx = bullet_xy_array[m*42+14+7 +: 7];
//                by = bullet_xy_array[m*42+14 +: 7];
//                if (!bullet_flag && |bullet_xy_array[m*42+14 +: 14]) begin
//                    if (x < 7'd95 && y < 7'd63) begin
//                            if ( ((x==bx) || (bx!=0 && x==bx-7'd1)) &&
//                                ((y==by) || (by!=0 && y==by-7'd1)) )
//                                bullet_flag = 1'b1;             
//                    end
//                end
//            end
//        end

    end
endmodule