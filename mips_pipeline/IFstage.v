`timescale 1ns/1ns

module IFstage (
    clk, 
    rst, 
    out_pc,
    // branch_adder, // from id
    // jmp_addr, // from id
    // Jmp, // cntrl
    // and_z_b, // cntrl
    // address_on_reg, // from id 
    instruction // out to id 
    // pc2id
);
    input 					clk,rst ; //,and_z_b;
    input wire  [31:0]           out_pc; 
    // input       [1:0]           Jmp; 
    // input wire  [31:0]      branch_adder,address_on_reg; 
    // input wire  [25:0]      jmp_addr; 
    output wire [31:0]      instruction; //,pc2id;
    // wire        [31:0] 		in_pc,out_branch,out_adder2,out_pc; 
    //wire [31:0] next_pc;
    // Output PC+4 (or 0 during reset)
    // assign pc2id = rst ? 32'd0 : out_adder2;
    // assign in_pc = rst ? 32'd0 : next_pc;
	// // pc PC(.clk(clk),.rst(rst),.in(in_pc),.out(out_pc));
    // adder adder_of_pc(.clk(clk),.data1(out_pc),.data2(32'd4),.sum(out_adder2));
	// mux2_to_1 #32 mux2_branch(.clk(clk),.data1(out_adder2),.data2(branch_adder),.sel(and_z_b),.out(out_branch));                                 
	// mux3_to_1 #32 mux3_jmp(.clk(clk),.data1(out_branch),.data2({out_adder2[31:28],jmp_addr,2'b00}),
    // .data3(address_on_reg),.sel(Jmp),.out(in_pc));
	inst_memory InstMem(.rst(rst),.adr(out_pc),.instruction(instruction));
endmodule


// module IFstage (
//     clk, 
//     rst, 
//     branch_adder,      // from ID
//     jmp_addr,          // from ID
//     Jmp,               // control
//     and_z_b,           // control
//     address_on_reg,    // from ID (JR/JALR)
//     instruction,       // to ID
//     pc2id              // PC+4 to ID
// );
//     input              clk, rst, and_z_b;
//     input  [1:0]       Jmp; 
//     input  [31:0]      branch_adder, address_on_reg; 
//     input  [25:0]      jmp_addr; 
//     output [31:0]      instruction, pc2id;

//     // Internal wires
//     wire [31:0] in_pc;
//     wire [31:0] out_pc;
//     wire [31:0] pc_plus4;
//     wire [31:0] branch_selected;
//     wire [31:0] jump_addr_full;

//     assign in_pc = (rst == 1) ? 32'd0 : in_pc;
//     // --- PC REGISTER ---
//     pc PC(
//         .clk(clk),
//         .rst(rst),
//         .in( rst ? 32'd0 : in_pc ),   // If reset, PC is forced to 0
//         .out(out_pc)
//     );

//     // Compute PC+4
//     adder add_pc4(
//         .clk(clk),
//         .data1(out_pc),
//         .data2(32'd4),
//         .sum(pc_plus4)
//     );

//     // Branch target select
//     mux2_to_1 #32 MBRANCH(
//         .clk(clk),
//         .data1(pc_plus4),
//         .data2(branch_adder),
//         .sel(and_z_b),
//         .out(branch_selected)
//     );

//     // Jump target
//     assign jump_addr_full = {pc_plus4[31:28], jmp_addr, 2'b00};

//     // Final PC selection
//     mux3_to_1 #32 MJUMP(
//         .clk(clk),
//         .data1(branch_selected),
//         .data2(jump_addr_full),
//         .data3(address_on_reg),
//         .sel(Jmp),
//         .out(in_pc)
//     );

//     // INSTRUCTION MEMORY
//     inst_memory INSTMEM(
//         .clk(clk),
//         .rst(rst),
//         .adr(out_pc),
//         .instruction(instruction)
//     );
//     // Output PC+4 (or 0 during reset)
//     assign pc2id = rst ? 32'd0 : pc_plus4;

// endmodule
