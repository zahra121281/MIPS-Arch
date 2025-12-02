module IDstage (
    clk,
    rst, 
    RegWrite, // cntrl
    instruction, // if2id
    write_reg, // to reg
    write_data_reg, 
    pcPlus4,
    // RegDst, // controller 
    inst_extended, // to reg
    read_data1_reg,read_data2_reg , // to reg
    branch_adder_id , // to controller
    // func, opcode, // to controller
    zero  // to controller
);
    input 					clk,rst;
	input           		RegWrite;
    wire        [31:0]      shifted_inst_extended; 
    input wire  [31:0]      write_data_reg; 
    input wire  [31:0]      pcPlus4, instruction; 
    input wire  [4:0]       write_reg; 
    output wire [31:0]     read_data1_reg,read_data2_reg,branch_adder_id;
    output wire [31:0]      inst_extended; 
    // output wire  [5:0] 		func,opcode;
    output wire             zero; 
    // goes to id 
	adder adder2(.data1(shifted_inst_extended),.data2(pcPlus4),.sum(branch_adder_id));
  	reg_file RegFile(.clk(clk),.rst(rst),.RegWrite(RegWrite),.read_reg1(instruction[25:21]),.read_reg2(instruction[20:16]),
					 .write_reg(write_reg),.write_data(write_data_reg),.read_data1(read_data1_reg),.read_data2(read_data2_reg));
	sign_extension sign_ext(.primary(instruction[15:0]),.extended(inst_extended));
	shl2 #32 shl2_of_adder2(.adr(inst_extended),.sh_adr(shifted_inst_extended));
	// assign func=instruction[5:0];
	// assign opcode =instruction[31:26];
    // //comparator
    assign zero = (read_data1_reg == read_data2_reg);
endmodule