`timescale 1ns / 1ps

module tb_buffer_uart_tx();

// Parameters
parameter BYTE_MAX = 13;
parameter CLK_PERIOD = 10;  // 10 ns = 100 MHz

// Testbench Variables
reg rst;
reg clk;
reg valid;
wire ready;
wire [7:0] data;

// Instantiate DUT
buffer_uart_tx #(
    .BYTE_MAX(BYTE_MAX)
) dut (
    .rst(rst),
    .clk(clk),
    .valid(valid),
    .ready(ready),
    .data(data)
);

// Clock Generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test Stimulus
initial begin
    // Initialize inputs
    rst = 1;
    valid = 0;
    
    // Apply reset
    #20;
    rst = 0;
    
    // Test 1: Send single message
    @(posedge clk);
    valid = 1;
    wait(ready == 0);  // Wait until transmission starts
    @(posedge clk);
    valid = 0;
    
    // Wait until transmission completes
    wait(ready == 1);
    #100;
    
    // Test 2: Send two messages back-to-back
    @(posedge clk);
    valid = 1;
    wait(ready == 0);
    @(posedge clk);
    valid = 1;  // Keep valid high to test immediate next transmission
    
    // Wait until first transmission completes
    wait(ready == 1);
    #10;
    
    // Second transmission should start immediately
    wait(ready == 0);
    
    // Wait until second transmission completes
    wait(ready == 1);
    #100;
    
    // Test 3: Try to send when not ready
    @(posedge clk);
    valid = 1;
    #10;
    valid = 0;  // Pulse valid for one clock cycle
    wait(ready == 0);
    @(posedge clk);
    valid = 1;  // Try to start new transmission while busy
    
    #100;
    valid = 0;
    
    // Wait until all transmissions complete
    wait(ready == 1);
    #100;
    
    $display("All tests completed");
    $finish;
end

// Monitoring
initial begin
    $timeformat(-9, 0, " ns", 6);
    $monitor("At time %t: valid=%b, ready=%b, data=%h (ASCII: %c)", 
             $time, valid, ready, data, data);
end

endmodule
