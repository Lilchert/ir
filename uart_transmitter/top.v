module top (
        input wire clk25,
        input wire  [1:0] key,
        output wire [1:0] led,
        output wire uart_debug_txd
);

//localparam BYTE_MAX = 13; // bytes in txt

wire [31:0] baudrate  = 32'd115200;

wire button_state;
wire rst;
assign rst = key[0];

wire ready;
wire [7:0] data = 8'h41; //"A"
wire valid = button_state;

wire tx;

assign led[0] = ready;
assign led[1] = buffer_ready;
assign uart_debug_txd = tx;

wire buffer_valid; //= button_state;
wire buffer_ready;

/*always @(posedge clk25 or posedge rst) begin
	if (rst) begin
		valid    <= 1'b0;
	end else if (buffer_valid) begin
		if (ready) valid <= 1'b1;
		else if (!ready) valid <= 1'b0;
	end
end
*/
debouncer debounce_inst (
                   .clk(clk25),
                   .rst(rst),
                   .button_in(key[1]),
                   .button_pressed(),
                   .button_state(button_state),
                   .button_released()
                );

/*buffer_uart_tx #(
	.BYTE_MAX(BYTE_MAX) 
) buffer (
	.rst(rst),
	.clk(clk25), 
	.byte_ready(ready),
	.valid(buffer_valid),
	.ready(buffer_ready),
	.data(data)
);*/

uart_tx uart (
        .clk(clk25),
        .rst(rst),
        .data(data),
        .baudrate(baudrate),
        .ready(ready),
	.valid(valid),
	.stop_bits(2'd1), // 2 stop bits
	.parity_en(1'b1), // Enable bit parity
	.parity_type(1'b1), // Odd parity
	.tx(tx)
);



endmodule
