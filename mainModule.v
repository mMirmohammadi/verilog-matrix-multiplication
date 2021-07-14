module mainModule#(parameter N = 4, parameter K = 2, 
		   parameter WIDTH = $clog2(N), parameter DATA_WIDTH = 32,
		   parameter ADDRESS_WIDTH = $clog2(3 * N * N + 2), parameter MEMORY_DEPTH = 1 << ADDRESS_WIDTH,
		   parameter logNdK = $clog2( N / K ))(
input clock,
input start,
input resetN,
	output	reg			 memory_Read_Enable,
	output	reg 			 memory_Write_Enable,
	output reg [DATA_WIDTH-1:0]	 data_to_memory,
	output	wire [ADDRESS_WIDTH-1:0] memory_Address,
	input 	wire [DATA_WIDTH-1:0]	 single_data
);

//has changed
parameter read_Status_State = 4'b0000;
parameter initial_State = 4'b0001;
parameter read_Config_State = 4'b0010;
parameter readA_State = 4'b0011;
parameter readB_State = 4'b0100;
parameter multiply_State  = 4'b0101;
parameter sum_State  = 4'b0110;
parameter writeC_State = 4'b0111;
parameter final_State =  4'b1000;
parameter write_Status_State= 4'b1001;

reg [3:0] main_State;
reg [7:0] first_Counter;
reg [7:0] second_Counter;
reg [7:0] second_Counter2;

wire [31 : 0] inputC_matrix_flatten_ovo[N * N - 1:0];

//adder outputs
//input [31:0] sum [N/K - 1:0][N/K - 1:0][0:K-1][0:K-1]; //not needed
wire  [K * K -1 : 0] adder_result_ready [N/K - 1:0][N/K - 1:0];
wire  [(N/K) * (N/K) -1 : 0] adder_result_ready_packed;

wire [32 * N * N - 1 : 0] inputA_matrix_flatten;
wire [32 * N * N - 1 : 0] inputB_matrix_flatten;
wire [32 * N * N - 1 : 0] inputC_matrix_flatten;

wire [32 * N * N - 1 : 0] C;

wire [K * K * 32 - 1:0] inputA_matrix [N/K - 1:0][N/K - 1:0];
wire [K * K * 32 - 1:0] inputB_matrix [N/K - 1:0][N/K - 1:0];
wire [K * K * 32 - 1:0] inputC_matrix [N/K - 1:0][N/K - 1:0];
wire [K * K * 32 - 1:0] C_tmp [N/K - 1:0][N/K - 1:0];


//adder inputs
reg  adder_reset [N/K - 1:0][N/K - 1:0];
reg  adder_result_ack [N/K - 1:0][N/K - 1:0];
reg  adder_enable_signal [N/K - 1:0][N/K - 1:0];

//multiplier inputs
reg  multiplier_reset [N/K - 1:0][N/K - 1:0];
reg  multiplier_result_ack [N/K - 1:0][N/K - 1:0];
reg  multiplier_enable_signal [N/K - 1:0][N/K - 1:0];
//multiplier outputs
wire [K * K * 32 - 1:0] product [N/K - 1:0][N/K - 1:0];
wire  [K * K - 1 : 0] multiplier_result_ready [N/K - 1:0][N/K - 1:0];
wire [(N/K) * (N/K) -1 : 0] multiplier_result_ready_packed;


//iterator registers
reg [WIDTH-1:0] block_i = 0;
reg [WIDTH-1:0] block_j = 0;
reg [WIDTH-1:0] single_i = 0;
reg [WIDTH-1:0] single_j = 0;

//wire  [DATA_WIDTH-1:0]	 single_data;

//for A
reg load_singleA;
reg shift_leftA;
reg load_allA;
reg resetRegisterA;
wire [logNdK - 1: 0]input_block_j_A = block_j - block_i;
registers_with_shift #(.N(N), .K(K)) registerWshiftsA(.clk(clock),.reset(resetRegisterA),.shift_left(shift_leftA ),.shift_up(1'b0),
                                      .load_all(load_allA),.load_single(load_singleA),
				      .input_block_i(block_i), .input_block_j(input_block_j_A),
				      .input_single_i(single_i), .input_single_j(single_j),
				      .input_single(single_data),
				      .input_matrix_flatten(A_flatten),.output_matrix_flatten(inputA_matrix_flatten));

