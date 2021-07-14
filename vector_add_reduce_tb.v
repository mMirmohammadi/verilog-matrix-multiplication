`timescale 1ns / 1ns
module vector_add_reduce_tb #(parameter k = 4);
    reg [0:k - 1][31:0] vector;
    reg clk, resetN, result_ack;
    reg [0:k - 1] data_in_ready;
    wire [31:0] result;
    wire result_ready;

    vector_add_reduce #(.k(k)) var(
        .vector(vector),
        .clk(clk),
        .resetN(resetN),
        .data_in_ready(data_in_ready),
        .data_out_ack(result_ack),
        .result(result),
        .data_out_ready(result_ready)
    );

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        $dumpfile("var.vcd");
        $dumpvars(0, vector_add_reduce_tb);
        resetN = 0;
        #10
        resetN = 1;
        vector[0] = 32'b00111111100000000000000000000000;
        vector[1] = 32'b00111111100000000000000000000100;
        vector[2] = 32'b00111111100000000000000000001000;
        vector[3] = 32'b00111111100000000000000000010100;
        data_in_ready = 0;
        data_in_ready = ~data_in_ready;

        result_ack = 0;
        
        #100 $finish;
    end
endmodule