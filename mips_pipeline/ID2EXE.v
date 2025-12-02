
`timescale 1ns/1ns
// ID2EXE.v
// Pipeline register between ID and EXE stages
module ID2EXE(
    // global
    input                   clk,
    input                   rst,

    // inputs (from ID stage / controller)
    input       [31:0]      inst_extended_in,    
    input       [31:0]      reg_data1_in,        
    input       [31:0]      reg_data2_in,        
    input       [4:0]       reg1_in,             // rt
    input       [4:0]       reg2_in,             // rd
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

    // outputs (to EXE stage)
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
        if (rst) begin
            // clear all pipeline outputs on reset
            AluOp_out           <= 4'b0000;
            DatacOut            <= 1'b0;
            reg_data1_out       <= 32'b0;
            reg_data2_out       <= 32'b0;
            inst_extended_out   <= 32'b0;
            RegDstOut           <= 2'b00;
            reg1_out            <= 5'b0;
            reg2_out            <= 5'b0;
            RegwriteOut         <= 1'b0;

            shamnt_out          <= 5'b0; 

            MemWriteOut         <= 1'b0;
            MemReadOut          <= 1'b0;
            MemtoRegOut         <= 1'b0;
            PCplus4OUt          <= 32'b0;
            AluSrcOut           <= 1'b0;
            AluSrc1Out          <= 1'b0;
        end else begin
            // normal capture
            AluOp_out           <= AluOp_in;
            DatacOut            <= DatacIn;
            reg_data1_out       <= reg_data1_in;
            reg_data2_out       <= reg_data2_in;
            inst_extended_out   <= inst_extended_in;
            RegDstOut           <= RegDstIn;
            reg1_out            <= reg1_in;
            reg2_out            <= reg2_in;
            
            RegwriteOut         <= RegwriteIn;
            shamnt_out          <= shamnt_in; 

            MemWriteOut         <= MemWriteIn;
            MemReadOut          <= MemReadIn;
            MemtoRegOut         <= MemtoRegIn;
            PCplus4OUt          <= PCplus4In;
            AluSrcOut           <= AluSrcIn;
            AluSrc1Out          <= AluSrc1In;
        end
    end

endmodule

// `timescale 1ns/1ns
// // ID2EXE.v
// // Pipeline register between ID and EXE stages
// // Keeps all signal names and widths as requested.

// module ID2EXE(
//     // global
//     input                   clk,
//     input                   rst,

//     // inputs (from ID stage / controller)
//     input       [31:0]      inst_extended_in,    // extended instruction / immediate
//     input       [31:0]      reg_data1_in,        // read_data1_reg (from regfile)
//     input       [31:0]      reg_data2_in,        // read_data2_reg (from regfile)
//     input       [4:0]       reg1_in,             // instruction_id[20:16] (rt)
//     input       [4:0]       reg2_in,             // instruction_id[15:11] (rd)
//     input       [1:0]       RegDstIn,
//     input       [3:0]       AluOp_in,            // AluOperation_id
//     input                   AluSrcIn,
//     input                   AluSrc1In,
//     input                   MemWriteIn,
//     input                   MemReadIn,
//     input                   MemtoRegIn,
//     input       [31:0]      PCplus4In,
//     input                   DatacIn              // DataC_id (whatever semantics you use)
//     // NOTE: if you have additional control signals, add them here following same naming
//     ,
//     // outputs (to EXE stage)
//     output reg  [3:0]       AluOp_out,           // AluOperation_exe
//     output reg              DatacOut,            // DataC_exe
//     output reg  [31:0]      reg_data1_out,       // reg_data1_exe
//     output reg  [31:0]      reg_data2_out,       // reg_data2_exe
//     output reg  [31:0]      inst_extended_out,   // inst_extended_exe
//     output reg  [1:0]       RegDstOut,
//     output reg  [4:0]       reg1_out,            // rt_exe
//     output reg  [4:0]       reg2_out,            // rd_exe
//     output reg              MemWriteOut,
//     output reg              MemReadOut,
//     output reg              MemtoRegOut,
//     output reg  [31:0]      PCplus4OUt,
//     output reg              AluSrcOut,
//     output reg              AluSrc1Out
// );

//     // Synchronous pipeline register behavior
//     // On reset: zero/clear outputs (safe default)
//     // On posedge clk: capture inputs to outputs

//     always @(posedge clk) begin
//         if (rst) begin
//             // clear all pipeline outputs on reset
//             AluOp_out           <= 4'b0000;
//             DatacOut            <= 1'b0;
//             reg_data1_out       <= 32'b0;
//             reg_data2_out       <= 32'b0;
//             inst_extended_out   <= 32'b0;
//             RegDstOut           <= 2'b00;
//             reg1_out            <= 5'b0;
//             reg2_out            <= 5'b0;
//             MemWriteOut         <= 1'b0;
//             MemReadOut          <= 1'b0;
//             MemtoRegOut         <= 1'b0;
//             PCplus4OUt          <= 32'b0;
//             AluSrcOut           <= 1'b0;
//             AluSrc1Out          <= 1'b0;
//         end else begin
//             // normal capture
//             AluOp_out           <= AluOp_in;
//             DatacOut            <= DatacIn;
//             reg_data1_out       <= reg_data1_in;
//             reg_data2_out       <= reg_data2_in;
//             inst_extended_out   <= inst_extended_in;
//             RegDstOut           <= RegDstIn;
//             reg1_out            <= reg1_in;
//             reg2_out            <= reg2_in;
//             MemWriteOut         <= MemWriteIn;
//             MemReadOut          <= MemReadIn;
//             MemtoRegOut         <= MemtoRegIn;
//             PCplus4OUt          <= PCplus4In;
//             AluSrcOut           <= AluSrcIn;
//             AluSrc1Out          <= AluSrc1In;
//         end
//     end

// endmodule
