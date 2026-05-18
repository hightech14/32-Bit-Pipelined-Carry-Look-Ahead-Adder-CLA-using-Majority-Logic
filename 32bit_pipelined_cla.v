(* keep_hierarchy = "yes" *)
module cla_4bit_majority(
    input [3:0] A, B, input Cin,
    output [3:0] S, output Cout
);
    wire [3:0] G = A & B; 
    wire [3:0] P = A | B; 
    wire [3:0] C;
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]); // Majority Logic
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);
    assign Cout = G[3] | (P[3] & C[3]); 
    assign S = A ^ B ^ C;
endmodule

module pipelined_cla_32bit(
    input clk, input rst_n,
    input [31:0] A, B, input Cin,
    output reg [31:0] Sum, output reg Cout
);
    // Pipeline registers for 4-stage architecture
    (* DONT_TOUCH = "yes" *) reg [31:8]  a1, b1;
    (* DONT_TOUCH = "yes" *) reg [31:16] a2, b2;
    (* DONT_TOUCH = "yes" *) reg [31:24] a3, b3;
    (* DONT_TOUCH = "yes" *) reg [7:0] s1_reg;
    (* DONT_TOUCH = "yes" *) reg [15:0] s2_reg;
    (* DONT_TOUCH = "yes" *) reg [23:0] s3_reg;
    (* DONT_TOUCH = "yes" *) reg c1_reg, c2_reg, c3_reg;

    wire [7:0] s0_w, s1_w, s2_w, s3_w;
    wire co0_w, co1_w, co2_w, co3_w;
    wire m0_w, m1_w, m2_w, m3_w;

    // Stage logic instances
    cla_4bit_majority m0(A[3:0], B[3:0], Cin, s0_w[3:0], m0_w);
    cla_4bit_majority m1(A[7:4], B[7:4], m0_w, s0_w[7:4], co0_w);
    cla_4bit_majority m2(a1[11:8], b1[11:8], c1_reg, s1_w[3:0], m1_w);
    cla_4bit_majority m3(a1[15:12], b1[15:12], m1_w, s1_w[7:4], co1_w);
    cla_4bit_majority m4(a2[19:16], b2[19:16], c2_reg, s2_w[3:0], m2_w);
    cla_4bit_majority m5(a2[23:20], b2[23:20], m2_w, s2_w[7:4], co2_w);
    cla_4bit_majority m6(a3[27:24], b3[27:24], c3_reg, s3_w[3:0], m3_w);
    cla_4bit_majority m7(a3[31:28], b3[31:28], m3_w, s3_w[7:4], co3_w);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a1 <= 0; b1 <= 0; s1_reg <= 0; c1_reg <= 0;
            a2 <= 0; b2 <= 0; s2_reg <= 0; c2_reg <= 0;
            a3 <= 0; b3 <= 0; s3_reg <= 0; c3_reg <= 0;
            Sum <= 0; Cout <= 0;
        end else begin
            a1 <= A[31:8]; b1 <= B[31:8]; s1_reg <= s0_w; c1_reg <= co0_w;
            a2 <= a1[31:16]; b2 <= b1[31:16]; s2_reg <= {s1_w, s1_reg}; c2_reg <= co1_w;
            a3 <= a2[31:24]; b3 <= b2[31:24]; s3_reg <= {s2_w, s2_reg}; c3_reg <= co2_w;
            
            // Registered Output
            Sum <= {s3_w, s3_reg}; 
            Cout <= co3_w;
        end
    end
endmodule 