//for B
reg load_singleB;
reg shift_upB;
reg load_allB;
reg resetRegisterB;
wire [logNdK - 1: 0]input_block_i_B = block_i - block_j;
registers_with_shift #(.N(N), .K(K)) registerWshiftsB(.clk(clock),.reset(resetRegisterB),.shift_up(shift_upB ),.shift_left(1'b0),
                                      .load_all(load_allB), .load_single(load_singleB),
				      .input_block_i(input_block_i_B), .input_block_j(block_j),
				      .input_single_i(single_i), .input_single_j(single_j),
				      .input_single(single_data),
				      .input_matrix_flatten(B_flatten),.output_matrix_flatten(inputB_matrix_flatten));

//for C
reg load_allC;
reg resetRegisterC;
registers_with_shift #(.N(N), .K(K)) registerWshiftsC(.clk(clock),.reset(resetRegisterC),.shift_up(1'b0),.shift_left(1'b0),
                                      .load_all(load_allC),.load_single(1'b0),
				      .input_block_i(0), .input_block_j(0),
				      .input_single_i(0), .input_single_j(0),
				      .input_single(0),
                                      .input_matrix_flatten(C),.output_matrix_flatten(inputC_matrix_flatten));
//memory offsets


reg [ADDRESS_WIDTH-1:0] offset = 2;
wire [ADDRESS_WIDTH-1:0] offset_A = 2;
wire [ADDRESS_WIDTH-1:0] offset_B = 2 + M1Ncolumns * M1Nrows;
wire [ADDRESS_WIDTH-1:0] offset_C = 2 + M1Ncolumns * M1Nrows + M2Ncolumns * M2Nrows;
 


//memory unit
reg read_from_memory;
/*
reg			 memory_Read_Enable;
reg 			 memory_Write_Enable;
reg  [DATA_WIDTH-1:0]	 input_data;
wire [ADDRESS_WIDTH-1:0]  memory_Address;
//reg  [DATA_WIDTH-1:0]	 single_data;


memory_unit #(.ADDRESS_WIDTH(ADDRESS_WIDTH)) memory(.clk(clock), .i_Read_Enable(memory_Read_Enable), .i_Write_Enable(memory_Write_Enable), 
		   .i_Data_In(input_data), .i_Address(memory_Address), .o_Data_Out(single_data), .resetN(resetN));
*/

//FSM

//has changed
reg [7:0] M1Ncolumns;
reg [7:0] M2Ncolumns;
reg [7:0] M1Nrows;
reg [7:0] M2Nrows;
reg enable;

genvar x1,y1;
generate 
	for (x1 = 0; x1 < N/K; x1 = x1 + 1) begin
		for (y1 = 0; y1 < N/K; y1 = y1 + 1) begin
			assign  multiplier_result_ready_packed[x1 * N / K + y1] =  &multiplier_result_ready[x1][y1];
			assign  adder_result_ready_packed[x1 * N / K + y1] = &adder_result_ready[x1][y1];

			always @(posedge clock or negedge resetN ) begin
				if (~resetN) begin
					main_State <= read_Status_State;
					memory_Read_Enable <= 1;
					enable <= 0;
				end else begin
					case (main_State)
                        read_Status_State: begin
                            memory_Read_Enable <= 1'b1;
							main_State <= read_Status_State;
							if(start) begin
								enable <= single_data[31];
								if (enable) begin
									main_State <= initial_State;
								end
							end
					    end
						initial_State: begin
						// initial values 
							memory_Read_Enable <= 1;
							memory_Write_Enable <= 0;
							
							main_State <= 0;
							first_Counter <= 0;
							second_Counter <= 0;
							second_Counter2 <= 0;
