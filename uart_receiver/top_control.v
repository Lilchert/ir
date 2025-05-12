module top (
        input wire clk25,
	input wire uart_debug_rxd,
	input wire [0:0] key,
        output reg [3:0] led,
	output wire [0:0] gpio
);

wire [31:0] baudrate  = 32'd115200;
wire [1:0] stop_bits  = 2'd0;
wire parity_valid;

wire rst;
assign rst = key[0];

reg [7:0] rx_data;
wire rx_ready;
reg [31:0] cmd_reg;
reg ir_valid;
wire ir_ready;
wire ir_out;

always @(posedge clk25 or posedge rst) begin
    if (rst) begin
        cmd_reg  <= 32'd0;
        ir_valid <= 1'b0;
	led[3:0] <= 4'b0000;
    end else begin 
            case (rx_data)
		    8'h38: begin
			    cmd_reg <= 32'b10011111011000000000011100000111; // Up
			    led[3:0] <= 4'b0001;
		    end
		    8'h32: begin
			    cmd_reg <= 32'b10011110011000010000011100000111; // Down
			    led[3:0] <= 4'b0010;
		    end
		    8'h36: begin
			    cmd_reg <= 32'b10011101011000100000011100000111; // Right
			    led[3:0] <= 4'b0100;
		    end
		    8'h34: begin
			    cmd_reg <= 32'b10011010011001010000011100000111; // Left
			    led[3:0] <= 4'b1000;
		    end
		    default: begin
			    cmd_reg <= 32'd0;
			    led[3:0] <= 4'b0000;
		    end
            endcase
            ir_valid <= 1'b1; 
    end
end

assign gpio[0] = ir_out;

ir_encoder encoder (
        .clk(clk25),
        .rst(rst),
        .cmd(cmd_reg),
        .valid(ir_valid),
        .ready(ir_ready),
        .ir_output(ir_out)
);


uart_rx uart_main (
    .rst(rst),
    .clk(clk25),
    .rx(uart_debug_rxd),
    .baudrate(baudrate),
    .valid(1'b1),
    .stop_bits(stop_bits),
    .parity_en(1'b1),
    .parity_type(1'b0),
    .parity_valid(parity_valid),
    .ready(rx_ready),
    .rx_data(rx_data)
);


endmodule
