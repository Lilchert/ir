module top (
    input  logic clk25,          
    input  logic [1:0] key,     
    output logic [3:0] led 
);

	 sound_generator s1(
		.clk(clk25),
//			.reset(~key[1]),
		.key1(key[0]),
		.beep(led[2]),
		.ready(led[3]),          
		.led0(led[0]),
		.led1(led[1])
	);

endmodule
