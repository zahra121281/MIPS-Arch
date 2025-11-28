
module mips(
	clk,
	rst,
	out1,
	out2
	);
	input 					clk,rst;
	output wire [31:0] 		out1,out2;

	wire 		[5:0] 		opcode,func;
	wire 		[1:0]		RegDst,Jmp;
	wire 					DataC,Regwrite,AluSrc,AluSrc1,Branch,MemRead,MemWrite,MemtoReg,not_equal_Branch;
	wire 		[3:0]		AluOperation;
	//////////
	wire        [31:0]		shifted_inst_extended;
	wire        [25:0]		Id_instruction;
	wire        and_z_b; 
	controller CU(.clk(clk),.rst(rst),.opcode(opcode),.func(func),.RegDst(RegDst),.Jmp(Jmp),
	              .DataC(DataC),.Regwrite(Regwrite),.AluSrc(AluSrc),.AluSrc1(AluSrc1),
				  .Branch(Branch),.not_equal_Branch(not_equal_Branch),.MemRead(MemRead),
				  .MemWrite(MemWrite),.MemtoReg(MemtoReg),.AluOperation(AluOperation));
	// shifted_inst_extended
	IFstage(.clk(clk), .rst(rst), .shifted_inst_extended(shifted_inst_extended), .jmp_addr(Id_instruction), 
				.Jmp(Jmp), .and_z_b(and_z_b), .read_data1_reg())
endmodule