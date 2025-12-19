`timescale 1ns/1ns

module IF2ID(
    clk,
    rst,
    flush,
    // freeze,
    PCplus4In,
    instructionIn,
    PCplus4OUt,
    instructionOut
    );
  input clk, rst, flush;
  // , freeze;
  input [31:0] PCplus4In, instructionIn;
  output reg [31:0] PCplus4OUt, instructionOut;

  always @ (posedge clk) begin
    if (rst) begin
      PCplus4OUt <= 0;
      instructionOut <= 0;
    end
    else begin
      // if (~freeze) begin
        if (flush) begin
          instructionOut <= 0;
          PCplus4OUt <= 0;
        end
        else begin
          instructionOut <= instructionIn;
          PCplus4OUt <= PCplus4In;
        end
      // end
    end
  end
endmodule // IF2ID
