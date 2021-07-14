`timescale 1ns / 1ps

module registers_with_shift #(
	parameter K=2, N=4, WIDTH1 = $clog2(N/K), WIDTH2 = $clog2(K)) (
	input clk, reset, shift_up, shift_left, load_all, load_single,
	input [WIDTH1 -1:0] input_block_i, 
	input [WIDTH1 -1:0] input_block_j,
	input [WIDTH2 -1:0] input_single_i,
	input [WIDTH2 -1:0] input_single_j,
	input [31:0] input_single,
	input [32 * N * N - 1 : 0] input_matrix_flatten,
	output [32 * N * N - 1 : 0] output_matrix_flatten
	);
	 
	wire [31:0] input_matrix[N/K - 1:0][N/K - 1:0][K-1:0][K-1:0];
	reg [31:0] matrix[N/K - 1:0][N/K - 1:0][K-1:0][K-1:0];
	
	genvar i1, i2, j1, j2;
	generate
		for (i1 = 0; i1 < N/K; i1 = i1+1) begin
			for (j1 = 0; j1 < N/K; j1 = j1+1) begin
				for (i2 = 0; i2 < K; i2 = i2+1) begin
					for (j2 = 0; j2 < K; j2 = j2 + 1) begin
						// 32 * (N * (i1 * K + i2) + j1 * K + j2 + 1) - 1 :  32 * (N * (i1 * K + i2) + j1 * K + j2)
						assign output_matrix_flatten[32 * (K * K *(i1 * N/K + j1) + i2 * K + j2 + 1) - 1 : 32 * (K * K *(i1 * N/K + j1) + i2 * K + j2)] = matrix[i1][j1][i2][j2];
						assign input_matrix[i1][j1][i2][j2] = input_matrix_flatten[32 * (K * K *(i1 * N/K + j1) + i2 * K + j2 + 1) - 1 : 32 * (K * K *(i1 * N/K + j1) + i2 * K + j2)];
						
						always @ (posedge clk or negedge reset) begin
							if (!reset) begin
								matrix[i1][j1][i2][j2] <= 0;
								
							end else if (load_all) begin
							
								matrix[i1][j1][i2][j2] <= input_matrix[i1][j1][i2][j2];
							
							end else if (load_single) begin
							
								if (input_block_i == i1 && input_block_j == j1 && input_single_i == i2 && input_single_j == j2)
									matrix[i1][j1][i2][j2] <= input_single;

							end else if (shift_left) begin
									
								if (j1 == N/K-1) begin
									matrix[i1][j1][i2][j2] <= matrix[i1][0][i2][j2];
								end else begin
									matrix[i1][j1][i2][j2] <= matrix[i1][j1 + 1][i2][j2];
								end
							
							end else if (shift_up) begin
							
								if (i1 == N/K-1) begin
									matrix[i1][j1][i2][j2] <= matrix[0][j1][i2][j2];
								end else begin
									matrix[i1][j1][i2][j2] <= matrix[i1 + 1][j1][i2][j2];
								end

							end
						end
					end
				end
			end
		end
	endgenerate


endmodule