`timescale 1ns/1ns

module IF2ID(
    input clk,
    input rst,
    input flush,     
    input EN,        
    input [31:0] PCplus4In,
    input [31:0] instructionIn,
    output reg [31:0] PCplus4OUt,
    output reg [31:0] instructionOut
    );
/*
  always @ (posedge clk) begin
   
    if (rst) begin
      PCplus4OUt <= 0;
      instructionOut <= 0;
    end
   
    else if (flush) begin
      PCplus4OUt <= 0;
      instructionOut <= 0;
    end
    
    else if (EN) begin
      PCplus4OUt <= PCplus4In;
      instructionOut <= instructionIn;
    end
  end
  */

  always @ (posedge clk) begin
    if (rst) begin
        PCplus4OUt <= 0;
        instructionOut <= 0;
    end
    else if (!EN) begin 
        PCplus4OUt <= PCplus4OUt;
        instructionOut <= instructionOut;
    end
    else if (flush) begin 
        PCplus4OUt <= 0;
        instructionOut <= 0;
    end
    else begin 
        PCplus4OUt <= PCplus4In;
        instructionOut <= instructionIn;
    end
end

endmodule