module IDstage (
    clk,
    rst, 
    RegWrite, // cntrl
    instruction, // if2id
    write_reg, // to reg
    write_data_reg, 
    fw_rs,
    fw_rt,
    pcPlus4,
    alu_result_mem,
    // RegDst, // controller 
    inst_extended, // to reg
    read_data1_reg,read_data2_reg , // to reg
    branch_adder_id , // to controller
    // func, opcode, // to controller
    zero  // to controller
);
    input 					clk,rst;
	input           		RegWrite,fw_rs,fw_rt;
    wire        [31:0]      shifted_inst_extended; 
    wire [31:0]      inst_extended_internal; 
    input wire  [31:0]      write_data_reg; 
    input wire  [31:0]      pcPlus4, instruction, alu_result_mem; 
    input wire  [4:0]       write_reg; 
    output wire [31:0]     read_data1_reg,read_data2_reg,branch_adder_id;
    output wire [31:0]      inst_extended; 
    wire [31:0]     read_data1_reg_internal,read_data2_reg_internal,read_data1_reg_mux,read_data2_reg_mux; 
    output wire             zero; 
    // goes to id 
	adder adder2(.data1(shifted_inst_extended),.data2(pcPlus4),.sum(branch_adder_id));
  	reg_file RegFile(.clk(clk),.rst(rst),.RegWrite(RegWrite),.read_reg1(instruction[25:21]),.read_reg2(instruction[20:16]),
					 .write_reg(write_reg),.write_data(write_data_reg),.read_data1(read_data1_reg_internal),.read_data2(read_data2_reg_internal));
	sign_extension sign_ext(.primary(instruction[15:0]),.extended(inst_extended_internal));
    assign inst_extended = inst_extended_internal; 
	shl2 #32 shl2_of_adder2(.adr(inst_extended_internal),.sh_adr(shifted_inst_extended));
	// assign func=instruction[5:0];
	// assign opcode =instruction[31:26];
    // //comparator
    mux2_to_1 #32 mux_reg1(.data1(read_data1_reg_internal), .data2(alu_result_mem), .sel(fw_rs), .out(read_data1_reg_mux)); 
    mux2_to_1 #32 mux_reg2(.data1(read_data2_reg_internal), .data2(alu_result_mem), .sel(fw_rt), .out(read_data2_reg_mux)); 
    assign read_data1_reg = read_data1_reg_mux; 
    assign read_data2_reg = read_data2_reg_mux; 
    assign zero = (read_data1_reg_mux == read_data2_reg_mux);
endmodule


