module top (
        input wire clk25,
	input wire uart_debug_rxd,
	input wire [0:0] key,
        output wire [2:0] led
);

wire [31:0] baudrate  = 32'd115200;

wire rst;
assign rst = key[0];
reg [7:0] rx_data;

uart_rx uart_main (
    .rst            (rst),
    .clk            (clk25),
    .rx             (uart_debug_rxd),
    .baudrate       (baudrate),
    .valid          (1'b1),
    .stop_bits      (2'd0),
    .parity_en      (1'b1),
    .parity_type    (1'b0),
    .parity_valid   (led[0]),
    .ready          (led[1]),
    .rx_data_output (rx_data)
);


endmodule
