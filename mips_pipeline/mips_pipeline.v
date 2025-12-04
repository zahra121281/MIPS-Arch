
`timescale 1ns/1ns
module mips(
	clk,
	rst,
	out1,
	out2
	);
	input 					clk,rst;
	output wire [31:0] 		out1,out2;
	// wire 					flush; 
	wire                    zero_ID; 
	wire 		[1:0]		RegDst,Jmp;
	
    // *** FIXED: Removed extra _ctrl wires, using direct connections
	wire 					AluSrc_id,AluSrc1_id,Branch,not_equal_Branch; 
	wire        [31:0]		instruction_if;
	wire        and_z_b; 
	wire 		flush_ctrl;
	wire 		final_flush;
    // *** FIXED: Using these wires for direct Controller -> ID2EXE connection
    wire 			MemWrite_id, MemRead_id; 
	wire 			MemtoReg_id;
	wire 			DataC_id;
	wire			Regwrite_id; 
	wire  [31:0]	instruction_id,inst_extended_id;
    // *** FIXED: Renamed to match usages & Added shamnt (5-bit)
    wire  [31:0]        read_data1_reg_id, read_data2_reg_id; 
    wire  [31:0]        branch_adder_id;
    wire  [4:0]         shamnt; 

	wire  [31:0]        pc_if,pc_id,pc_exe,pc_mem,pc_wb; 
	// wire  [25:0]        jmp_addr_id; 
	wire  [3:0]		    AluOperation_id; 
	
	// from Exe 
	wire				Regwrite_exe;  
	wire 				DataC_exe;
	wire                zero_exe;
    wire                overflow_exe; 
    wire     [31:0]     alu_result_exe,reg_data1_exe,reg_data2_exe; 
	wire                MemtoReg_exe;
	wire      [1:0]     RegDst_exe; 
	wire  [31:0]		inst_extended_exe; 
	wire      [4:0]     rt_exe,rd_exe,write_reg_exe; 
	wire  [3:0]		    AluOperation_exe; 
	wire             	AluSrc_exe, AluSrc1_exe; 
	
	wire            	MemWrite_exe,MemRead_exe; 
	// mem 
	wire                MemtoReg_mem; 
	wire 				DataC_mem;
	wire				Regwrite_mem; 
	// wire      [1:0]     RegDst_mem; 
	wire     [31:0]     alu_result_mem; 
	wire      [4:0]   write_reg_mem; 
	wire              MemWrite_mem,MemRead_mem; 
	// wb
	wire   [31:0]     write_data_reg_wb; 
	wire   [31:0]     alu_result_wb; 
	wire 			  DataC_wb;
	wire              MemtoReg_wb; 
	// wire   [1:0]      RegDst_wb;  
	wire   [4:0]   	  write_reg_wb; 
	wire			  Regwrite_wb; 
	wire   [31:0] 	  in_pc,out_branch,out_adder2,out_pc; 
	wire   [31:0]     write_data_mem;
	wire   [31:0]     read_data_mem_mem, read_data_mem_wb;
    // ####################
	// ##### PIPELINE #####
	// ####################

	// ######################### PC REG ######################### 
	adder adder_of_pc(.data1(out_pc),.data2(32'd4),.sum(out_adder2));
	mux2_to_1 #32 mux2_branch(.data1(out_adder2),.data2(branch_adder_id),.sel(and_z_b),.out(out_branch));  
	mux3_to_1 #32 mux3_jmp(.data1(out_branch),.data2({out_adder2[31:28],instruction_id[25:0],2'b00}),
    .data3(read_data1_reg_id),.sel(Jmp),.out(in_pc));
	pc PC(.clk(clk),.rst(rst),.in(in_pc),.out(out_pc));
	assign pc_if = out_adder2; 

	// ######################### IF STAGE #########################
	IFstage ifstage(
		.clk(clk), 
		.rst(rst), 
		.out_pc(out_pc),
		.instruction(instruction_if)
	);

	IF2ID IF2ID(
		.clk(clk),
		.rst(rst),
		.flush(final_flush),  
		.PCplus4In(pc_if),
		.instructionIn(instruction_if),
		.PCplus4OUt(pc_id),
		.instructionOut(instruction_id)
    ); 
	
    // ######################### ID STAGE #########################
	IDstage idstage(.clk(clk), 
					.rst(rst), 
					.RegWrite(Regwrite_wb), 
					.instruction(instruction_id), 
					.write_reg(write_reg_wb),
					.write_data_reg(write_data_reg_wb),
					.inst_extended(inst_extended_id), 
					.read_data1_reg(read_data1_reg_id),
					.read_data2_reg(read_data2_reg_id), 
					.pcPlus4(pc_id),
					.zero(zero_ID),
					.branch_adder_id(branch_adder_id)); 

	assign and_z_b = (zero_ID & Branch) | (~(zero_ID) & not_equal_Branch);
	assign final_flush = flush_ctrl | and_z_b;

	// ######################
	// ##### CONTROLLER #####
	// ######################
	controller CU(
				.opcode(instruction_id[31:26]),
				.func(instruction_id[5:0]),
				// exe signals 
				  .AluOperation(AluOperation_id),
				  .AluSrc(AluSrc_id),
				  .AluSrc1(AluSrc1_id),
				  .RegDst(RegDst),
				  // MEM
                  // *** FIXED: Connected directly to _id wires (to go to ID2EXE)
				  .MemWrite(MemWrite_id),
				  .MemRead(MemRead_id),
				  //WB
				  .MemtoReg(MemtoReg_id),
	              .DataC(DataC_id),
				  .Regwrite(Regwrite_id),
				  .Jmp(Jmp),
				  .Branch(Branch),
				  .flush(flush_ctrl),
				  .not_equal_Branch(not_equal_Branch));

	ID2EXE id2exe(
		.clk(clk),
		.rst(rst),
		.inst_extended_in(inst_extended_id),
		.reg_data1_in(read_data1_reg_id),
		.reg_data2_in(read_data2_reg_id),
		.reg1_in(instruction_id[20:16]),
		.reg2_in(instruction_id[15:11]),
		.RegDstIn(RegDst),
		.AluOp_in(AluOperation_id),
		.AluSrcIn(AluSrc_id),
		.AluSrc1In(AluSrc1_id),
		.RegwriteIn(Regwrite_id),
        // *** FIXED: Added shamnt (Shift Amount) connections
        .shamnt_in(instruction_id[10:6]), 
        .shamnt_out(shamnt),
		.RegwriteOut(Regwrite_exe),
		// add signals for mem stage from exe stage and controller
		.MemWriteIn(MemWrite_id), 
        .MemReadIn(MemRead_id), 
		.MemtoRegIn(MemtoReg_id),
		.PCplus4In(pc_id),
		.DatacIn(DataC_id),
		// add signals for wb stage from mem stage and controller
		///////////////////////// output 
		// add signals for Exe stage from id stage and controller
		.AluOp_out(AluOperation_exe),
		.DatacOut(DataC_exe),
		.reg_data1_out(reg_data1_exe),
		.reg_data2_out(reg_data2_exe),
		.inst_extended_out(inst_extended_exe),
		.RegDstOut(RegDst_exe) ,
		.reg1_out(rt_exe),
		.reg2_out(rd_exe),
		.MemWriteOut(MemWrite_exe), 
		.MemReadOut(MemRead_exe),
		.MemtoRegOut(MemtoReg_exe),
		.PCplus4OUt(pc_exe),
		.AluSrcOut(AluSrc_exe),
		.AluSrc1Out(AluSrc1_exe)
	);

	// ######################### IF STAGE #########################

	mux3_to_1 #5 mux3_reg_file(.data1(rt_exe),.data2(rd_exe),.data3(5'd31),.sel(RegDst_exe),.out(write_reg_exe));

	EXEstage exestage(.clk(clk), 
					.read_data1_reg(reg_data1_exe), 
					.read_data2_reg(reg_data2_exe), 
					.AluSrc1(AluSrc1_exe),
					.AluSrc(AluSrc_exe), 
					.shamnt({27'b0, shamnt}), 
					.AluOperation(AluOperation_exe), 
					.inst_extended(inst_extended_exe),
					.zero_flag(zero_exe), 
                    .overflow(overflow_exe), // *** FIXED: Connected overflow wire
					.alu_result(alu_result_exe)); 

	EXE2MEM exe2mem(
    // *** FIXED: CRITICAL - Added clk and rst
    .clk(clk),
    .rst(rst),
	.write_reg_in(write_reg_exe),
	// add signals for mem stage from exe stage and controller
	.WriteDataIn(reg_data2_exe),  //////////////////////////// from rt reg data 
	.MemtoRegIn(MemtoReg_exe), 
	.MemWriteIn(MemWrite_exe), 
    .MemReadIn(MemRead_exe), // *** FIXED: Was missing
	.AluResIn(alu_result_exe),
	.DatacIn(DataC_exe),
	.pc_in(pc_exe),
	.RegwriteIn(Regwrite_exe), 
	// add signals for wb stage from mem stage and controller
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
	
	// ######################### MEM STAGE #########################
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

	MEM2WB mem2wb(
        // *** FIXED: CRITICAL - Added clk and rst
        .clk(clk),
        .rst(rst),
		.write_reg_in(write_reg_mem),
		.AluResIn(alu_result_mem),
		.MemtoRegIn(MemtoReg_mem), 
		.pc_in(pc_mem),
		.DatacIn(DataC_mem),
		.read_data_In(read_data_mem_mem),
		.RegwriteIn(Regwrite_mem), 
		// add signals for wb stage from mem stage and controller
		.write_reg_out(write_reg_wb),
		.pc_out(pc_wb),
		.AluResOut(alu_result_wb),
		.MemtoRegOut(MemtoReg_wb), 
		.DatacOut(DataC_wb),
		.RegwriteOut(Regwrite_wb), 
		.read_data_out(read_data_mem_wb)
	);

	// ######################### WB STAGE #########################
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


// `timescale 1ns/1ns
// module mips(
// 	clk,
// 	rst,
// 	out1,
// 	out2
// 	);
// 	input 					clk,rst;
// 	output wire [31:0] 		out1,out2;
// 	wire 					flush; 
// 	wire                    zero_ID; 
// 	wire 		[1:0]		RegDst,Jmp;
// 	wire 					Regwrite,AluSrc_id,AluSrc1_id,Branch,MemRead_ctrl,MemWrite_ctrl,MemtoReg,not_equal_Branch;
// 	//////////
// 	wire        [31:0]		instruction_if;
// 	wire        and_z_b; 
// 	// from id to controller : 
// 	wire  [31:0]    inst_extended; 
//     wire  [5:0] 	func,opcode;
// 	wire            MemWrite_id,MemRead_id; 
// 	wire 					DataC_id;
// 	wire					Regwrite_id; 
// 	// from id to id2exe
// 	wire  [25:0]		Id_instruction;
// 	wire  [31:0]        read_data1_reg,read_data2_reg,branch_adder_id,shamnt;
// 	wire  [31:0]        pc_if,pc_id ; 
// 	wire  [25:0]        jmp_addr_id; 
// 	wire  [31:0]		instruction_id,inst_extended_id;
// 	wire  [3:0]		AluOperation_id; 
// 	wire                MemtoReg_id;
	
