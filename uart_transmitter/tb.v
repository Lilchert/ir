`timescale 1ns / 1ps

module uart_tx_tb;

    // Testbench parameters
    parameter BYTE_MAX = 13;
    parameter CLK_PERIOD = 40; // 25 MHz clock (40 ns period)
    parameter BAUD_RATE = 115200;
    parameter BIT_PERIOD = 1000000000/BAUD_RATE; // in ns
    
    // Signals
    reg rst;
    reg clk;
    
    // Buffer UART TX signals
    reg byte_ready;
    reg valid;
    wire ready;
    wire [7:0] data;
    
    // UART TX signals
    reg [31:0] baudrate;
    reg [1:0] stop_bits;
    reg parity_en;
    reg parity_type;
    wire uart_ready;
    wire tx;
    
    // Testbench variables
    integer i;
    reg [7:0] received_data;
    integer errors;
    integer test_case;
    integer byte_index;
    
    // Instantiate modules
    buffer_uart_tx #(.BYTE_MAX(BYTE_MAX)) u_buffer (
        .rst(rst),
        .clk(clk),
        .byte_ready(byte_ready),
        .valid(valid),
        .ready(ready),
        .data(data)
    );
    
    uart_tx u_uart (
        .rst(rst),
        .clk(clk),
        .data(data),
        .baudrate(baudrate),
        .valid(ready && (byte_index < BYTE_MAX)), // Only validate when buffer has data
        .stop_bits(stop_bits),
        .parity_en(parity_en),
        .parity_type(parity_type),
        .ready(uart_ready),
        .tx(tx)
    );
    
    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end
    
    // UART receiver task
    task uart_receive;
        output [7:0] rx_byte;
        begin
            // Wait for start bit
            @(negedge tx); // Wait for falling edge
            #(BIT_PERIOD*1.5); // Sample in middle of first data bit
            
            // Receive data bits
            for (i = 0; i < 8; i = i + 1) begin
                rx_byte[i] = tx;
                #(BIT_PERIOD);
            end
            
            // Check parity if enabled
            if (parity_en) begin
                #(BIT_PERIOD); // Skip parity
            end
            
            // Wait for stop bit(s)
            if (stop_bits == 0) begin
                #(BIT_PERIOD); // 1 stop bit
            end else if (stop_bits == 1) begin
                #(2*BIT_PERIOD); // 2 stop bits
            end else begin
                #(1.5*BIT_PERIOD); // 1.5 stop bits
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize
        rst = 1;
        valid = 0;
        byte_ready = 0;
        baudrate = BAUD_RATE;
        stop_bits = 0;
        parity_en = 0;
        parity_type = 0;
        errors = 0;
        test_case = 0;
        byte_index = 0;
        
        // Create VCD file for waveform viewing
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);
        
        // Reset
        #(CLK_PERIOD*10);
        rst = 0;
        #(CLK_PERIOD*10);
        
        // Test Case 1: Basic transmission
        test_case = 1;
        $display("Test Case %0d: Basic transmission", test_case);
        
        // Trigger transmission
        valid = 1;
        @(posedge clk);
        valid = 0;
        
        // Process all bytes
        while (byte_index < BYTE_MAX) begin
            // Wait for UART to finish previous transmission
            wait(uart_ready == 1);
            
            // Signal byte ready to buffer (pulse for one clock cycle)
            @(posedge clk);
            byte_ready = 1;
            @(posedge clk);
            byte_ready = 0;
            
            // Wait for UART to start transmission
            wait(uart_ready == 0);
            
            // Receive the byte
            uart_receive(received_data);
            $display("[%0t] Received byte %0d: %h ('%c')", 
                    $time, byte_index+1, received_data, received_data);
            
            byte_index = byte_index + 1;
        end
        
        #(CLK_PERIOD*100);
        
        $display("\nTestbench completed with %0d errors", errors);
        $finish;
    end
    
    // Monitor
    initial begin
        forever begin
            $display("Time %0t: State=%d, TX=%b, Data=%h, BufReady=%b, UartReady=%b, ByteIndex=%0d", 
                    $time, u_uart.state, tx, data, ready, uart_ready, byte_index);
            #(CLK_PERIOD);
        end
    end
    
endmodule
