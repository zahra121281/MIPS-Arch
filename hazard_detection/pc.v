`timescale 1ns/1ns

module pc(
    input              clk,
    input              rst,
    input              en,   
    input      [31:0]  in,
    output reg [31:0]  out
    );

    always @(posedge clk) begin
        if (rst) begin
            out <= 32'b0;
        end
        else if (en) begin
            
            out <= in;
        end
       
    end

endmodule