// 	// wire      [4:0]     reg_data1_id,reg_data2_id; 
// 	// from Exe 
// 	wire					Regwrite_exe;  
// 	wire 					DataC_exe;
// 	wire                 zero_exe;
//     wire     [31:0]      alu_result_exe,reg_data1_exe,reg_data2_exe; 
// 	wire                MemtoReg_exe;
// 	wire      [1:0]     RegDst_exe; 
// 	wire  [31:0]		instruction_exe; 
// 	wire      [4:0]     rt_exe,rd_exe,write_reg_exe; 
// 	wire  [3:0]		AluOperation_exe; 
// 	wire             AluSrc_exe, AluSrc1_exe; 
	
// 	wire            MemWrite_exe,MemRead_exe; 
// 	// mem 
// 	wire                MemtoReg_mem; 
// 	wire 					DataC_mem;
// 	wire					Regwrite_mem; 
// 	wire      [1:0]     RegDst_mem; 
// 	wire     [31:0]      alu_result_mem; 
// 	wire      [4:0]     write_reg_mem; 
// 	wire              MemWrite_mem,MemRead_mem; 
// 	// wb
// 	wire   [31:0]     write_data_reg_wb; 
// 	wire     [31:0]   alu_result_wb; 
// 	wire 			  DataC_wb;
// 	wire              MemtoReg_wb;
// 	wire   [1:0]      RegDst_wb;  
// 	wire   [4:0]   	  write_reg_wb; 
// 	wire			  Regwrite_wb; 
// 	wire        [31:0] 		in_pc,out_branch,out_adder2,out_pc; 
// 	// ####################
// 	// ##### PIPELINE #####
// 	// ####################

