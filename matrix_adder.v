module matrix_adder #(
    parameter k = 2
) (
    input [k * k * 32 - 1:0] i1matrix,
    input [k * k * 32 - 1:0] i2matrix,
    input clk,
    input resetN,
    input load,
    input result_ack,
    output [k * k * 32 - 1:0] omatrix,
    output [k * k - 1:0] result_ready
);

    wire [31:0] i1matrix_inner [0:k - 1][0:k - 1];
    wire [31:0] i2matrix_inner [0:k - 1][0:k - 1];
    wire [31:0] omatrix_inner [0:k - 1][0:k - 1];
    wire result_ready_inner [0:k - 1][0:k - 1];
    wire mat1_ack [0:k - 1][0:k - 1];
    wire mat2_ack [0:k - 1][0:k - 1];

    genvar i, j;
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
                adder a(
                    .clk(clk),
                    .rst(resetN), 
                    .input_a(i1matrix_inner[i][j]), 
                    .input_b(i2matrix_inner[i][j]),
                    .output_z_ack(result_ack),
                    .output_z(omatrix_inner[i][j]),
                    .output_z_stb(result_ready_inner[i][j]),
                    .input_a_stb(load),
                    .input_a_ack(mat1_ack[i][j]),
                    .input_b_stb(load),
                    .input_b_ack(mat2_ack[i][j])
                );
            end
        end
    endgenerate
endmodule