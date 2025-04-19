module top (
	input wire clk25,
	input wire [1:0] key,
	output wire [0:0] led,
	output wire [0:0] gpio
);
	
	
reg [31:0] cmd_reg = 32'b1111_1011_0000_0100_0000_0111_0000_0111;

wire rst;
wire ready;
wire ir_out;
wire valid;

assign valid = key[1];
assign rst = key[0];
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

