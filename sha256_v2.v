module sha256_v2(
    input wire i_clk,
    input wire i_rst,
    input wire i_write,
    input wire [7:0] i_N, // số block 
    input wire [8:0] i_bit_miss, // số bit thiếu ở block cuối 
    input wire [31:0] i_data,
    output reg [31:0] o_data,
    output reg o_done,
    output reg [3:0] o_read
);
    parameter IDLE = 3'd0,
            GETDATA = 3'd1,
            PADDING = 3'd2, 
            INITIAL = 3'd3,
            COMPRESS = 3'd4,
            FINISH = 3'd5,  
            READ = 3'd6;

    // --- internal regs and sync stage for inputs ---
    reg i_write_reg;
    reg [31:0] i_data_reg;
    reg [8:0] i_bit_miss_reg;

    // rest of your regs
    reg [2:0] state, next_state;
    reg [31:0] data_use_reg [0:15];
    reg [31:0] a,b,c,d,e,f,g,h;
    reg [31:0] H [0:7];
    reg pad;
    reg output_pad2;
    reg cnt_j_en;
    reg cnt_i_en;
    reg clr_j;
    reg clr_i;
    reg clr_data;
    reg calc_w;
    wire [511:0] data_use;
    wire [511:0] padded_block;
    wire [31:0] k_j;
    wire [31:0] w_out;
    wire [7:0] counter_i;
    wire [6:0] counter_j;
    wire [4:0] counter_data;
    wire output_block_pad2 = output_pad2;
    wire w_enable = calc_w;
    
    // --- counters and modules (use i_write_reg for cnt_data_en) ---
    sha256_counter_j_v2 u_counter_j_v2(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .clr_j(clr_j),
        .cnt_j_en(cnt_j_en),
        .j(counter_j)
    );

    sha256_counter_i_v2 u_counter_i_v2(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .clr_i(clr_i),
        .cnt_i_en(cnt_i_en),
        .i(counter_i)
    );

    sha256_counter_data_v2 u_counter_data_v2(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .clr_data(clr_data),
        .cnt_data_en(i_write_reg), // use registered write
        .counter_data(counter_data)
    );
    
    sha256_padding_v2_top u_padding_v2_top(
        .i_data(data_use),
        .i_N(i_N),
        .output_block_pad2(output_block_pad2),
        .i_bit_miss(i_bit_miss_reg),
        .o_data_padding(padded_block)
    );

    sha256_scheduler_v2 u_scheduler_v2(
        .clk(i_clk),
        .rst(i_rst),
        .i_block(data_use),
        .i_enable(w_enable),
        .W_out(w_out)
    );

    sha256_functions_v2 u_functions_v2 (    
        .j(counter_j),
        .k_j(k_j)
    );

    // --- next state logic (use registered inputs) ---
    always @(*) begin
        clr_i    = 0;
        clr_j    = 0;
        clr_data = 0;
        cnt_i_en = 0;
        cnt_j_en = 0;
        next_state = state;
        case (next_state) 
            IDLE: begin
                clr_j = 1;
                clr_i = 1;
                if (i_write_reg) begin            // synchronized check
                    next_state = GETDATA;
                end
            end

            GETDATA: begin
                if (counter_data == 5'd16 ) begin
                    clr_data = 1;
                    if (counter_i == i_N-1) begin
                        next_state = PADDING;
                    end else next_state = INITIAL;
                end 
            end

            PADDING: begin
                next_state = INITIAL;
            end

            INITIAL: begin
                next_state = COMPRESS;
            end

            COMPRESS: begin
                cnt_j_en = 1;
                if (counter_j == 7'd64) begin
                    clr_j = 1;
                    cnt_j_en = 0;
                    cnt_i_en = 1;
                    next_state = FINISH; 
                end
            end

            FINISH: begin
                if (i_write_reg) begin          // synchronized check
                    next_state = GETDATA;
                end else begin
                    if (!pad && counter_i >= i_N) begin
                        next_state = READ;
                    end else if(pad) next_state = PADDING;
                end
            end

            READ: begin
                if (o_read == 4'd8) begin
                    next_state = IDLE;
                end
            end
            default: next_state = state;
        endcase
    end
    assign data_use = {
        data_use_reg[0], data_use_reg[1], data_use_reg[2], data_use_reg[3],
        data_use_reg[4], data_use_reg[5], data_use_reg[6], data_use_reg[7],
        data_use_reg[8], data_use_reg[9], data_use_reg[10], data_use_reg[11],
        data_use_reg[12], data_use_reg[13], data_use_reg[14], data_use_reg[15]
    };
    // --- main sequential block + sync inputs on posedge ---
    always@(posedge i_clk or negedge i_rst) begin
        if(!i_rst) begin
            // reset internal registers and also synced inputs
            i_write_reg <= 1'b0;
            i_data_reg  <= 32'b0;
            i_bit_miss_reg <= 9'd0;

            state <= IDLE;
            o_done <= 0;
            o_data <= 0;
            o_read <= 0;
            pad <= 0;
            output_pad2 <= 0;
            calc_w <= 0;
            data_use_reg [0]  <=  32'b0;
            data_use_reg [1]  <=  32'b0;
            data_use_reg [2]  <=  32'b0;
            data_use_reg [3]  <=  32'b0;
            data_use_reg [4]  <=  32'b0;
            data_use_reg [5]  <=  32'b0;
            data_use_reg [6]  <=  32'b0;
            data_use_reg [7]  <=  32'b0;
            data_use_reg [8]  <=  32'b0;
            data_use_reg [9]  <=  32'b0;
            data_use_reg [10] <=  32'b0;
            data_use_reg [11] <=  32'b0;
            data_use_reg [12] <=  32'b0;
            data_use_reg [13] <=  32'b0;
            data_use_reg [14] <=  32'b0;
            data_use_reg [15] <=  32'b0;
            H[0] <= 32'h6a09e667;
            H[1] <= 32'hbb67ae85;
            H[2] <= 32'h3c6ef372;
            H[3] <= 32'ha54ff53a;
            H[4] <= 32'h510e527f;
            H[5] <= 32'h9b05688c;
            H[6] <= 32'h1f83d9ab;
            H[7] <= 32'h5be0cd19;
        end else begin
            // --- sample inputs on clock (input flop) ---
            i_write_reg <= i_write;
            i_data_reg  <= i_data;
            i_bit_miss_reg <= i_bit_miss;

            state <= next_state;
            case(state)
                IDLE: begin
                    o_done <= 1;
                    output_pad2 <= 0;
                    a <= H[0]; b <= H[1];
                    c <= H[2]; d <= H[3];
                    e <= H[4]; f <= H[5];
                    g <= H[6]; h <= H[7];
                    if (i_write_reg) begin
                        data_use_reg[counter_data] <= i_data_reg;
                    end
                end
                
                GETDATA: begin
                    o_done <= 0;
                    if (i_write_reg) begin
                        data_use_reg[counter_data] <= i_data_reg;
                    end 
                    if (counter_data == 5'd16) begin
                        if (counter_i == i_N - 1) begin
                            pad <= (i_bit_miss_reg <= 9'd64);
                        end else begin
                            calc_w <= 1;
                        end
                    end
                end

                PADDING: begin
                    data_use_reg[0]  <= padded_block[511:480];
                    data_use_reg[1]  <= padded_block[479:448];
                    data_use_reg[2]  <= padded_block[447:416];
                    data_use_reg[3]  <= padded_block[415:384];
                    data_use_reg[4]  <= padded_block[383:352];
                    data_use_reg[5]  <= padded_block[351:320];
                    data_use_reg[6]  <= padded_block[319:288];
                    data_use_reg[7]  <= padded_block[287:256];
                    data_use_reg[8]  <= padded_block[255:224];
                    data_use_reg[9]  <= padded_block[223:192];
                    data_use_reg[10] <= padded_block[191:160];
                    data_use_reg[11] <= padded_block[159:128];
                    data_use_reg[12] <= padded_block[127:96];
                    data_use_reg[13] <= padded_block[95:64];
                    data_use_reg[14] <= padded_block[63:32];
                    data_use_reg[15] <= padded_block[31:0];
                    calc_w <= 1;
                    if (pad && o_done) begin
                        pad <= 0;
                    end
                end

                INITIAL: begin
                    a <= H[0]; b <= H[1];
                    c <= H[2]; d <= H[3];
                    e <= H[4]; f <= H[5];
                    g <= H[6]; h <= H[7];
                    o_done <= 0;
                end

                COMPRESS: begin 
                    calc_w <= 0;
                    if (counter_j < 7'd64) begin
                        a <= t1 + t2;
                        b <= a;
                        c <= b;
                        d <= c;
                        e <= d + t1;
                        f <= e;
                        g <= f;
                        h <= g;
                    end
                    else begin
                        o_done <= 1;
                        H[0] <= a + H[0];
                        H[1] <= b + H[1];
                        H[2] <= c + H[2];
                        H[3] <= d + H[3];
                        H[4] <= e + H[4];
                        H[5] <= f + H[5];
                        H[6] <= g + H[6];
                        H[7] <= h + H[7];
                        data_use_reg [0]  <=  32'b0;
                        data_use_reg [1]  <=  32'b0;
                        data_use_reg [2]  <=  32'b0;
                        data_use_reg [3]  <=  32'b0;
                        data_use_reg [4]  <=  32'b0;
                        data_use_reg [5]  <=  32'b0;
                        data_use_reg [6]  <=  32'b0;
                        data_use_reg [7]  <=  32'b0;
                        data_use_reg [8]  <=  32'b0;
                        data_use_reg [9]  <=  32'b0;
                        data_use_reg [10] <=  32'b0;
                        data_use_reg [11] <=  32'b0;
                        data_use_reg [12] <=  32'b0;
                        data_use_reg [13] <=  32'b0;
                        data_use_reg [14] <=  32'b0;
                        data_use_reg [15] <=  32'b0;
                    end 
                end

                FINISH: begin
                    if (i_write_reg ) begin
                        data_use_reg[counter_data] <= i_data_reg;
                    end else begin
                        if (pad) begin
                            output_pad2 <= 1;
                        end
                    end
                end

                READ: begin
                    case(o_read)
                        4'd1: o_data <= H[0];
                        4'd2: o_data <= H[1];
                        4'd3: o_data <= H[2];
                        4'd4: o_data <= H[3];
                        4'd5: o_data <= H[4];
                        4'd6: o_data <= H[5];
                        4'd7: o_data <= H[6];
                        4'd8: o_data <= H[7];
                        default: o_data <= 0;
                    endcase
                    if (o_read == 4'd8) begin
                        o_read <= 4'd0;
                    end else o_read <= o_read + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // ... same functions and t1/t2 wiring as before ...
    function [31:0] func_ch;
        input [31:0] x, y, z;
        begin
            func_ch = (x & y) ^ (~x & z);
    end
    endfunction

    function [31:0] func_maj;
        input [31:0] x, y, z;
        begin
            func_maj = (x & y) ^ (x & z) ^ (y & z);
        end
    endfunction

    function [31:0] func_sigma0;
        input [31:0] x;
        begin
            func_sigma0 = {x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]};
        end
    endfunction

    function [31:0] func_sigma1;
        input [31:0] x;
        begin
            func_sigma1 = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]};
        end
    endfunction
    wire [31:0] ch   = func_ch(e, f, g);
    wire [31:0] maj  = func_maj(a, b, c);
    wire [31:0] sig0 = func_sigma0(a);
    wire [31:0] sig1 = func_sigma1(e);
    wire [31:0] t1 = h + sig1 + ch + k_j + w_out;
    wire [31:0] t2 = sig0 + maj;
    reg[8*8:0] DISPLAY;
    always@(*) begin
        case(state) 
            IDLE: DISPLAY = "IDLE";
            GETDATA: DISPLAY = "GETDATA";
            PADDING: DISPLAY = "PADDING";
            INITIAL: DISPLAY = "INITIAL";
            COMPRESS: DISPLAY = "COMPRESS";
            FINISH: DISPLAY = "FINISH";
            READ: DISPLAY = "READ";
        endcase
    end
endmodule