/*
							inputA_matrix_flatten <= 0;
							inputB_matrix_flatten <= 0;
							inputC_matrix_flatten <= 0;
							C <= 0;
							*/
							offset <= offset_A;
							
							block_i <=0;
							block_j <= 0;
							single_i <= 0;
							single_j <= 0;


							load_singleA <= 1'b0;
							shift_leftA <= 1'b0;
							load_allA <=1'b0;
							resetRegisterA <= 1'b0;

							load_singleB<= 1'b0;
							shift_upB<= 1'b0;
							load_allB <=1'b0;
							resetRegisterB<= 1'b0;


							load_allC<= 1'b0;
							resetRegisterC<= 1'b0;
								
							read_from_memory <=1'b1;

							//////////////////////////////
							multiplier_reset[x1][y1] <= ~0;
							adder_reset[x1][y1] <= ~0;

							first_Counter <= 0;
							second_Counter <= 0;
							second_Counter2 <= 0;


							// C <= 0;

							block_i <= 0;
							block_j <= 0;
							single_i <= 0;
							single_j <= 0;

							first_Counter <= 1'b0;
							second_Counter <= 1'b0;
							second_Counter2 <= 1'b0;
							//go to next state
							main_State <= read_Config_State;
							//memory_Address <= offset + (N * (K * block_i + single_i) + (K * block_j + single_j));
						end

                        //has changed
                        read_Config_State: begin
							main_State <= readA_State;
                            M2Ncolumns <= single_data[31:24];
                            M2Nrows <= single_data[23:16];
                            M1Ncolumns <= single_data[15:8];
                            M1Nrows <= single_data[7:0];
						end

						readA_State: begin

							read_from_memory <= ~read_from_memory;

							resetRegisterA <= ~0;
							resetRegisterB <= ~0;
							resetRegisterC <= ~0;
							//memory_Address <= offset + (N * (K * block_i + single_i) + (K * block_j + single_j));
							
							
							// update block and single

							if( read_from_memory )
								load_singleA  <= 1'b1;
							else begin
								if( single_j == K - 1 || (single_j == (M1Ncolumns % K) - 1 && block_j == ((M1Ncolumns + K) / K) - 1)) begin
									single_j <= 0;
									if( single_i == K - 1 || (single_i == (M1Nrows % K) - 1 && block_i == ((M1Nrows + K) / K) - 1)) begin  
										single_i <= 0;
										if( block_j == ((M1Ncolumns + K - 1) / K) - 1) begin
											block_j <= 0;
											if( block_i == ((M1Nrows + K - 1) / K) - 1) begin
												block_i <= 0;
												main_State <= readB_State;
												offset <= offset_B;
												load_singleB <= 0;
											end else
												block_i <= block_i + 1;
										end else
											block_j <= block_j + 1;
									end else
										single_i <= single_i + 1;
								end else
									single_j <= single_j + 1;
								load_singleA <= 1'b0;
							end

						end

						readB_State: begin

							read_from_memory <= ~read_from_memory;
							//memory_Address <= offset + (N * (K * block_i + single_i) + (K * block_j + single_j));
							
							if( read_from_memory )
								load_singleB  <= 1'b1;
							else begin
								if( single_j == K - 1 || (single_j == (M2Ncolumns % K) - 1 && block_j == ((M2Ncolumns + K) / K) - 1)) begin
									single_j <= 0;
									if( single_i == K - 1 || (single_i == (M2Nrows % K) - 1 && block_i == ((M2Nrows + K) / K) - 1)) begin 
										single_i <= 0;
										if( block_j == ((M2Ncolumns + K - 1) / K) - 1) begin
											block_j <= 0;
											if( block_i == ((M2Nrows + K - 1) / K) - 1) begin
												block_i <= 0;
												main_State <= multiply_State;
												memory_Read_Enable <= 0;
												load_singleB <= 0;
											end else
												block_i <= block_i + 1;
										end else
											block_j <= block_j + 1;
									end else
										single_i <= single_i + 1;
								end else
									single_j <= single_j + 1;
								load_singleB <= 1'b0;
							end
						end

						multiply_State: begin //correct
							//activate shift signals
							shift_leftA <= 1'b0;
							shift_upB <= 1'b0;
							load_allC <= 1'b0;
							multiplier_enable_signal[x1][y1] <= ~0;
							multiplier_result_ack[x1][y1] <= 0;
							//go to next state
							if (& multiplier_result_ready_packed) begin
								//get result from multiplier and give inputs into adder 
								multiplier_result_ack[x1][y1] <= ~0; //c
								multiplier_enable_signal[x1][y1] <= 0; //notSure
								adder_enable_signal[x1][y1] <= ~0;
								main_State <= sum_State;
							end else
								main_State <= multiply_State;
						end

						sum_State: begin //corect
								//go to next state
								if (& adder_result_ready_packed) begin
									//get results from adder
									adder_result_ack[x1][y1] <= ~0; //c
									adder_enable_signal[x1][y1] <= 0;
									main_State <= writeC_State;
								end else
									main_State <= sum_State;

						end

						writeC_State: begin
							if(first_Counter == (N/K)) begin
								first_Counter <= 0;
								load_allC <= 0;
								main_State <= final_State;
							end else if (first_Counter == (N/K - 1)) begin
								first_Counter <= first_Counter + 1;
								load_allC <= 1'b1;
							end
							else begin
								first_Counter <= first_Counter + 1;
								load_allC <= 1'b1;
								//activate shift signals
								shift_leftA <= 1'b1;
								shift_upB <= 1'b1;
								//go to next state
								main_State <= multiply_State;
							end
						end

						final_State: begin
							load_allC <= 1'b0;
							if(second_Counter == M1Nrows*N)
								main_State <= write_Status_State; //has changed
							else begin
								memory_Write_Enable <= 1'b1;
								data_to_memory <= inputC_matrix_flatten_ovo[second_Counter];
								//memory_Address <= offset_C + second_Counter;
								if (second_Counter % N == M2Ncolumns - 1)
									second_Counter <= second_Counter + (N - M2Ncolumns + 1);
								else
									second_Counter <= second_Counter + 1;
								second_Counter2 <= second_Counter2 + 1;
								main_State <= final_State;
							end
						end

                        //has changed
                        write_Status_State: begin
							data_to_memory <= 1;
							//memory_Address <= 0;
							main_State <= read_Status_State;
					    end
						
						default :
							main_State <= read_Status_State; //has changed

					endcase
				end
			end
		end
	end
