module memory_unit #(parameter DATA_WIDTH = 32,
		     parameter ADDRESS_WIDTH = 5,
		     parameter MEMORY_DEPTH = 1 << ADDRESS_WIDTH)
(
	input wire resetN,
	input wire			 clk,
	input	wire			 i_Read_Enable,
	input	wire 			 i_Write_Enable,
	input wire [DATA_WIDTH-1:0]	 i_Data_In,
	input	wire [ADDRESS_WIDTH-1:0] i_Address,
	output 	reg [DATA_WIDTH-1:0]	 o_Data_Out
);

reg [DATA_WIDTH-1:0] memory [MEMORY_DEPTH-1:0];
integer i;

always @ (posedge clk or negedge resetN)
begin 
	if (~resetN) begin
		for (i = 0; i < MEMORY_DEPTH; i = i + 1)
			memory[i] <= 0;
		o_Data_Out <= 0;
	end else begin

		if (i_Write_Enable)
			memory[i_Address] <= i_Data_In;
		if(i_Read_Enable) begin
			o_Data_Out <= memory[i_Address];

		end
			
	end
end


endmodule