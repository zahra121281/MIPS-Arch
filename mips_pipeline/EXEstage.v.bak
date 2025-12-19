module EXEstage (
    clk,
    read_data1_reg,
    read_data2_reg,
    inst_extended,
    shamnt,
    AluSrc1,AluSrc,
    AluOperation,
    zero_flag, 
    alu_result
);
    input wire      [31:0]      read_data1_reg,read_data2_reg,inst_extended,shamnt;
    input wire                  AluSrc1,AluSrc;
    input wire      [3:0]		AluOperation;
    output                      zero_flag;
    output wire     [31:0]      alu_result; 
    mux2_to_1 #32 alu_mux1(.clk(clk),.data1(read_data1_reg),.data2(shamnt),.sel(AluSrc1),.out(alu_input1)); /////////////// {27'b0,instruction[10:6]}
	// ok 
	mux2_to_1 #32 alu_mux(.clk(clk),.data1(read_data2_reg),.data2(inst_extended),.sel(AluSrc),.out(alu_input2));
	alu ALU(.clk(clk),.data1(alu_input1),.data2(alu_input2),.alu_op(AluOperation),.alu_result(alu_result),.zero_flag(zero));
    
endmodule

