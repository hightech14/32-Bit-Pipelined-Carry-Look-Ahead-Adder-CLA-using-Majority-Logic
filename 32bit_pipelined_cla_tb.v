module tb_pipelined_cla_debug;
    reg clk;
    reg rst_n;
    reg [31:0] A, B;
    reg Cin;
    wire [31:0] Sum;
    wire Cout;

    // Instantiate the Unit Under Test (UUT)
    pipelined_cla_32bit uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .A(A), 
        .B(B), 
        .Cin(Cin), 
        .Sum(Sum), 
        .Cout(Cout)
    );

    // Clock Generation: 2.99ns period as per paper specs [cite: 136]
    initial clk = 0;
    always #1.5 clk = ~clk;

    initial begin
        // --- PRE-TEST SETUP ---
        $display("Starting Simulation...");
        rst_n = 0; A = 0; B = 0; Cin = 0;
        #10 rst_n = 1; // Release reset and clear pipeline [cite: 151]
        
        // --- TEST CASE 1: Simple Addition (No Carry) ---
        // Verifies basic logic and pipeline movement
        @(posedge clk);
        A = 32'h1111_1111; B = 32'h2222_2222; Cin = 0;
        repeat(4) @(posedge clk); // Wait 4 cycles for 4-stage pipeline [cite: 84]
        #1; $display("TC1 (Simple): Sum=%h, Cout=%b (Expected: 33333333, 0)", Sum, Cout);

        // --- TEST CASE 2: Carry Propagation Between Stages ---
        // Verifies if carry moves correctly from Stage 1 to Stage 2, etc.
        @(posedge clk);
        A = 32'h0000_00FF; B = 32'h0000_0001; Cin = 0;
        repeat(4) @(posedge clk);
        #1; $display("TC2 (Carry): Sum=%h, Cout=%b (Expected: 00000100, 0)", Sum, Cout);

        // --- TEST CASE 3: Maximum Value (All Ones) ---
        // Verifies the "Edge Case" mentioned in the paper [cite: 118]
        @(posedge clk);
        A = 32'hFFFF_FFFF; B = 32'h0000_0000; Cin = 1;
        repeat(4) @(posedge clk);
        #1; $display("TC3 (All 1s): Sum=%h, Cout=%b (Expected: 00000000, 1)", Sum, Cout);

        // --- TEST CASE 4: Alternating Bits ---
        // Verifies switching activity and majority logic stability [cite: 118]
        @(posedge clk);
        A = 32'hAAAA_AAAA; B = 32'h5555_5555; Cin = 0;
        repeat(4) @(posedge clk);
        #1; $display("TC4 (Alt): Sum=%h, Cout=%b (Expected: FFFFFFFF, 0)", Sum, Cout);

        $display("Simulation Finished.");
        $finish;
    end
endmodule 
₹