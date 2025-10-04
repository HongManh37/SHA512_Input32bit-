module sha256_scheduler_v2 (
    input wire clk,
    input wire rst,
    input wire [511:0] i_block,
    input wire i_enable,
    output reg [31:0] W_out
);

    parameter  IDLE = 2'd0,
               LOAD = 2'd1,
               GEN  = 2'd2; 
    reg[1:0] state;
    reg [31:0] w_mem [0:15];
    wire [31:0] w_new;
    reg [5:0] j;
    assign w_new = sigma1(w_mem[14]) + w_mem[9] + sigma0(w_mem[1]) + w_mem[0];


    function [31:0] sigma0(input [31:0] x);
        sigma0 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ (x >> 3);
    endfunction

    function [31:0] sigma1(input [31:0] x);
        sigma1 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ (x >> 10);
    endfunction

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            j <= 0;
            W_out <= 0;
            w_mem[1] <= 0;
            w_mem[2] <= 0;
            w_mem[3] <= 0;
            w_mem[4] <= 0;
            w_mem[5] <= 0;
            w_mem[6] <= 0;
            w_mem[7] <= 0;
            w_mem[8] <= 0;
            w_mem[9] <= 0;
            w_mem[10] <= 0;
            w_mem[11] <= 0;
            w_mem[12] <= 0;
            w_mem[13] <= 0;
            w_mem[14] <= 0;
            w_mem[15] <= 0;
        end else begin
            case (state)
                IDLE: begin
                    j <= 0;
                    W_out <= 0;
                    if (i_enable) begin
                        state <= LOAD;
                        w_mem[j] <= i_block[512'd511 - j*512'd32 -: 512'd32];
                        W_out <= i_block[512'd511 - j*512'd32 -: 512'd32];
                        j <= j + 1;
                    end
                end

                LOAD: begin
                    w_mem[j] <= i_block[512'd511 - j*512'd32 -: 512'd32];
                    W_out <= i_block[512'd511 - j*512'd32 -: 512'd32];
                    if (j == 6'd15) begin
                        state <= GEN;
                    end
                    j <= j + 1;
                end

                GEN: begin
                    W_out <= w_new;
                    w_mem[0] <= w_mem[1];
                    w_mem[1] <= w_mem[2];
                    w_mem[2] <= w_mem[3];
                    w_mem[3] <= w_mem[4];
                    w_mem[4] <= w_mem[5];
                    w_mem[5] <= w_mem[6];
                    w_mem[6] <= w_mem[7];
                    w_mem[7] <= w_mem[8];
                    w_mem[8] <= w_mem[9];
                    w_mem[9] <= w_mem[10];
                    w_mem[10] <= w_mem[11];
                    w_mem[11] <= w_mem[12];
                    w_mem[12] <= w_mem[13];
                    w_mem[13] <= w_mem[14];
                    w_mem[14] <= w_mem[15];
                    w_mem[15] <= w_new;
                    if (j == 6'd63) begin
                        state <= IDLE;
                    end else begin
                        j <= j + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
    
    reg[8*8:0] DISPLAY;
    always@(*) begin
        case(state) 
            IDLE: DISPLAY = "IDLE";
            LOAD: DISPLAY = "LOAD";
            GEN: DISPLAY = "GEN";
        endcase
    end
endmodule
