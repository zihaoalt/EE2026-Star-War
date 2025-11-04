module starship(
    input clk,
    input [6:0] pixel_x,
    input [6:0] pixel_y,
    input reset,
    input up,
    input down,
    input [1:0] state,
    input shield_active, // 🟦 NEW: from hp_bar
    output starship_flag,
    output starship_bullet_flag,
    output shield_flag    // 🟦 NEW: to display blue ring
    );
    
reg [6:0] centre_x;
reg [6:0] centre_y;    
wire starship_flag_store; 
wire starship_bullet_flag_store;
wire shield_flag_store;

// Pass shield_active into design for visual ring
starship_design C0(
    .clk(clk),
    .anchor_x(centre_x),
    .anchor_y(centre_y),
    .x(pixel_x),
    .y(pixel_y),
    .starship_flag(starship_flag_store),
    .starship_bullet_flag(starship_bullet_flag_store),
    .shield_active(shield_active),
    .shield_flag(shield_flag_store)
); 

// Movement direction encoding
reg [1:0] move_dir; 
parameter NONE = 2'b00, UP = 2'b01, DOWN = 2'b10;

// Direction update
always @(posedge clk or posedge reset) begin
    if (reset)
        move_dir <= NONE;
    else if (up)
        move_dir <= UP;
    else if (down)
        move_dir <= DOWN;
    else
        move_dir <= NONE; 
end     

// 60Hz movement control
reg [16:0] move_counter; 
wire move_tick = (move_counter == 0);

always @(posedge clk or posedge reset) begin
    if (reset)
        move_counter <= 0;
    else if (move_counter >= 104166) // for 60Hz at 6.25MHz
        move_counter <= 0;
    else
        move_counter <= move_counter + 1;
end

// Starship position update
always @(posedge clk or posedge reset) begin
    if (reset) begin
        centre_x <= 5;
        centre_y <= 32;
    end else if (state == 2'b10) begin // pause
        centre_x <= centre_x;
        centre_y <= centre_y;
    end else if (move_tick) begin
        case (move_dir)
            UP:   if (centre_y > 5)  centre_y <= centre_y - 1;
            DOWN: if (centre_y < 57) centre_y <= centre_y + 1;
            default: ;
        endcase
    end
end

assign starship_flag = starship_flag_store;
assign starship_bullet_flag = starship_bullet_flag_store;
assign shield_flag = shield_flag_store;

endmodule