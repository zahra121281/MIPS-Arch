module IDstage (
    clk,
    rst, 
    RegWrite, // cntrl
    instruction, // if2id
    write_reg, // toplevel
    write_data_reg, // toplevel 
    RegDst, // controller 
    inst_extended, // to reg
    read_data1_reg,read_data2_reg , // to reg
    shifted_inst_extended , // to controller
    func, opcode, // to controller
    zero  // to controller
);

    input 					clk,rst;
	input       [1:0]		RegWrite;
    input wire  [1:0]       RegDst; 
    output wire  [31:0]     read_data1_reg,read_data2_reg;
    output wire [31:0]      inst_extended; 
    output wire  [5:0] 		func,opcode;
    wire        [4:0]       write_reg; 
    output wire             zero; 

    // not sure 
	mux3_to_1 #5 mux3_reg_file(.clk(clk),.data1(instruction[20:16]),.data2(instruction[15:11]),.data3(5'd31),.sel(RegDst),.out(write_reg));
	
  	reg_file RegFile(.clk(clk),.rst(rst),.RegWrite(RegWrite),.read_reg1(instruction[25:21]),.read_reg2(instruction[20:16]),
					 .write_reg(write_reg),.write_data(write_data_reg),.read_data1(read_data1_reg),.read_data2(read_data2_reg));
	sign_extension sign_ext(.clk(clk),.primary(instruction[15:0]),.extended(inst_extended));
	shl2 #32 shl2_of_adder2(.clk(clk),.adr(inst_extended),.sh_adr(shifted_inst_extended));
	assign func=instruction[5:0];
	assign opcode =instruction[31:26];
    //comparator
    assign zero = (data1 == data2);
	// assign and_z_b= (zero & Branch) | (~(zero) & not_equal_Branch);
endmodule