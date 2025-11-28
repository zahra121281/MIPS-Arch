`timescale 1ns/1ns


module IFstage (
    clk, 
    rst, 
    shifted_inst_extended, // from id
    jmp_addr, // from id
    Jmp, // cntrl
    and_z_b, // cntrl
    read_data1_reg, // from id 
    instruction // out to id 
);
    input 					clk,rst,and_z_b;
    input       [1:0]       Jmp; 
    input wire        [31:0]      shifted_inst_extended,read_data1_reg; 
    input wire        [25:0]      jmp_addr; 
    output wire        [31:0]      instruction;
    wire        [31:0] 		in_pc,out_pc,pc_adder,out_branch,out_adder2; 
	adder adder_of_pc(.clk(clk),.data1(out_pc),.data2(32'd4),.sum(pc_adder));
	adder adder2(.clk(clk),.data1(shifted_inst_extended),.data2(pc_adder),.sum(out_adder2));
	mux2_to_1 #32 mux2_branch(.clk(clk),.data1(pc_adder),.data2(out_adder2),.sel(and_z_b),.out(out_branch));                                 
	mux3_to_1 #32 mux3_jmp(.clk(clk),.data1(out_branch),.data2({pc_adder[31:28],jmp_addr,2'b00}),
    .data3(read_data1_reg),.sel(Jmp),.out(in_pc));
	pc PC(.clk(clk),.rst(rst),.in(in_pc),.out(out_pc));
	inst_memory InstMem(.clk(clk),.rst(rst),.adr(out_pc),.instruction(instruction));
endmodule

