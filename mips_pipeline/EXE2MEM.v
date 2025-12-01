`timescale 1ns/1ns

module EXE2MEM(
    input               clk,
    input               rst,

    // ---------------- FROM EXE STAGE ----------------
    input       [4:0]   write_reg_in,      // write_reg_exe
    input       [31:0]  WriteDataIn,       // write_data_exe
    input               MemtoRegIn,        // MemtoReg_exe
    input               MemWriteIn,        // MemWrite_exe
    input               MemReadIn,         // MemRead_exe   (must be included)
    input       [31:0]  AluResIn,          // alu_result_exe
    input               DatacIn,           // DataC_exe
    input       [31:0]  pc_in,             // pc_exe

    // ---------------- TO MEM STAGE ----------------
    output reg  [4:0]   write_reg_out,     // write_reg_mem
    output reg  [31:0]  pc_out,            // pc_mem
    output reg          MemWriteOut,       // MemWrite_mem
    output reg          MemReadOut,        // MemRead_mem
    output reg  [31:0]  AluResOut,         // alu_result_mem
    output reg          MemtoRegOut,       // MemtoReg_mem
    output reg          DatacOut,          // DataC_mem
    output reg  [31:0]  WriteDataOut       // write_data_mem
);

    //======================================================
    //  Pipeline Registers (synchronous)
    //======================================================
    always @(posedge clk) begin
        if (rst) begin
            write_reg_out   <= 5'b0;
            pc_out          <= 32'b0;
            MemWriteOut     <= 1'b0;
            MemReadOut      <= 1'b0;
            AluResOut       <= 32'b0;
            MemtoRegOut     <= 1'b0;
            DatacOut        <= 1'b0;
            WriteDataOut    <= 32'b0;
        end else begin
            write_reg_out   <= write_reg_in;
            pc_out          <= pc_in;
            MemWriteOut     <= MemWriteIn;
            MemReadOut      <= MemReadIn;
            AluResOut       <= AluResIn;
            MemtoRegOut     <= MemtoRegIn;
            DatacOut        <= DatacIn;
            WriteDataOut    <= WriteDataIn;
        end
    end

endmodule