// 	// ######################### PC REG ######################### 
// 	adder adder_of_pc(.data1(out_pc),.data2(32'd4),.sum(out_adder2));
// 	mux2_to_1 #32 mux2_branch(.data1(out_adder2),.data2(branch_adder_id),.sel(and_z_b),.out(out_branch));  

// 	mux3_to_1 #32 mux3_jmp(.data1(out_branch),.data2({out_adder2[31:28],jmp_addr_id,2'b00}),
//     .data3(read_data1_reg_id),.sel(Jmp),.out(in_pc));

// 	pc PC(.clk(clk),.rst(rst),.in(in_pc),.out(out_pc));
// 	assign pc_if = out_adder2; 

// 	// ######################### IF STAGE #########################
// 	IFstage ifstage(
// 		.clk(clk), 
// 		.rst(rst), 
// 		.out_pc(out_pc),
// 		.instruction(instruction_if)
// 		);

// 	IF2ID IF2ID(
// 		.clk(clk),
// 		.rst(rst),
// 		.flush(flush),  // add it to controller signals 
// 		// .freeze,
// 		.PCplus4In(pc_if),
// 		.instructionIn(instruction_if),
// 		.PCplus4OUt(pc_id),
// 		.instructionOut(instruction_id)
//     ); 
// 	// ######################### ID STAGE #########################
// 	IDstage idstage(.clk(clk), 
// 					.rst(rst), 
// 					.RegWrite(Regwrite_wb), 
// 					.instruction(instruction_id), 
// 					.write_reg(write_reg_wb),
// 					.write_data_reg(write_data_reg_wb),
// 					.inst_extended(inst_extended_id), 
// 					.read_data1_reg(read_data1_reg_id),
// 					.read_data2_reg(read_data2_reg_id), 
// 					.pcPlus4(pc_id),
// 					.zero(zero_ID),
// 					.branch_adder_id(branch_adder_id),
// 					.func(func),
// 					.opcode(opcode));

