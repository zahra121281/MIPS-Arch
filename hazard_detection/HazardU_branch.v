`timescale 1ns/1ns


module HazardU_br (
    input id2ex_RegWrite,
    input exe2mem_memRead,
    input branch ,
    input [4:0] id2exe_writeRegister,
    input [4:0] exe2mem_writeRegister,
    input [4:0] if2id_readRegister_rs,
    input [4:0] if2id_readRegister_rt,
    output reg stall_beq 
);

    always @(*) begin
        stall_beq = 1'b0; 
        if (branch) begin

            if (id2ex_RegWrite && (id2exe_writeRegister != 0) &&
            ((id2exe_writeRegister == if2id_readRegister_rs) || 
                (id2exe_writeRegister == if2id_readRegister_rt))) 
                stall_beq = 1'b1;
                
            else if (exe2mem_memRead && (exe2mem_writeRegister != 0) &&
            ((exe2mem_writeRegister == if2id_readRegister_rs) || 
                (exe2mem_writeRegister == if2id_readRegister_rt)))
                stall_beq = 1'b1;
        end
    end
    
endmodule