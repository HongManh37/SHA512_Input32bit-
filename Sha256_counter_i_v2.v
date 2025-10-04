module sha256_counter_i_v2 (
    input wire        i_clk,
    input wire        i_rst,
    input wire        clr_i,
    input wire        cnt_i_en,
    output reg [7:0]  i
);


    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            i <= 0;
        end else begin
            if (clr_i) i <= 0;
            else if (cnt_i_en) i <= i + 8'd1;
            else i <= i;
        end
    end

endmodule
