`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:53:54 07/11/2021 
// Design Name: 
// Module Name:    top_module 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top_module #(parameter N = 4, parameter K = 2, 
		   parameter WIDTH = $clog2(N), parameter DATA_WIDTH = 32,
		   parameter ADDRESS_WIDTH = $clog2(3 * N * N + 2), parameter MEMORY_DEPTH = 1 << ADDRESS_WIDTH,
		   parameter logNdK = $clog2( N / K ))(
input clock,
input start,
input resetN,

input dma, //direct memory access
input			 dma_memory_Read_Enable,
input 			 dma_memory_Write_Enable,
input [DATA_WIDTH-1:0]	 dma_data_to_memory,
input [ADDRESS_WIDTH-1:0] dma_memory_Address,
output [DATA_WIDTH-1:0]	 dma_single_data
);


wire			 main_memory_Read_Enable;
wire 			 main_memory_Write_Enable;
wire [DATA_WIDTH-1:0]	 main_data_to_memory;
wire [ADDRESS_WIDTH-1:0] main_memory_Address;
wire [DATA_WIDTH-1:0]	 main_single_data;

	 
wire			 memory_Read_Enable = dma ? dma_memory_Read_Enable : main_memory_Read_Enable;
wire 			 memory_Write_Enable = dma ? dma_memory_Write_Enable : main_memory_Write_Enable;
wire [DATA_WIDTH-1:0]	 data_to_memory = dma ? dma_data_to_memory : main_data_to_memory;
wire [ADDRESS_WIDTH-1:0] memory_Address = dma ? dma_memory_Address : main_memory_Address;
wire [DATA_WIDTH-1:0]	 single_data;

assign dma_single_data = single_data;
assign main_single_data = single_data;

memory_unit #(.ADDRESS_WIDTH(ADDRESS_WIDTH)) memory (
	.clk(clock),
	.resetN(resetN),
	.i_Read_Enable(memory_Read_Enable),
	.i_Write_Enable(memory_Write_Enable),
	.i_Data_In(data_to_memory),
	.i_Address(memory_Address),
	.o_Data_Out(single_data)
);

mainModule #(.N(N), .K(K)) main (
	.clock(clock),
	.start(start),
	.resetN(resetN),
	.memory_Read_Enable(main_memory_Read_Enable),
	.memory_Write_Enable(main_memory_Write_Enable),
	.data_to_memory(main_data_to_memory),
	.memory_Address(main_memory_Address),
	.single_data(main_single_data)
);





endmodule
