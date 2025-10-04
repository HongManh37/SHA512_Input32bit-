module sha256_functions_v2 (
    input  wire [6:0]  j,
    output wire [31:0] k_j
);
    assign k_j   = func_k(j);
    function [31:0] func_k;
        input [6:0] j;
        begin
            case (j)
                7'd0 :  func_k = 32'h428a2f98;
                7'd1 :  func_k = 32'h71374491;
                7'd2 :  func_k = 32'hb5c0fbcf;
                7'd3 :  func_k = 32'he9b5dba5;
                7'd4 :  func_k = 32'h3956c25b;
                7'd5 :  func_k = 32'h59f111f1;
                7'd6 :  func_k = 32'h923f82a4;
                7'd7 :  func_k = 32'hab1c5ed5;
                7'd8 :  func_k = 32'hd807aa98;
                7'd9 :  func_k = 32'h12835b01;
                7'd10:  func_k = 32'h243185be;
                7'd11:  func_k = 32'h550c7dc3;
                7'd12:  func_k = 32'h72be5d74;
                7'd13:  func_k = 32'h80deb1fe;
                7'd14:  func_k = 32'h9bdc06a7;
                7'd15:  func_k = 32'hc19bf174;
                7'd16:  func_k = 32'he49b69c1;
                7'd17:  func_k = 32'hefbe4786;
                7'd18:  func_k = 32'h0fc19dc6;
                7'd19:  func_k = 32'h240ca1cc;
                7'd20:  func_k = 32'h2de92c6f;
                7'd21:  func_k = 32'h4a7484aa;
                7'd22:  func_k = 32'h5cb0a9dc;
                7'd23:  func_k = 32'h76f988da;
                7'd24:  func_k = 32'h983e5152;
                7'd25:  func_k = 32'ha831c66d;
                7'd26:  func_k = 32'hb00327c8;
                7'd27:  func_k = 32'hbf597fc7;
                7'd28:  func_k = 32'hc6e00bf3;
                7'd29:  func_k = 32'hd5a79147;
                7'd30:  func_k = 32'h06ca6351;
                7'd31:  func_k = 32'h14292967;
                7'd32:  func_k = 32'h27b70a85;
                7'd33:  func_k = 32'h2e1b2138;
                7'd34:  func_k = 32'h4d2c6dfc;
                7'd35:  func_k = 32'h53380d13;
                7'd36:  func_k = 32'h650a7354;
                7'd37:  func_k = 32'h766a0abb;
                7'd38:  func_k = 32'h81c2c92e;
                7'd39:  func_k = 32'h92722c85;
                7'd40:  func_k = 32'ha2bfe8a1;
                7'd41:  func_k = 32'ha81a664b;
                7'd42:  func_k = 32'hc24b8b70;
                7'd43:  func_k = 32'hc76c51a3;
                7'd44:  func_k = 32'hd192e819;
                7'd45:  func_k = 32'hd6990624;
                7'd46:  func_k = 32'hf40e3585;
                7'd47:  func_k = 32'h106aa070;
                7'd48:  func_k = 32'h19a4c116;
                7'd49:  func_k = 32'h1e376c08;
                7'd50:  func_k = 32'h2748774c;
                7'd51:  func_k = 32'h34b0bcb5;
                7'd52:  func_k = 32'h391c0cb3;
                7'd53:  func_k = 32'h4ed8aa4a;
                7'd54:  func_k = 32'h5b9cca4f;
                7'd55:  func_k = 32'h682e6ff3;
                7'd56:  func_k = 32'h748f82ee;
                7'd57:  func_k = 32'h78a5636f;
                7'd58:  func_k = 32'h84c87814;
                7'd59:  func_k = 32'h8cc70208;
                7'd60:  func_k = 32'h90befffa;
                7'd61:  func_k = 32'ha4506ceb;
                7'd62:  func_k = 32'hbef9a3f7;
                default:func_k = 32'hc67178f2;
            endcase
        end
    endfunction

endmodule
