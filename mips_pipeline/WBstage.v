module WBstage (
    clk,
    rst, 
    alu_result,
    read_data_mem,
    MemtoReg, 
    DataC,
    write_data_reg,
);
    input wire              DataC; 
    wire        [31:0]      mem_read_data;
    output wire [31:0]      write_data_reg;
	mux2_to_1 #32 mux_of_mem(.clk(clk),.data1(alu_result),.data2(read_data_mem),.sel(MemtoReg),.out(mem_read_data));
	mux2_to_1 #32 mux2_reg_file(.clk(clk),.data1(mem_read_data),.data2(pc_adder),.sel(DataC),.out(write_data_reg));
endmodule