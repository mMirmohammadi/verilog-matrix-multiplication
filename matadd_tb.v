`timescale 1ns / 1ns
module matadd_tb #(parameter k = 2);
    reg [0:k - 1][0:k - 1][31:0] i1matrix;
    reg [0:k - 1][0:k - 1][31:0] i2matrix;
    reg clk, load, resetN, result_ack;
    wire [0:k - 1][0:k - 1][31:0] omatrix;
    wire [0:k - 1][0:k - 1] result_ready;

    matrix_adder #(.k(k)) mult(
        .i1matrix(i1matrix),
        .i2matrix(i2matrix),
        .omatrix(omatrix),
        .result_ready(result_ready),
        .result_ack(result_ack),
        .load(load),
        .resetN(resetN),
        .clk(clk)
    );
    
    // genvar i;
    // generate
    //     for (i = 0; i < k * k; i = i + 1) begin
    //         adder a(
    //             .clk(clk),
    //             .reset(resetN), 
    //             .load(load),
    //             .Number1(i1matrix[i / k][i % k]), 
    //             .Number2(i2matrix[i / k][i % k]),
    //             .result_ack(result_ack),
    //             .Result(omatrix[i / k][i % k]),
    //             .result_ready(result_ready[i])
    //         );
    //     end
    // endgenerate

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        $dumpfile("add.vcd");
        $dumpvars(0, matadd_tb);
        resetN = 0;
        #100
        load = 1;
        resetN = 1;
        i1matrix[0][0] = 32'h40A00000;
        i1matrix[0][1] = 32'b00111111100000000000000000000001;
        i1matrix[1][0] = 32'b00111111100000000000000000000010;
        i1matrix[1][1] = 32'b00111111100000000000000000000100;

        i2matrix[0][0] = 32'h00000000;
        i2matrix[0][1] = 32'b00111111100000000000000000000111;
        i2matrix[1][0] = 32'b00111111100000000000000000000100;
        i2matrix[1][1] = 32'b00111111100000000000000000000100;

        result_ack = 0;
        
        #1000 $finish;
    end
endmodule