endgenerate

genvar i_1, i_2, j_1, j_2;
generate
   for (i_1 = 0; i_1 < N/K; i_1 = i_1 + 1) begin
		for (j_1 = 0; j_1 < N/K; j_1 = j_1 + 1) begin // 32 * (K * K *(i_1 * N/K + j_1 + 1)) - 1 : 32 * (K * K *(i_1 * N/K + j_1))
			assign inputA_matrix[i_1][j_1] = inputA_matrix_flatten[32 * (K * K *(i_1 * N/K + j_1 + 1)) - 1 : 32 * (K * K *(i_1 * N/K + j_1))];
			assign inputB_matrix[i_1][j_1] = inputB_matrix_flatten[32 * (K * K *(i_1 * N/K + j_1 + 1)) - 1 : 32 * (K * K *(i_1 * N/K + j_1))];
			assign inputC_matrix[i_1][j_1] = inputC_matrix_flatten[32 * (K * K *(i_1 * N/K + j_1 + 1)) - 1 : 32 * (K * K *(i_1 * N/K + j_1))];
			assign C[32 * (K * K *(i_1 * N/K + j_1 + 1)) - 1 : 32 * (K * K *(i_1 * N/K + j_1))] = C_tmp[i_1][j_1];
		end
   end
endgenerate


//Connecting matrix multipliers

genvar i1, j1, i2, j2 ;
generate
   for (i1 = 0; i1 < N/K; i1 = i1+1) begin
		for (j1 = 0; j1 < N/K; j1 = j1+1) begin : mult
			 matrix_multiplier #(.k(K)) mul(
							 .i1matrix(inputA_matrix[i1][j1]),
							 .i2matrix(inputB_matrix[i1][j1]),
							 .matrix1_ready(multiplier_enable_signal[i1][j1]),
							 .matrix2_ready(multiplier_enable_signal[i1][j1]),
							 .clk(clock),
							 .resetN(resetN),
							 .result_ack(multiplier_result_ack[i1][j1]),
							 .omatrix(product[i1][j1]),
							 .result_ready(multiplier_result_ready[i1][j1])
					);
		end
	end
endgenerate

//Connecting matrix adders

generate
   for (i2 = 0; i2 < N/K; i2 = i2+1) begin
		for (j2 = 0; j2 < N/K; j2 = j2+1) begin

			 matrix_adder #(.k(K)) add(
							 .i1matrix(product[i2][j2]),
							 .i2matrix(inputC_matrix[i2][j2]),
							 .clk(clock),
							 .resetN(resetN),
							 .load(adder_enable_signal[i2][j2]),
							 .result_ack(adder_result_ack[i2][j2]),
							 .omatrix(C_tmp[i2][j2]),
							 .result_ready(adder_result_ready[i2][j2])    
					);
					
		end
	end
endgenerate

generate
	for (i1 = 0; i1 < N/K; i1 = i1+1) begin
		for (j1 = 0; j1 < N/K; j1 = j1+1) begin
			for (i2 = 0; i2 < K; i2 = i2+1) begin
				for (j2 = 0; j2 < K; j2 = j2 + 1) begin
					assign  inputC_matrix_flatten_ovo[N * (i1 * K + i2) + j1 * K + j2] = 
					inputC_matrix_flatten[32 * (K * K *(i1 * N/K + j1) + i2 * K + j2 + 1) - 1 : 32 * (K * K *(i1 * N/K + j1) + i2 * K + j2)];//C[32 * (N * (i1 * K) + j1 * K * K) - 1 :  32 * (N * (i1 * K) + j1 * K * K)] = C_tmp[i1][j1];
				end
			end
		end
	end
endgenerate

//has changed
assign memory_Address = (main_State == final_State) ? offset_C + second_Counter2 - 1 : (main_State == read_Status_State || main_State == write_Status_State) ? 0 : (main_State == initial_State) ? 1 : offset + ((main_State == readA_State) ? M1Ncolumns : ((main_State == readB_State) ? M2Ncolumns : N)) * (K * block_i + single_i) + (K * block_j + single_j);
endmodule