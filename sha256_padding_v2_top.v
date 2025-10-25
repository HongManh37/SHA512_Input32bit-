
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
        if (valid_bits < 10'd448) begin
            o_data_padding[63:0] = length_data;
            o_data_padding[512'd511 - valid_bits] = 1'b1;
        end else if (valid_bits < 10'd512) begin
            o_data_padding[512'd511 - valid_bits] = 1'b1;
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

