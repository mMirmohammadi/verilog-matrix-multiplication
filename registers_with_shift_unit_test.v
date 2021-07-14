`timescale 1ns / 1ps

module registers_with_shift_unit_test #(
	parameter K=2, N=4, WIDTH = $clog2(N) );

	// Inputs
	reg clk;
	reg reset;
	reg shift_up;
	reg shift_left;
	reg load_all;
	reg load_single;
	reg [1:0] input_block_i;
	reg [1:0] input_block_j;
	reg [1:0] input_single_i;
	reg [1:0] input_single_j;
	reg [31:0] input_single;
	reg [511:0] input_matrix_flatten;

	// Outputs
	wire [511:0] output_matrix_flatten;

	// Instantiate the Unit Under Test (UUT)
	registers_with_shift uut (
		.clk(clk), 
		.reset(reset), 
		.shift_up(shift_up), 
		.shift_left(shift_left), 
		.load_all(load_all), 
		.load_single(load_single), 
		.input_block_i(input_block_i), 
		.input_block_j(input_block_j), 
		.input_single_i(input_single_i), 
		.input_single_j(input_single_j), 
		.input_single(input_single), 
		.input_matrix_flatten(input_matrix_flatten), 
		.output_matrix_flatten(output_matrix_flatten)
	);

	genvar i1, i2, j1, j2;
	generate
		for (i1 = 0; i1 < N/K; i1 = i1+1) begin
			for (j1 = 0; j1 < N/K; j1 = j1+1) begin
				for (i2 = 0; i2 < K; i2 = i2+1) begin
					for (j2 = 0; j2 < K; j2 = j2 + 1) begin
						
	
						initial begin
							forever #10 $display("time=%t \t i1=%d \t j1=%d \t i2=%d \t j2=%d \t value=%d", $time, i1, j1, i2, j2,
								output_matrix_flatten[32 * (N * (i1 * K + i2) + j1 * K + j2 + 1) - 1 :  32 * (N * (i1 * K + i2) + j1 * K + j2)]);
						end

					end
				end
			end
		end
	endgenerate

	initial begin
		clk <= 0;
		forever #5 clk <= ~clk;
	end

	initial begin
		// Initialize Inputs
		reset = 0;
		shift_up = 0;
		shift_left = 0;
		load_all = 0;
		load_single = 0;
		input_block_i = 0;
		input_block_j = 0;
		input_single_i = 0;
		input_single_j = 0;
		input_single = 0;
		input_matrix_flatten = 0;

		#10;
		
		reset <= 1;
		
		#10;
		
		input_block_i = 0;
		input_block_j = 1;
		input_single_i = 1;
		input_single_j = 0;
		
		input_single = 17;
		
		load_single = 1;
		
		#10;
		
		input_block_i = 0;
		input_block_j = 0;
		input_single_i = 1;
		input_single_j = 1;
		
		input_single = 13;
		
		
		#10;
		
		input_block_i = 1;
		input_block_j = 0;
		input_single_i = 1;
		input_single_j = 0;
		
		input_single = 123;
		
		
		#10;
		
		input_block_i = 1;
		input_block_j = 1;
		input_single_i = 0;
		input_single_j = 0;
		
		input_single = 222;
		
		#10;
		
		load_single = 0;
		
		shift_up = 1;
		
		#10;
		
		shift_up = 0;
		shift_left = 1;
		
		#10;
		
		shift_left = 0;
		
		#10;
		
		load_all = 1;
		input_matrix_flatten = 512'h0000000f0000000e0000000d0000000c0000000b0000000a00000009000000080000000700000006000000050000000400000003000000020000000100000000;
		
		#10;
		
		load_all = 0;
		
		shift_up = 1;
		
		#10;
		
		shift_up = 0;
		shift_left = 1;
		
		#10;
		
		shift_left = 0;
		
		#10;

	end
      
endmodule