// 	assign jmp_addr_id = instruction_id[25:0]; 
// 	assign and_z_b = (zero_ID & Branch) | (~(zero_ID) & not_equal_Branch);

// 	// ######################
// 	// ##### CONTROLLER #####
// 	// ######################
// 	controller CU(.clk(clk),
// 				.rst(rst),
// 				.opcode(opcode),
// 				.func(func),
// 				// exe signals 
// 				  .AluOperation(AluOperation_id),
// 				  .AluSrc(AluSrc_id),
// 				  .AluSrc1(AluSrc1_id),
// 				  .RegDst(RegDst),
// 				  // MEM
// 				  .MemWrite(MemWrite_ctrl),
// 				  .MemRead(MemRead_ctrl),
// 				  //WB
// 				  .MemtoReg(MemtoReg_id),
// 	              .DataC(DataC_id),
// 				  .Regwrite(Regwrite_id),
// 				  // which stage? 
// 				  .Jmp(Jmp),
// 				  .Branch(Branch),
// 				  .flush(flush),
// 				  .not_equal_Branch(not_equal_Branch));

// 	ID2EXE id2exe(
// 		.clk(clk),
// 		.rst(rst),
// 		.inst_extended_in(inst_extended_id),
// 		.reg_data1_in(read_data1_reg_id),
// 		.reg_data2_in(read_data2_reg_id),
// 		.reg1_in(instruction_id[20:16]),
// 		.reg2_in(instruction_id[15:11]),
// 		.RegDstIn(RegDst),
// 		.AluOp_in(AluOperation_id),
// 		.AluSrcIn(AluSrc_id),
// 		.AluSrc1In(AluSrc1_id),
// 		// add signals for mem stage from exe stage and controller
// 		.MemWriteIn(MemWrite_id), 
// 		.MemtoRegIn(MemtoReg_id),
// 		.PCplus4In(pc_id),
// 		.DatacIn(DataC_id),
// 		// add signals for wb stage from mem stage and controller
// 		///////////////////////// output 
// 		// add signals for Exe stage from id stage and controller
// 		.AluOp_out(AluOperation_exe),
// 		.DatacOut(DataC_exe),
// 		.reg_data1_out(reg_data1_exe),
// 		.reg_data2_out(reg_data2_exe),
// 		.inst_extended_out(inst_extended_exe),
// 		.RegDstOut(RegDst_exe) ,
// 		.reg1_out(rt_exe),
// 		.reg2_out(rd_exe),
// 		.MemWriteOut(MemWrite_exe), 
// 		.MemReadOut(MemRead_exe),
// 		.MemtoRegOut(MemtoReg_exe),
// 		.PCplus4OUt(pc_exe),
// 		.AluSrcOut(AluSrc_exe),
// 		.AluSrc1Out(AluSrc1_exe)
// 	);

