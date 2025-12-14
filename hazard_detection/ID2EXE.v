`timescale 1ns/1ns
// ID2EXE.v
// Pipeline register between ID and EXE stages
module ID2EXE(
    // global
    input                   clk,
    input                   rst,
    input                   flush,

   
    input       [4:0]       RsIn,  
    input       [4:0]       RtIn,  
    
   
    output reg  [4:0]       RsOut,
    output reg  [4:0]       RtOut,

   
    input       [31:0]      inst_extended_in,   
    input       [31:0]      reg_data1_in,        
    input       [31:0]      reg_data2_in,        
    input       [4:0]       reg1_in,             
    input       [4:0]       reg2_in,             
    input       [1:0]       RegDstIn,
    input       [3:0]       AluOp_in,            
    input                   AluSrcIn,
    input                   AluSrc1In,
    input                   RegwriteIn,
    input       [4:0]       shamnt_in,            
    input                   MemWriteIn,
    input                   MemReadIn,
    input                   MemtoRegIn,
    input       [31:0]      PCplus4In,
    input                   DatacIn,              

   
    output reg  [3:0]       AluOp_out,            
    output reg              DatacOut,             
    output reg  [31:0]      reg_data1_out,        
    output reg  [31:0]      reg_data2_out,        
    output reg  [31:0]      inst_extended_out,    
    output reg  [1:0]       RegDstOut,
    output reg  [4:0]       reg1_out,             
    output reg  [4:0]       reg2_out,             
    output reg              RegwriteOut,
    output reg  [4:0]       shamnt_out,           
    output reg              MemWriteOut,
    output reg              MemReadOut,
    output reg              MemtoRegOut,
    output reg  [31:0]      PCplus4OUt,
    output reg              AluSrcOut,
    output reg              AluSrc1Out
);

    always @(posedge clk) begin
        if (rst || flush) begin 
           
            RegwriteOut     <= 1'b0;
            MemWriteOut     <= 1'b0;
            MemReadOut      <= 1'b0;
            
            
            AluOp_out       <= 4'b0000;
            DatacOut        <= 1'b0;
            reg_data1_out   <= 32'b0;
            reg_data2_out   <= 32'b0;
            inst_extended_out <= 32'b0;
            RegDstOut       <= 2'b00;
            reg1_out        <= 5'b0;
            reg2_out        <= 5'b0;
            shamnt_out      <= 5'b0; 
            MemtoRegOut     <= 1'b0;
            PCplus4OUt      <= 32'b0;
            AluSrcOut       <= 1'b0;
            AluSrc1Out      <= 1'b0;
            
           
            RsOut           <= 5'b0;
            RtOut           <= 5'b0;
            
        end else begin

            AluOp_out       <= AluOp_in;
            DatacOut        <= DatacIn;
            reg_data1_out   <= reg_data1_in;
            reg_data2_out   <= reg_data2_in;
            inst_extended_out <= inst_extended_in;
            RegDstOut       <= RegDstIn;
            reg1_out        <= reg1_in;
            reg2_out        <= reg2_in;
            
            RegwriteOut     <= RegwriteIn;
            shamnt_out      <= shamnt_in; 

            MemWriteOut     <= MemWriteIn;
            MemReadOut      <= MemReadIn;
            MemtoRegOut     <= MemtoRegIn;
            PCplus4OUt      <= PCplus4In;
            AluSrcOut       <= AluSrcIn;
            AluSrc1Out      <= AluSrc1In;
            
           
            RsOut           <= RsIn;
            RtOut           <= RtIn;
        end
    end

endmodule