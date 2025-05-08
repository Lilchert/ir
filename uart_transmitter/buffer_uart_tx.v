module buffer_uart_tx #(
	parameter BYTE_MAX = 13
)(
	input wire rst,
	input wire clk,
	input wire byte_ready,
	input wire valid,			// Valid for bytes
	output reg ready,			// Ready to accept new message
	output wire [7:0] data			// Data byte to tx
);

reg [$clog2(BYTE_MAX):0] byte_cnt;
reg transmitting;

reg [7:0] message [0:BYTE_MAX-1];
initial $readmemh("hello_world.txt", message); // Hello world+\r+\n 

reg [7:0] data_reg;
assign data = data_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        byte_cnt <= 0;
        data_reg <= 0;
        ready    <= 1'b1;
    end else begin
        if (valid && ready) begin              // Start new transmission
            byte_cnt <= 1;
            data_reg <= message[0];
            ready    <= 1'b0;
        end else if (byte_ready && !ready) begin             // Continue transmission
            if (byte_cnt < BYTE_MAX-1) begin
                data_reg <= message[byte_cnt];
                byte_cnt <= byte_cnt + 1;
            end else begin                     // End of transmission
                data_reg <= message[byte_cnt];  // Send last byte
                byte_cnt <= 0;
                ready    <= 1'b1;
            end
        end
    end
end

endmodule
