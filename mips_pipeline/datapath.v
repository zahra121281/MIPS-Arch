// `timescale 1ns/1ns
// // 
// module data_path(
// 	clk,
// 	rst,
// 	RegDst,
// 	Jmp,
// 	DataC,
// 	RegWrite,
// 	AluSrc,
// 	AluSrc1,
// 	Branch,
// 	MemRead,
// 	MemWrite,
// 	MemtoReg,
// 	AluOperation,
// 	not_equal_Branch,
// 	func,
// 	opcode,
// 	out1,
// 	out2
// 	);

// 	input 					clk,rst;
// 	input       [1:0]		RegDst,Jmp;
// 	input 					DataC,RegWrite,AluSrc,AluSrc1,Branch,MemRead,MemWrite,MemtoReg,not_equal_Branch;
// 	input       [3:0]		AluOperation;
// 	output wire  [5:0] 		func,opcode;
// 	output wire [31:0] 		out1,out2;
// 	wire        [31:0] 		in_pc,out_pc,instruction,write_data_reg,read_data1_reg,read_data2_reg,pc_adder,mem_read_data,
// 							inst_extended,alu_input2,alu_result,read_data_mem,shifted_inst_extended,out_adder2,out_branch,shamnt,alu_input1;
// 	wire 		[4:0] 		write_reg;
// 	wire 		[25:0] 		shl2_inst;
// 	wire 					and_z_b,zero;
	
	// 1. specify stages : 
	// IF  

	// adder adder_of_pc(.clk(clk),.data1(out_pc),.data2(32'd4),.sum(pc_adder));

	// adder adder2(.clk(clk),.data1(shifted_inst_extended),.data2(pc_adder),.sum(out_adder2));
	// mux2_to_1 #32 mux2_branch(.clk(clk),.data1(pc_adder),.data2(out_adder2),.sel(and_z_b),.out(out_branch));

	// // ok , input to pc                                     
	// mux3_to_1 #32 mux3_jmp(.clk(clk),.data1(out_branch),.data2({pc_adder[31:28],instruction[25:0],2'b00}),.data3(read_data1_reg),.sel(Jmp),.out(in_pc));
	// //  if rst==0 , out <-- 0, else : put in -> out
	// pc PC(.clk(clk),.rst(rst),.in(in_pc),.out(out_pc));
	// inst_memory InstMem(.clk(clk),.rst(rst),.adr(out_pc),.instruction(instruction));
	
	// ID 
	// reg_file RegFile(.clk(clk),.rst(rst),.RegWrite(RegWrite),.read_reg1(instruction[25:21]),.read_reg2(instruction[20:16]),
	// 				 .write_reg(write_reg),.write_data(write_data_reg),.read_data1(read_data1_reg),.read_data2(read_data2_reg));

	// 	// ok 
	// mux3_to_1 #5 mux3_reg_file(.clk(clk),.data1(instruction[20:16]),.data2(instruction[15:11]),.data3(5'd31),.sel(RegDst),.out(write_reg));
	
	// // shl2 #26 shl2_1(.clk(clk),.adr(instruction[25:0]),.sh_adr(shl2_inst));
	// sign_extension sign_ext(.clk(clk),.primary(instruction[15:0]),.extended(inst_extended));
	// shl2 #32 shl2_of_adder2(.clk(clk),.adr(inst_extended),.sh_adr(shifted_inst_extended));

	// assign func=instruction[5:0];
	// assign opcode =instruction[31:26];
	// assign and_z_b= (zero & Branch) | (~(zero) & not_equal_Branch);

	// EXE 
	// EXE alu registers  ok
	// mux2_to_1 #32 alu_mux1(.clk(clk),.data1(read_data1_reg),.data2({27'b0,instruction[10:6]}),.sel(AluSrc1),.out(alu_input1)); ///////////////
	// // ok 
	// mux2_to_1 #32 alu_mux(.clk(clk),.data1(read_data2_reg),.data2(inst_extended),.sel(AluSrc),.out(alu_input2));
	
	// alu ALU(.clk(clk),.data1(alu_input1),.data2(alu_input2),.alu_op(AluOperation),.alu_result(alu_result),.zero_flag(zero));

	// MEM 
	// data_memory data_mem(.clk(clk),.rst(rst),.mem_read(MemRead),.mem_write(MemWrite),.adr(alu_result),
	// 					 .write_data(read_data2_reg),.read_data(read_data_mem),.out1(out1),.out2(out2)); 

	// // WB
	// mux2_to_1 #32 mux_of_mem(.clk(clk),.data1(alu_result),.data2(read_data_mem),.sel(MemtoReg),.out(mem_read_data));
	// mux2_to_1 #32 mux2_reg_file(.clk(clk),.data1(mem_read_data),.data2(pc_adder),.sel(DataC),.out(write_data_reg));

// endmodule

