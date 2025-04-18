module tb;
    reg rst = 1;
    reg clk = 0;
    reg valid = 0;
    reg [31:0] cmd = 32'b1111_1011_0000_0100_0000_0111_0000_0111; // Тестовый паттерн
    wire ready;
    wire ir_out;
    
    ir_encoder dut (
        .rst(rst),
        .clk(clk),
        .cmd(cmd),
        .valid(valid),
        .ready(ready),
        .ir_output(ir_out)
    );
    
    always #20 clk = ~clk; // 25 MHz
    
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb);
        
        #100 rst = 0;
        #200 valid = 1;
        wait(ready == 0);
        #10 valid = 0;
        
        #80_000_000 $finish; // 20 мс симуляции
    end
endmodule
