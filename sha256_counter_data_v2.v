module sha256_counter_data_v2 (
    input wire        i_clk,
    input wire        i_rst,
    input wire        clr_data,
    input wire        cnt_data_en,
    output reg [4:0]  counter_data
);
    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            counter_data <= 0;
        end else begin
            if (clr_data) counter_data <= 0;
            else if (cnt_data_en) counter_data <= counter_data + 5'd1;
            else counter_data <= counter_data;
        end
    end

endmodule
