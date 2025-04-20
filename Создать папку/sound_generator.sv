module sound_generator (
    input wire clk,
    input wire reset,
    input wire key1, // Ключ 1 
    output reg beep,
    output reg ready,
    output reg led0, // Диод 0
    output reg led1  // Диод 1
);

    reg [15:0] tone_counter;
    reg [15:0] duration_counter;
    reg playing; 

    parameter TONE_PERIOD = 16'd1000;
    parameter DURATION = 16'd5000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            beep <= 0;
            ready <= 0;
            tone_counter <= 0;
            duration_counter <= 0;
            playing <= 0;
            led0 <= 0; 
            led1 <= 0; 
        end else begin
            if (key1 && !playing) begin
                playing <= 1;
                duration_counter <= DURATION;
                tone_counter <= 0;
                ready <= 1;
                led1 <= 1; 
            end else if (playing) begin
                if (tone_counter < TONE_PERIOD) begin
                    beep <= ~beep;
                    tone_counter <= tone_counter + 1;
                end else begin
                    tone_counter <= 0;
                    if (duration_counter > 0) begin
                        duration_counter <= duration_counter - 1;
                    end else begin
                        playing <= 0;
                        ready <= 0;
                        beep <= 0;
                        led1 <= 0; 
                    end
                end
            end
//            led0 <= start; 
        end
    end
endmodule
