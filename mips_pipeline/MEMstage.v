module MEMstage (
    clk,
    rst, 
    MemRead,
    MemWrite,
    alu_result,
    out1,out2,
    write_data,
    read_data
);
    input wire clk, rst, MemRead, MemWrite; 
    input wire      [31:0]      alu_result,write_data; 
    output wire     [31:0]       out1,out2,read_data; 
    
    data_memory data_mem(.clk(clk),.rst(rst),.mem_read(MemRead),.mem_write(MemWrite),.adr(alu_result),
                        .write_data(write_data),.read_data(read_data_mem),.out1(out1),.out2(out2)); 

endmodule