// 	// ######################### IF STAGE #########################

// 	mux3_to_1 #5 mux3_reg_file(.data1(rt_exe),.data2(rd_exe),.data3(5'd31),.sel(RegDst_exe),.out(write_reg_exe));

// 	EXEstage exestage(.clk(clk), 
// 					.read_data1_reg(reg_data1_exe), 
// 					.read_data2_reg(reg_data2_exe), 
// 					.AluSrc1(AluSrc1_exe),
// 					.AluSrc(AluSrc_exe), 
// 					.shamnt(shamnt), 
// 					.AluOperation(AluOperation_exe), 
// 					.inst_extended(inst_extended_exe),
// 					.zero_flag(zero_exe), 
// 					.alu_result(alu_result_exe)); 

// 	EXE2MEM exe2mem(
// 	.write_reg_in(write_reg_exe),
// 	// add signals for mem stage from exe stage and controller
// 	.WriteDataIn(reg_data2_exe),  //////////////////////////// from rt reg data 
// 	.MemtoRegIn(MemtoReg_exe), 
// 	.MemWriteIn(MemWrite_exe), 
// 	.AluResIn(alu_result_exe),
// 	.DatacIn(DataC_exe),
// 	.pc_in(pc_exe),
// 	// add signals for wb stage from mem stage and controller
// 	.write_reg_out(write_reg_mem),
// 	.pc_out(pc_mem),
// 	.MemWriteOut(MemWrite_mem), 
// 	.MemReadOut(MemRead_mem), 
// 	.AluResOut(alu_result_mem),
// 	.MemtoRegOut(MemtoReg_mem), 
// 	.DatacOut(DataC_mem),
// 	.WriteDataOut(write_data_mem)
// 	);
	
// 	// ######################### MEM STAGE #########################
// 	MEMstage Memstage(
// 		.clk(clk),
// 		.rst(rst), 
// 		.MemRead(MemRead_mem),
// 		.MemWrite(MemWrite_mem),
// 		.alu_result(alu_result_mem),
// 		.out1(out1),
// 		.out2(out2),
// 		.write_data(write_data_mem)
// 	);

// 	MEM2WB mem2wb(
// 		.write_reg_in(write_reg_mem),
// 		.AluResIn(alu_result_mem),
// 		.MemtoRegIn(MemtoReg_mem), 
// 		.pc_in(pc_mem),
// 		.DatacIn(DataC_mem),
// 		// add signals for wb stage from mem stage and controller
// 		.write_reg_out(write_reg_wb),
// 		.pc_out(pc_wb),
// 		.AluResOut(alu_result_wb),
// 		.MemtoRegOut(MemtoReg_wb), 
// 		.DatacOut(DataC_wb)
// 	);

// 	// ######################### WB STAGE #########################
// 	WBstage wbstage(
// 		.clk(clk),
// 		.rst(rst), 
// 		.pc_adder(pc_wb),
// 		.alu_result(alu_result_wb),
// 		.read_data_mem(read_data_mem_wb),
// 		.MemtoReg(MemtoReg_wb), 
// 		.DataC(DataC_wb),
// 		.write_data_reg(write_data_reg_wb)
// 	);

// endmodule





// // IFstage ifstage(
// // 		.clk(clk), 
// // 		.rst(rst), 
// // 		.out_pc(out_pc),
// // 		// .branch_adder(branch_adder_id), // from id
// // 		// .jmp_addr(jmp_addr_id), // from id
// // 		// .Jmp(Jmp), // cntrl
// // 		// .and_z_b(and_z_b), // cntrl
// // 		// .address_on_reg(read_data1_reg), // from id 
// // 		.instruction(instruction_if)
// // 		// .pc2id(pc_if)
// // 		);