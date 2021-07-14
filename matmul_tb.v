`timescale 1ns / 1ns
module matmul_tb #(parameter k = 1);
    reg [0:k - 1][0:k - 1][31:0] i1matrix;
    reg [0:k - 1][0:k - 1][31:0] i2matrix;
    reg matrix1_ready;
    reg matrix2_ready;
    reg clk, resetN, result_ack;
    wire [0:k - 1][0:k - 1][31:0] omatrix;
    wire [0:k - 1][0:k - 1] result_ready;

    matrix_multiplier #(.k(k)) mult(
        .i1matrix(i1matrix),
        .i2matrix(i2matrix),
        .matrix1_ready(matrix1_ready),
        .matrix2_ready(matrix2_ready),
        .omatrix(omatrix),
        .result_ready(result_ready),
        .result_ack(result_ack),
        .resetN(resetN),
        .clk(clk)
    );
    
    // genvar i, j, p;
    // generate
    //     for (i = 0; i < k; i = i + 1) begin
    //         for (j = 0; j < k; j = j + 1) begin
    //             for (p = 0; p < k; p = p + 1) begin
    //                 single_multiplier m(
    //                     .clk(clk),
    //                     .rst(resetN),
    //                     .input_a(i1matrix[i][p]),
    //                     .input_b(i2matrix[p][j]),
    //                     .output_z(medmatrix[i][j][p]),
    //                     .input_a_stb(matrix1_ready),
    //                     .input_b_stb(matrix2_ready),
    //                     .input_a_ack(mat1_ack[i][j][p]),
    //                     .input_b_ack(mat2_ack[i][j][p]),
    //                     .output_z_stb(medmult_ready[i][j][p]),
    //                     .output_z_ack(result_ack)
    //                 );
    //             end
    //             // vector_add_reduce #(.k(k)) var (
    //             //     .vector(medmatrix[i][j]),
    //             //     .clk(clk),
    //             //     .resetN(resetN),
    //             //     .data_in_ready(&medmult_ready[i][j]),
    //             //     .data_out_ack(result_ack),
    //             //     .result(omatrix[i][j]),
    //             //     .data_out_ready(result_ready[i][j])
    //             // );
    //         end
    //     end
    // endgenerate
    
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
        $dumpfile("mult.vcd");
        $dumpvars(0, matmul_tb);
        resetN = 1;
        #10resetN = 0;
        i1matrix[0][0] = 0;
        i2matrix[0][0] = 0;
        matrix1_ready = 0;
        matrix2_ready = 0;
        #1000
        resetN = 1;
        i1matrix[0][0] = 32'h3f800000;
        // i1matrix[0][1] = 32'b00111111100000000000000000000001;
        // i1matrix[1][0] = 32'b00111111100000000000000000000010;
        // i1matrix[1][1] = 32'b00111111100000000000000000000100;

        i2matrix[0][0] = 32'h40A00000;
        // i2matrix[0][1] = 32'b00111111100000000000000000000010;
        // i2matrix[1][0] = 32'b00111111100000000000000000000100;
        // i2matrix[1][1] = 32'b00111111100000000000000000000100;

        #10;
        matrix1_ready = 1;
        matrix2_ready = 1;

        result_ack = 0;
        
        #5000 $finish;
    end
endmodule