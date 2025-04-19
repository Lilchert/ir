module top (
    input wire clk25,
    input wire [1:0] key,
    output wire [0:0] led,
    output wire [0:0] gpio
);

    reg [31:0] cmd_reg;
    wire rst;
    wire ready;
    wire ir_out;
    wire valid;

    // Коды для Samsung (NEC-формат)
    localparam VOL_UP   = 32'hE0E040BF; // Громкость вверх
    localparam VOL_DOWN = 32'hE0E0C03F; // Громкость вниз

    assign rst = key[0];    // key[0] как сброс
    assign ready = led[0];
    assign gpio[0] = ir_out;

    // Выбор команды
    always @(posedge clk25) begin
        if (rst) cmd_reg <= 32'h0;
        else begin
            if (key[1]) cmd_reg <= VOL_UP;      // key[1] -> громкость вверх
            else if (key[0]) cmd_reg <= VOL_DOWN; // key[0] -> громкость вниз
        end
    end

    // Активация передачи
    assign valid = key[1] || key[0];

    ir_encoder encoder (
        .clk(clk25),
        .rst(rst),
        .cmd(cmd_reg),
        .valid(valid),
        .ready(ready),
        .ir_output(ir_out)
    );
endmodule

