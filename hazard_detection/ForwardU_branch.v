`timescale 1ns/1ns

module ForwardU_br (
    input [4:0] ex2mem_writeRegister , 
    input [4:0] if2id_readRegister_rs , 
    input [4:0] if2id_readRegister_rt ,
    input ex2mem_regWrite, 
    output reg fw_rs ,
    output reg fw_rt 
);
    always @(*) begin
        fw_rs = 1'b0;
        fw_rt = 1'b0;
       if (ex2mem_regWrite && (ex2mem_writeRegister != 0 )
            && (ex2mem_writeRegister == if2id_readRegister_rs)) begin
            fw_rs = 1'b1; 
        end 

        if (ex2mem_regWrite && (ex2mem_writeRegister != 0 )
            && (ex2mem_writeRegister == if2id_readRegister_rt)) begin
            fw_rt = 1'b1; 
        end 
    end
endmodule