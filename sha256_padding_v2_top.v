// module sha256_padding_v2_top (
//     input  wire [511:0] i_data,
//     input  wire         output_block_pad2,
//     input  wire [7:0]   i_N,
//     input  wire [8:0]   i_bit_miss,
//     output wire [511:0] o_data_padding
// );
//     wire [9:0] valid_bits = 10'd512 - i_bit_miss;
//     wire [63:0] length_data = ((i_N - 1) * 64'd512 + valid_bits);

//     wire [511:0] block_case1, block_case2, block_case3;

//     sha256_padding_case1_v2 u_case1 (
//         .i_data(i_data), .i_bit_miss(i_bit_miss),
//         .length_data(length_data), .o_block(block_case1)
//     );

//     sha256_padding_case2_v2 u_case2 (
//         .i_data(i_data), .i_bit_miss(i_bit_miss),
//         .length_data(length_data),
//         .output_block_pad2(output_block_pad2),
//         .o_block(block_case2)
//     );

//     sha256_padding_case3_v2 u_case3 (
//         .i_data(i_data), .length_data(length_data),
//         .output_block_pad2(output_block_pad2),
//         .o_block(block_case3)
//     );

//     assign o_data_padding = (valid_bits < 10'd448)  ? block_case1 :
//                             (valid_bits < 10'd512)  ? block_case2 :
//                                                        block_case3;

// endmodule

module sha256_padding_v2_top (
    input  wire [511:0] i_data,
    input  wire         output_block_pad2,
    input  wire [7:0]   i_N,
    input  wire [8:0]   i_bit_miss,
    output reg  [511:0] o_data_padding
);

    wire [9:0] valid_bits = 10'd512 - i_bit_miss;
    wire [63:0] length_data = ((i_N - 1) * 64'd512 + valid_bits);
    always @(*) begin
        o_data_padding = i_data & ({512{1'b1}} << i_bit_miss);
        if (valid_bits < 10'd512) o_data_padding[512'd511 - valid_bits] = 1'b1;
        
        if (valid_bits < 10'd448) begin
            o_data_padding[63:0] = length_data;
        end else if (valid_bits < 10'd512) begin
            if (output_block_pad2) begin
                o_data_padding = {448'd0, length_data};
            end
        end else begin
            if (output_block_pad2) begin
                o_data_padding = {1'b1, 447'd0, length_data};
            end
        end
    end

endmodule

