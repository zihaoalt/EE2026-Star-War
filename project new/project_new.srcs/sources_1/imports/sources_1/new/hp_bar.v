`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: hp_bar
// Description: Starship HP system with shield skill (10s cooldown)
//////////////////////////////////////////////////////////////////////////////////

module hp_bar(
    input clk,
    input deduct_HP,
    input [1:0] state,
    input [1:0] level_state,
    input reset,
    input shield_switch,
    output reg [15:0] starship_hp,
    output reg dead_flag,
    output reg shield_active     // Shield status for display
    );

    reg [5:0] HP = 6'd16;
    reg prev_deduct;
    wire hit_pulse = deduct_HP & ~prev_deduct;

    reg [3:0] damage;
    reg [31:0] shield_counter;     // cooldown counter
    reg shield_used;               // track if shield was consumed

    parameter SHIELD_COOLDOWN = 32'd62500000;  // 10s @ 6.25MHz

    // damage based on level
    always @(*) begin
        case(level_state)
            2'b00: damage = 1; 
            2'b01: damage = 2; 
            2'b10: damage = 4; 
            2'b11: damage = 8; 
        endcase    
    end

    always @(posedge clk) begin
        prev_deduct <= deduct_HP;
    end

    // === Shield and HP management ===
always @(posedge clk or posedge reset) begin
        if (reset || state == 2'b00) begin
            HP <= 6'd16;
            dead_flag <= 0;
            shield_active <= 1;
            shield_used <= 0;
            shield_counter <= 0;
        end else if (state != 2'b10) begin
            if (hit_pulse) begin
                if (shield_active && shield_switch) begin
                    // Shield absorbs the hit
                    shield_active <= 0;
                    shield_used <= 1;
                    shield_counter <= 0;
                end else if (HP > 0) begin
                    HP <= HP - damage;
                end
            end
    
            // Dead flag: use original working logic
            if (!(shield_active && shield_switch))
                dead_flag <= (HP == 1 && hit_pulse) || (HP == 0);
    
            // Shield cooldown
            if (shield_used) begin
                if (shield_counter < SHIELD_COOLDOWN)
                    shield_counter <= shield_counter + 1;
                else begin
                    shield_active <= shield_switch;
                    shield_used <= 0;
                    shield_counter <= 0;
                end
            end
        end
    end

    // === HP bar display ===
    always @(*) begin
        case(HP)
            6'd0:  starship_hp = 16'b0;
            6'd1:  starship_hp = 16'b0000000000000001;
            6'd2:  starship_hp = 16'b0000000000000011;
            6'd3:  starship_hp = 16'b0000000000000111;
            6'd4:  starship_hp = 16'b0000000000001111;
            6'd5:  starship_hp = 16'b0000000000011111;
            6'd6:  starship_hp = 16'b0000000000111111;
            6'd7:  starship_hp = 16'b0000000001111111;
            6'd8:  starship_hp = 16'b0000000011111111;
            6'd9:  starship_hp = 16'b0000000111111111;
            6'd10: starship_hp = 16'b0000001111111111;
            6'd11: starship_hp = 16'b0000011111111111;
            6'd12: starship_hp = 16'b0000111111111111;
            6'd13: starship_hp = 16'b0001111111111111;
            6'd14: starship_hp = 16'b0011111111111111;
            6'd15: starship_hp = 16'b0111111111111111;
            6'd16: starship_hp = 16'b1111111111111111;
            default: starship_hp = 16'b1111111111111111;
        endcase
    end
endmodule
