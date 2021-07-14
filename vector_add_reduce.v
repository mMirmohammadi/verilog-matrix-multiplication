module vector_add_reduce #(
    parameter k = 2
) (
    input [k * 32 - 1:0] vector,
    input clk,
    input resetN,
    input [k - 1:0] data_in_ready,
    input data_out_ack,
    output [31:0] result,
    output data_out_ready
);
    wire [(k/2) * 32 - 1:0] resvec;
    // wire [0:k/2 - 1] med_data_out_ack;
    wire [k/2 - 1:0] med_data_out_ready;
    wire [31:0] vector_inner [0:k - 1];
    wire mat1_ack [0:k - 1];
    wire mat2_ack [0:k - 1];

    genvar i;
    generate
        for (i = 0; i < k; i = i + 1) begin
            assign vector_inner[i] = vector[(i + 1) * 32 - 1 : i * 32];
        end
        for (i = 0; i < k - 1; i = i + 2) begin
            adder a(
                .clk(clk),
                .rst(resetN), 
                .input_a(vector_inner[i]), 
                .input_b(vector_inner[i + 1]),
                .output_z_ack(data_out_ack),
                .output_z(resvec[(i / 2 + 1) * 32 - 1:(i/2) * 32]),
                .output_z_stb(med_data_out_ready[i / 2]),
                .input_a_stb(data_in_ready[i]),
                .input_a_ack(mat1_ack[i]),
                .input_b_stb(data_in_ready[i + 1]),
                .input_b_ack(mat2_ack[i])
            );
        end
        if (k > 1) begin
            vector_add_reduce #(
                .k(k / 2)
            ) var (
                .vector(resvec),
                .clk(clk),
                .resetN(resetN),
                .data_in_ready(med_data_out_ready),
                .data_out_ack(data_out_ack),
                .result(result),
                .data_out_ready(data_out_ready)
            );
        end 
        else begin
            assign result = vector;
            assign data_out_ready = data_in_ready;
        end
    endgenerate
endmodule