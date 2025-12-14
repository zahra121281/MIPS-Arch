`timescale 1ns/1ns
module ForwardingUnit(
    input RegWrite_MEM,
    input RegWrite_WB,
    input [4:0] Rd_MEM,
    input [4:0] Rd_WB,
    input [4:0] Rs_EXE,
    input [4:0] Rt_EXE,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    always @(*) begin
        // Forwarding A (Rs)
        if (RegWrite_MEM && (Rd_MEM != 0) && (Rd_MEM == Rs_EXE))
            ForwardA = 2'b10; 
        else if (RegWrite_WB && (Rd_WB != 0) && (Rd_WB == Rs_EXE))
            ForwardA = 2'b01; 
        else
            ForwardA = 2'b00; 
        // Forwarding B (Rt)
        if (RegWrite_MEM && (Rd_MEM != 0) && (Rd_MEM == Rt_EXE))
            ForwardB = 2'b10;
        else if (RegWrite_WB && (Rd_WB != 0) && (Rd_WB == Rt_EXE))
            ForwardB = 2'b01;
        else
            ForwardB = 2'b00;
    end
endmodule