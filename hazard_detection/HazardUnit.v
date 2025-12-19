`timescale 1ns/1ns
module HazardUnit(
   
    input MemRead_EXE,
    input [4:0] Rt_EXE,
    input [4:0] Rs_ID,      
    input [4:0] Rt_ID,      
    
   
    input Branch_ID,       
    input RegWrite_EXE,     
    input [4:0] WriteReg_EXE,
    input MemRead_MEM,      
    input [4:0] WriteReg_MEM,
    
    output reg Stall
);
    always @(*) begin
        Stall = 1'b0;
        
        // 1. Load-Use Hazard
       
        if (MemRead_EXE && (Rt_EXE != 0) && ((Rt_EXE == Rs_ID) || (Rt_EXE == Rt_ID)))
            Stall = 1'b1;
        // 2. Branch Data Hazard (Alu to Branch)
       
        else if (Branch_ID && RegWrite_EXE && (WriteReg_EXE != 0) && 
                ((WriteReg_EXE == Rs_ID) || (WriteReg_EXE == Rt_ID)))
            Stall = 1'b1;
            
        // 3. Branch Data Hazard (Load to Branch)
       
        else if (Branch_ID && MemRead_MEM && (WriteReg_MEM != 0) &&
                ((WriteReg_MEM == Rs_ID) || (WriteReg_MEM == Rt_ID)))
            Stall = 1'b1;
    end
endmodule