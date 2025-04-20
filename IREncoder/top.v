module top (
	input wire clk25,
	input wire rst,
	input wire [3:0] key,
	output wire [0:0] led,
	output wire [0:0] gpio
);
	
reg [31:0] cmd_reg;

wire ready;
wire ir_out;
reg valid;

wire key_0_pressed, key_1_pressed, key_2_pressed, key_3_pressed;
debouncer debouncer_0 (
    .clk(clk),
    .rst(rst),
    .button_in(key[0]),
    .button_pressed(key_0_pressed),
    .button_state(),
    .button_released()
);


debouncer debouncer_1 (
    .clk(clk),
    .rst(rst),
    .button_in(key[1]),
    .button_pressed(key_1_pressed),
    .button_state(),
    .button_released()  
);

debouncer debouncer_2 (
    .clk(clk),
    .rst(rst),
    .button_in(key[2]),
    .button_pressed(key_2_pressed),
    .button_state(),
    .button_released()  
);


debouncer debouncer_3 (
    .clk(clk),
    .rst(rst),
    .button_in(key[3]),
    .button_pressed(key_3_pressed),
    .button_state(),
    .button_released()  
);

always @(posedge clk25 or posedge rst) begin
	if (rst) begin
		cmd_reg <= 0;
		valid   <= 1'b0;
	end else begin
		if (key_0_pressed && ready) begin
			cmd_reg <= 32'b10011101011000100000011100000111; // Right
			valid   <= 1'b1;
		end
		if (key_1_pressed && ready) begin
			cmd_reg <= 32'b10011111011000000000011100000111; // Up
			valid   <= 1'b1;
		end
		if (key_2_pressed && ready) begin
			cmd_reg <= 32'b10011110011000010000011100000111; // Down
			valid   <= 1'b1;
		end
		if (key_3_pressed && ready) begin
			cmd_reg <= 32'b10011010011001010000011100000111; // Left
			valid   <= 1'b1;
		end else begin
			cmd_reg <= 0;
			valid   <= 1'b0;
		end
	end
end



assign ready = led[0];
assign gpio[0] = ir_out;

		
ir_encoder encoder (
	.clk(clk25),
	.rst(rst),
	.cmd(cmd_reg),
	.valid(valid),
	.ready(ready),
	.ir_output(ir_out)
);

endmodule

