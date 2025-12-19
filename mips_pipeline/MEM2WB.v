`timescale 1ns/1ns

module MEM2WB(
    input               clk,
    input               rst,

    // ---------------- FROM MEM STAGE ----------------
    input       [4:0]   write_reg_in,      // write_reg_mem
    input       [31:0]  AluResIn,          // alu_result_mem
    input               MemtoRegIn, 
    input       [31:0]  read_data_In,
    input       [31:0]  pc_in,             // pc_mem
    input               DatacIn,           // DataC_mem
    input               RegwriteIn,
    // ---------------- TO WB STAGE -------------------
    output reg  [4:0]   write_reg_out,     // write_reg_wb
    output reg  [31:0]  pc_out,            // pc_wb
    output reg  [31:0]  AluResOut,         // alu_result_wb
    output reg          MemtoRegOut,       // MemtoReg_wb
    output reg          DatacOut ,          // DataC_wb
    output reg   [31:0] read_data_out,
    output reg          RegwriteOut
);

    //======================================================
    //  Pipeline Registers (synchronous)
    //======================================================
    always @(posedge clk) begin
        if (rst) begin
            write_reg_out   <= 5'b0;
            pc_out          <= 32'b0;
            AluResOut       <= 32'b0;
            MemtoRegOut     <= 1'b0;
            DatacOut        <= 1'b0;
            read_data_out   <= 32'b0; 
        end else begin
            write_reg_out   <= write_reg_in;
            pc_out          <= pc_in;
            AluResOut       <= AluResIn;
            MemtoRegOut     <= MemtoRegIn;
            DatacOut        <= DatacIn;
            read_data_out   <= read_data_In; 
            RegwriteOut     <= RegwriteIn;
        end
    end

endmodule
