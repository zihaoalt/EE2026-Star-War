`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Mat
// Module Name: starship_design
// Description: Starship pixel layout with circular blue shield ring (radius 6)
//////////////////////////////////////////////////////////////////////////////////

module starship_design(
    input clk,
    input [6:0] anchor_x,
    input [6:0] anchor_y,
    input [6:0] x,
    input [6:0] y,
    input shield_active,      // from hp_bar
    output reg starship_flag,
    output reg starship_bullet_flag,
    output reg shield_flag    // blue ring pixels
);
    integer dx, dy, dist2;
    parameter integer SHIELD_RADIUS = 6;
always @(*) begin
    starship_flag = 0;
    starship_bullet_flag = 0;
    shield_flag = 0;

    // --- Bullet pixel ---
    if ((x == anchor_x + 2) && (y == anchor_y))
        starship_bullet_flag = 1;

    // --- Starship body ---
    if ((x == anchor_x + 4) && ((y == anchor_y - 3) || (y == anchor_y + 3)))
        starship_flag = 1;
    else if ((x == anchor_x + 3) && ((y == anchor_y - 2) || (y == anchor_y + 2)))
        starship_flag = 1;
    else if ((x == anchor_x + 2) && ((y > anchor_y - 3) && (y < anchor_y + 3)))
        starship_flag = 1;
    else if ((x == anchor_x + 1) && (((y > anchor_y - 4) && (y < anchor_y + 4)) && (y != anchor_y - 2) && (y != anchor_y + 2)))
        starship_flag = 1;
    else if ((x == anchor_x) && ((y > anchor_y - 4) && (y < anchor_y + 4)))
        starship_flag = 1;
    else if ((x == anchor_x - 1) && ((y > anchor_y - 3) && (y < anchor_y + 3)))
        starship_flag = 1;
    else if ((x == anchor_x - 2) && ((y == anchor_y - 3) || (y == anchor_y + 3)))
        starship_flag = 1;
    else if ((x == anchor_x - 3) && ((y == anchor_y - 2) || (y == anchor_y + 2) || (y == anchor_y - 1) || (y == anchor_y + 1)))
        starship_flag = 1;

    // --- Shield ring (circular, 1-pixel thick, radius 6) ---
    if (shield_active) begin
        dx = x - anchor_x;
        dy = y - anchor_y;
        dist2 = dx*dx + dy*dy;

        // Full circle 1-pixel thick ring
        if (dist2 >= (SHIELD_RADIUS-1)*(SHIELD_RADIUS-1) && dist2 <= SHIELD_RADIUS*SHIELD_RADIUS)
            shield_flag = 1;  // priority_module will color this light blue
    end
end

endmodule
