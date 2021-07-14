`timescale 1ns/1ns 
module top_module_TB;
parameter N = 4, K = 1;
reg start;
reg clock;
reg resetN;
integer f, i;

top_module #(.N(N), .K(K)) topModule(
    .clock(clock),
    .start(start), 
    .resetN(resetN), 
    .dma(0), 
    .dma_memory_Read_Enable(z),
    .dma_memory_Write_Enable(z),
    .dma_data_to_memory(z),
    .dma_memory_Address(z),
    .dma_single_data(z));

initial
begin
   $dumpfile("main4.vcd");
  $dumpvars(0, top_module_TB);
	resetN = 1;
	#2;
	resetN = 0;
	#2;
	resetN = 1;
    $readmemh("Sample4.txt", topModule.memory.memory);

    start = 1'b1;
    #20 start = 0;

    #59900
    f = $fopen("output4.txt","w");
    for (i = 0; i < 3 * N * N + 2; i=i+1) begin
        $fwrite(f,"%h\n",topModule.memory.memory[i]);
    end
    $fclose(f);
    f = $fopen("ovo4.txt","w");
    for (i = 0; i < N * N; i=i+1) begin
        $fwrite(f,"%h\n",topModule.main.inputC_matrix_flatten_ovo[i]);
    end
    $fclose(f);
    
    $finish;
end

initial 
begin
clock <= 1'b0 ;
forever #1 clock = ~clock;
end


// initial 
// begin
// forever #2 $display("%0t main state = %b", $time, topModule.main.main_State);
// end

// initial 
// begin
// forever #2 $display("A = %h", topModule.main.inputA_matrix_flatten);
// end

// initial 
// begin
// forever #2 $display("B = %h", topModule.main.inputB_matrix_flatten);
// end

// initial 
// begin
// forever #2 $display("C = %h ", topModule.main.inputC_matrix_flatten);
// end
endmodule