module top (
	input wire clk25,
	input wire [3:0] key,
	output wire [0:0] led,
	output wire [0:0] gpio
);
	
reg [31:0] cmd_reg;
wire rst = 0;

wire ready;
wire ir_out;
reg valid;

wire [3:0] button_state;

genvar i;
generate
	for (i=0; i<4; i=i+1) begin: debouncers
		debouncer debounce_inst (
		   .clk(clk25),
		   .rst(rst),
		   .button_in(key[i]),
		   .button_pressed(),
		   .button_state(button_state[i]),
		   .button_released()
	   	);
	end
endgenerate
	
always @(posedge clk25 or posedge rst) begin
	if (rst) begin
		cmd_reg <= 0;
		valid   <= 1'b0;
	end else begin
		valid   <= 1'b0;
		if (button_state[0]) begin
			cmd_reg      <= 32'b10011101011000100000011100000111; // Right
			valid        <= 1'b1;
			button_state <= 0;
		end
		else if (button_state[1]) begin
			cmd_reg <= 32'b10011111011000000000011100000111; // Up
			valid   <= 1'b1;
			button_state <= 0;
		end
		else if (button_state[2]) begin
			cmd_reg <= 32'b10011110011000010000011100000111; // Down
			valid   <= 1'b1;
			button_state <= 0;
		end
		else if (button_state[3]) begin
			cmd_reg <= 32'b10011010011001010000011100000111; // Left
			valid   <= 1'b1;
			button_state <= 0;
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

