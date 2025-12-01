`timescale 1ns/1ns


module IFstage (
    clk, 
    rst, 
    branch_adder, // from id
    jmp_addr, // from id
    Jmp, // cntrl
    and_z_b, // cntrl
    address_on_reg, // from id 
    instruction, // out to id 
    pc2id
);
    input 					clk,rst,and_z_b;
    input           [1:0]           Jmp; 
    input wire        [31:0]      branch_adder,address_on_reg; 
    input wire        [25:0]      jmp_addr; 
    output wire        [31:0]      instruction,pc2id;
    wire        [31:0] 		in_pc,pc_adder,out_branch,out_adder2,out_pc; 
    
	pc PC(.clk(clk),.rst(rst),.in(in_pc),.out(out_pc));
    adder adder_of_pc(.clk(clk),.data1(out_pc),.data2(32'd4),.sum(out_adder2));
	mux2_to_1 #32 mux2_branch(.clk(clk),.data1(out_adder2),.data2(branch_adder),.sel(and_z_b),.out(out_branch));                                 
	mux3_to_1 #32 mux3_jmp(.clk(clk),.data1(out_branch),.data2({out_adder2[31:28],jmp_addr,2'b00}),
    .data3(address_on_reg),.sel(Jmp),.out(in_pc));
	inst_memory InstMem(.clk(clk),.rst(rst),.adr(out_pc),.instruction(instruction));
    assign pc2id = out_adder2; 
    
endmodule

