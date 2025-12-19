`timescale 1ns/1ns

module mips(
	input 					clk,
	input 					rst,
	output wire [31:0] 		out1,
	output wire [31:0] 		out2
);

	// ====================================================
	// 1. WIRES & SIGNALS
	// ====================================================

	// --- Control Signals ---
	wire [1:0] 	RegDst, Jmp;
	wire 		Branch, not_equal_Branch;
	wire 		MemRead_id, MemWrite_id, MemtoReg_id, Regwrite_id, AluSrc_id, AluSrc1_id, DataC_id;
	wire 		flush_ctrl;

	// --- IF Stage Signals ---
	wire [31:0] pc_if, instruction_if, in_pc, out_pc, out_adder2;
	
	// --- ID Stage Signals ---
	wire [31:0] pc_id, instruction_id, inst_extended_id;
	wire [31:0] read_data1_reg_id, read_data2_reg_id;
	wire [31:0] branch_adder_id;
	wire 		zero_ID;
	wire [31:0] jump_address;
	// hazard controll unit (branch)
	wire stall_beq;
	// -- fu_br
	wire fw_rs;
	wire fw_rt;
	// --- EXE Stage Signals ---
	wire [31:0] pc_exe, inst_extended_exe;
	wire [31:0] reg_data1_exe, reg_data2_exe;
	wire [4:0] 	rt_exe, rd_exe, write_reg_exe;
	wire [4:0] 	rs_exe; // *** NEW: For Forwarding
	wire [31:0] alu_result_exe, write_data_exe_final; // write_data_exe_final for SW
	wire 		zero_exe, overflow_exe;
	wire [3:0] 	AluOperation_id, AluOperation_exe;
	wire 		Regwrite_exe, MemtoReg_exe, MemRead_exe, MemWrite_exe, AluSrc_exe, AluSrc1_exe, DataC_exe;
	wire [1:0] 	RegDst_exe;
	wire [4:0] 	shamnt_id, shamnt_exe;

	// --- MEM Stage Signals ---
	wire [31:0] pc_mem, alu_result_mem, write_data_mem;
	wire [31:0] read_data_mem_mem;
	wire [4:0] 	write_reg_mem;
	wire 		Regwrite_mem, MemtoReg_mem, MemRead_mem, MemWrite_mem, DataC_mem;

	// --- WB Stage Signals ---
	wire [31:0] pc_wb, alu_result_wb, read_data_mem_wb, write_data_reg_wb;
	wire [4:0] 	write_reg_wb;
	wire 		Regwrite_wb, MemtoReg_wb, DataC_wb;

	// --- HAZARD & FORWARDING SIGNALS ---
	wire 		Stall;
	wire 		Stall_n; 
	assign 		Stall_n = ~(Stall || stall_beq); // Active Low Enable for Freeze

	wire [1:0] 	ForwardA, ForwardB;
	wire 		PCSrc; // Logic for Branch Taken

	// ====================================================
	// 2. HAZARD & FORWARDING UNITS INSTANTIATION
	// ====================================================

	HazardUnit hu (
		.MemRead_EXE(MemRead_exe),
		.Rt_EXE(rt_exe), // For LW hazard
		.Rs_ID(instruction_id[25:21]),
		.Rt_ID(instruction_id[20:16]),
		// Branch Hazards (Aggressive Stall)
		.Branch_ID(Branch | not_equal_Branch),
		.RegWrite_EXE(Regwrite_exe),
		.WriteReg_EXE(write_reg_exe),
		.MemRead_MEM(MemRead_mem),
		.WriteReg_MEM(write_reg_mem),
		.Stall(Stall)
	);

	ForwardingUnit fu (
		.RegWrite_MEM(Regwrite_mem),
		.RegWrite_WB(Regwrite_wb),
		.Rd_MEM(write_reg_mem),
		.Rd_WB(write_reg_wb),
		.Rs_EXE(rs_exe), // Comes from ID2EXE
		.Rt_EXE(rt_exe), // Comes from ID2EXE
		.ForwardA(ForwardA),
		.ForwardB(ForwardB)
	);

	// ====================================================
	// 3. BRANCH & PC LOGIC
	// ====================================================

	// Logic: If (beq & zero) OR (bne & !zero) => Branch Taken
	assign PCSrc = (Branch & zero_ID) | (not_equal_Branch & ~zero_ID);
	
	// Jump Address Calculation
	assign jump_address = {pc_id[31:28], instruction_id[25:0], 2'b00};

	// Next PC Logic: Priority: Jump > Branch > PC+4
	// (Note: Using separate MUXes or nested ternary operator)
	assign in_pc = (Jmp == 2'b01 || Jmp == 2'b10) ? jump_address : // Simple Jump support
				   (PCSrc) ? branch_adder_id : 
				   out_adder2;

	// ====================================================
	// 4. PIPELINE STAGES
	// ====================================================

	// --- PC ---
	adder adder_of_pc(.data1(out_pc), .data2(32'd4), .sum(out_adder2));
	
	pc PC(
		.clk(clk),
		.rst(rst),
		.en(Stall_n), // *** FIXED: Freeze PC on Stall
		.in(in_pc),
		.out(out_pc)
	);
	
	assign pc_if = out_adder2;

	// --- IF STAGE ---
	IFstage ifstage(
		.clk(clk), 
		.rst(rst), 
		.out_pc(out_pc),
		.instruction(instruction_if)
	);

	// --- IF/ID REG ---
	IF2ID IF2ID(
		.clk(clk),
		.rst(rst),
		.EN(Stall_n),           // *** FIXED: Freeze IF/ID on Stall
		.flush(PCSrc | (Jmp != 0)), // *** FIXED: Flush on Branch Taken or Jump
		.PCplus4In(pc_if),
		.instructionIn(instruction_if),
		.PCplus4OUt(pc_id),
		.instructionOut(instruction_id)
	);

	// --- ID STAGE ---
	IDstage idstage(
		.clk(clk), 
		.rst(rst), 
		.RegWrite(Regwrite_wb), 
		.instruction(instruction_id), 
		.fw_rs(fw_rs),
		.fw_rt(fw_rt),
		.alu_result_mem(alu_result_mem),
		.write_reg(write_reg_wb),
		.write_data_reg(write_data_reg_wb),
		.inst_extended(inst_extended_id), 
		.read_data1_reg(read_data1_reg_id),
		.read_data2_reg(read_data2_reg_id), 
		.pcPlus4(pc_id),
		.zero(zero_ID),
		.branch_adder_id(branch_adder_id)
	);


	// -- HDU_BR
	HazardU_br hazardU_br (
		.id2ex_RegWrite(Regwrite_exe),
		.exe2mem_memRead(MemRead_mem),
		.branch(Branch),
		.id2exe_writeRegister(write_reg_exe),
		.exe2mem_writeRegister(write_reg_mem),
		.if2id_readRegister_rs(instruction_id[25:21]),
		.if2id_readRegister_rt(instruction_id[20:16]),
		.stall_beq(stall_beq) 
	);

	// -- FU_br
	ForwardU_br forwardU_br(
		.ex2mem_writeRegister(write_reg_mem),
		.if2id_readRegister_rs(instruction_id[25:21]),
		.if2id_readRegister_rt(instruction_id[20:16]),
		.ex2mem_regWrite(Regwrite_mem),
		.fw_rs(fw_rs),
		.fw_rt(fw_rt)
	);

	// --- CONTROLLER ---
	controller CU(
		.opcode(instruction_id[31:26]),
		.func(instruction_id[5:0]),
		.AluOperation(AluOperation_id),
		.AluSrc(AluSrc_id),
		.AluSrc1(AluSrc1_id),
		.RegDst(RegDst),
		.MemWrite(MemWrite_id),
		.MemRead(MemRead_id),
		.MemtoReg(MemtoReg_id),
		.DataC(DataC_id),
		.Regwrite(Regwrite_id),
		.Jmp(Jmp),
		.Branch(Branch),
		.flush(flush_ctrl),
		.not_equal_Branch(not_equal_Branch)
	);

	// --- ID/EXE REG ---
	ID2EXE id2exe(
		.clk(clk),
		.rst(rst),
		.flush(Stall|stall_beq | PCSrc), // *** FIXED: Flush on Stall OR Branch Taken
		
		// Forwarding Inputs/Outputs
		.RsIn(instruction_id[25:21]), .RtIn(instruction_id[20:16]),
		.RsOut(rs_exe), .RtOut(rt_exe), // Outputs to Forwarding Unit

		// Standard Signals
		.inst_extended_in(inst_extended_id),
		.reg_data1_in(read_data1_reg_id),
		.reg_data2_in(read_data2_reg_id),
		.reg1_in(instruction_id[20:16]), // rt
		.reg2_in(instruction_id[15:11]), // rd
		.RegDstIn(RegDst),
		.AluOp_in(AluOperation_id),
		.AluSrcIn(AluSrc_id),
		.AluSrc1In(AluSrc1_id),
		.RegwriteIn(Regwrite_id),
		.shamnt_in(instruction_id[10:6]), 
		.shamnt_out(shamnt_exe),
		.RegwriteOut(Regwrite_exe),
		.MemWriteIn(MemWrite_id), 
		.MemReadIn(MemRead_id), 
		.MemtoRegIn(MemtoReg_id),
		.PCplus4In(pc_id),
		.DatacIn(DataC_id),
		
		// Outputs to EXE
		.AluOp_out(AluOperation_exe),
		.DatacOut(DataC_exe),
		.reg_data1_out(reg_data1_exe),
		.reg_data2_out(reg_data2_exe),
		.inst_extended_out(inst_extended_exe),
		.RegDstOut(RegDst_exe),
		.reg1_out(rt_exe), // used for rt
		.reg2_out(rd_exe), // used for rd
		.MemWriteOut(MemWrite_exe), 
		.MemReadOut(MemRead_exe),
		.MemtoRegOut(MemtoReg_exe),
		.PCplus4OUt(pc_exe),
		.AluSrcOut(AluSrc_exe),
		.AluSrc1Out(AluSrc1_exe)
	);

	// --- EXE STAGE ---
	// MUX for Destination Register
	mux3_to_1 #5 mux3_reg_file(
		.data1(rt_exe),
		.data2(rd_exe),
		.data3(5'd31),
		.sel(RegDst_exe),
		.out(write_reg_exe)
	);

	EXEstage exestage(
		.clk(clk), 
		.read_data1_reg(reg_data1_exe), 
		.read_data2_reg(reg_data2_exe), 
		.AluSrc1(AluSrc1_exe),
		.AluSrc(AluSrc_exe), 
		.shamnt(shamnt_exe), 
		.AluOperation(AluOperation_exe), 
		.inst_extended(inst_extended_exe),
		
		// Forwarding Inputs
		.alu_result_MEM(alu_result_mem), 
		.result_WB(write_data_reg_wb), // Note: forwarding from WB stage result
		.ForwardA(ForwardA), 
		.ForwardB(ForwardB),
		
		// Outputs
		.zero_flag(zero_exe), 
		.overflow(overflow_exe),
		.alu_result(alu_result_exe),
		.write_data_out(write_data_exe_final) // *** FIXED: Correct data for SW
	); 

	// --- EXE/MEM REG ---
	EXE2MEM exe2mem(
		.clk(clk),
		.rst(rst),
		.write_reg_in(write_reg_exe),
		.WriteDataIn(write_data_exe_final), // *** FIXED: Using forwarded data
		.MemtoRegIn(MemtoReg_exe), 
		.MemWriteIn(MemWrite_exe), 
		.MemReadIn(MemRead_exe),
		.AluResIn(alu_result_exe),
		.DatacIn(DataC_exe),
		.pc_in(pc_exe),
		.RegwriteIn(Regwrite_exe), 
		
		.write_reg_out(write_reg_mem),
		.pc_out(pc_mem),
		.MemWriteOut(MemWrite_mem), 
		.MemReadOut(MemRead_mem), 
		.AluResOut(alu_result_mem),
		.MemtoRegOut(MemtoReg_mem), 
		.DatacOut(DataC_mem),
		.RegwriteOut(Regwrite_mem), 
		.WriteDataOut(write_data_mem)
	);
	
	// --- MEM STAGE ---
	MEMstage Memstage(
		.clk(clk),
		.rst(rst), 
		.MemRead(MemRead_mem),
		.MemWrite(MemWrite_mem),
		.alu_result(alu_result_mem),
		.out1(out1),
		.out2(out2),
		.write_data(write_data_mem),
		.read_data(read_data_mem_mem)
	);

	// --- MEM/WB REG ---
	MEM2WB mem2wb(
		.clk(clk),
		.rst(rst),
		.write_reg_in(write_reg_mem),
		.AluResIn(alu_result_mem),
		.MemtoRegIn(MemtoReg_mem), 
		.pc_in(pc_mem),
		.DatacIn(DataC_mem),
		.read_data_In(read_data_mem_mem),
		.RegwriteIn(Regwrite_mem), 
		
		.write_reg_out(write_reg_wb),
		.pc_out(pc_wb),
		.AluResOut(alu_result_wb),
		.MemtoRegOut(MemtoReg_wb), 
		.DatacOut(DataC_wb),
		.RegwriteOut(Regwrite_wb), 
		.read_data_out(read_data_mem_wb)
	);

	// --- WB STAGE ---
	WBstage wbstage(
		.clk(clk),
		.rst(rst), 
		.pc_adder(pc_wb),
		.alu_result(alu_result_wb),
		.read_data_mem(read_data_mem_wb),
		.MemtoReg(MemtoReg_wb), 
		.DataC(DataC_wb),
		.write_data_reg(write_data_reg_wb)
	);

endmodule