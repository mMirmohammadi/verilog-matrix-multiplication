module matrix_multiplier #(
    parameter k = 2
) (
    input [k * k * 32 - 1:0] i1matrix,
    input [k * k * 32 - 1:0] i2matrix,
    input matrix1_ready,
    input matrix2_ready,
    input clk,
    input resetN,
    input result_ack,
    output [k * k * 32 - 1:0] omatrix,
    output [k * k - 1:0] result_ready
);
    wire [k * 32 - 1:0] medmatrix [0:k - 1][0:k - 1];
    wire [k - 1:0] medmult_ready [0:k - 1][0:k - 1];
    wire [k - 1:0] mat1_ack [0:k - 1][0:k - 1];
    wire [k - 1:0] mat2_ack [0:k - 1][0:k - 1];

    wire [31:0] i1matrix_inner [0:k - 1][0:k - 1];
    wire [31:0] i2matrix_inner [0:k - 1][0:k - 1];
    wire [31:0] omatrix_inner [0:k - 1][0:k - 1];
    wire result_ready_inner [0:k - 1][0:k - 1];

    genvar i, j, p;
    generate
        for (i = 0; i < k; i = i + 1) begin
            for (j = 0; j < k; j = j + 1) begin
                assign i1matrix_inner[i][j] = i1matrix[(i * k + j + 1) * 32 - 1:(i * k + j) * 32];
                assign i2matrix_inner[i][j] = i2matrix[(i * k + j + 1) * 32 - 1:(i * k + j) * 32];
                assign omatrix[(i * k + j + 1) * 32 - 1:(i * k + j) * 32] = omatrix_inner[i][j];
                assign result_ready[i * k + j] = result_ready_inner[i][j];
            end
        end
        for (i = 0; i < k; i = i + 1) begin
            for (j = 0; j < k; j = j + 1) begin
                for (p = 0; p < k; p = p + 1) begin
                    single_multiplier m(
                        .clk(clk),
                        .rst(resetN),
                        .input_a(i1matrix_inner[i][p]),
                        .input_b(i2matrix_inner[p][j]),
                        .output_z(medmatrix[i][j][(p + 1) * 32 - 1: p * 32]),
                        .input_a_stb(matrix1_ready),
                        .input_b_stb(matrix2_ready),
                        .input_a_ack(mat1_ack[i][j][p]),
                        .input_b_ack(mat2_ack[i][j][p]),
                        .output_z_stb(medmult_ready[i][j][p]),
                        .output_z_ack(result_ack)
                    );
                end
                vector_add_reduce #(.k(k)) var (
                    .vector(medmatrix[i][j]),
                    .clk(clk),
                    .resetN(resetN),
                    .data_in_ready(medmult_ready[i][j]),
                    .data_out_ack(result_ack),
                    .result(omatrix_inner[i][j]),
                    .data_out_ready(result_ready_inner[i][j])
                );
            end
        end
    endgenerate
endmodule