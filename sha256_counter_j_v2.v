module sha256_counter_j_v2 (
    input wire        i_clk,
    input wire        i_rst,
    input wire        clr_j,
    input wire        cnt_j_en,
    output reg [6:0]  j
);
    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            j <= 0;
        end else begin
            if (clr_j) j <= 0;
            else if (cnt_j_en) j <= j + 7'd1;
            else j <= j;
        end
    end

endmodule
