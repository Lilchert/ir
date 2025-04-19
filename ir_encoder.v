module ir_encoder (
    input wire rst,        // Сброс
    input wire clk,        // 25 MHz
    input wire [31:0] cmd, // Команда для передачи
    input wire valid,      // Сигнал валидности
    output reg ready,      // Готовность
    output reg ir_output   // Выход ИК-сигнала
);

//===============================================
// Параметры состояний
//===============================================
localparam [2:0]
    IDLE        = 3'd0,    // Ожидание команды
    START_MOD   = 3'd1,    // Стартовая модуляция
    START_SPACE = 3'd2,    // Стартовая пауза
    ACTIVE      = 3'd3,    // Активная передача бита
    PAUSE       = 3'd4;    // Пауза между битами

//===============================================
// Параметры временных интервалов
//===============================================
localparam
    CLK_FREQ     = 25_000_000,
    CARRIER_FREQ = 36_000,
    DATA_RATE    = 1200,

    CARRIER_DIV = CLK_FREQ/(CARRIER_FREQ*2), // 347
    DATA_DIV    = CLK_FREQ/(DATA_RATE*2), // 10416
    START_TICKS = CLK_FREQ*218737/50_000_000; // 109368,5 (4,37475ms)

//===============================================
// Генерация тактовых сигналов
//===============================================
reg [15:0] carrier_cnt;
reg carrier_36k;

reg [15:0] data_cnt;
reg carrier_1200;

// Генерация 36 кГц
always @(posedge clk or posedge rst) begin
    if(rst) begin
        carrier_cnt <= 0;
        carrier_36k <= 0;
    end else begin
        if(carrier_cnt >= CARRIER_DIV-1) begin
            carrier_cnt <= 0;
            carrier_36k <= ~carrier_36k;
        end else begin
            carrier_cnt <= carrier_cnt + 1;
        end
    end
end

// Генерация 1200 Гц
always @(posedge clk or posedge rst) begin
    if(rst) begin
        data_cnt <= 0;
        carrier_1200 <= 0;
    end else begin
        if(data_cnt >= DATA_DIV-1) begin
            data_cnt <= 0;
            carrier_1200 <= ~carrier_1200;
        end else begin
            data_cnt <= data_cnt + 1;
        end
    end
end

// Комбинированный сигнал модуляции
wire modulation = carrier_36k & carrier_1200;

//===============================================
// Конечный автомат передачи
//===============================================
reg [31:0] shift_reg;
reg [5:0]  bit_cnt;
reg [23:0] main_cnt;
reg [2:0]  state;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        ready     <= 1'b1;
        ir_output <= 1'b0;
        shift_reg <= 0;
        bit_cnt   <= 0;
        main_cnt  <= 0;
        state     <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                ir_output <= 1'b0;
                if(valid && ready) begin
                    shift_reg <= cmd;
                    ready     <= 1'b0;
                    main_cnt  <= 0;
                    state     <= START_MOD;
                end
            end

            START_MOD: begin
                ir_output <= carrier_36k;
                if(main_cnt == START_TICKS-1) begin
                    main_cnt <= 0;
                    state    <= START_SPACE;
                end else begin
                    main_cnt <= main_cnt + 1;
                end
            end

            START_SPACE: begin
                ir_output <= 1'b0;
                if(main_cnt == START_TICKS-1) begin
                    main_cnt   <= 0;
                    bit_cnt    <= 0;
                    state      <= ACTIVE;
                end else begin
                    main_cnt <= main_cnt + 1;
                end
            end

            ACTIVE: begin
                ir_output <= modulation;
                if(main_cnt == DATA_DIV-1) begin
                    main_cnt <= 0;
                    state    <= PAUSE;
                end else begin
                    main_cnt <= main_cnt + 1;
                end
            end

            PAUSE: begin
                ir_output <= 1'b0;
                if(main_cnt == (shift_reg[0] ? (DATA_DIV*3)-1 : DATA_DIV-1)) begin
                    main_cnt <= 0;
                    shift_reg <= {1'b0, shift_reg[31:1]}; // добавляет 0 слева
                    bit_cnt   <= bit_cnt + 1;
                    if(bit_cnt == 31) begin
                        ready <= 1'b1;
                        state <= IDLE;
                    end else begin
                        state <= ACTIVE;
                    end
                end else begin
                    main_cnt <= main_cnt + 1;
                end
            end
        endcase
    end
end

endmodule                  
