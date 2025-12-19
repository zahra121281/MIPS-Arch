`timescale 1ns/1ns
module tb();
	reg clk,rst=1'b0;
	wire [31:0] out1,out2;
	
	mips mips_processor(.clk(clk),.rst(rst),.out1(out1),.out2(out2));
	
	always begin
		#5 clk = ~clk;
	end

initial begin
    clk = 1'b0;
	rst = 1'b1;
    #5 rst = 1'b0;
	#3000 $stop;
end
    
endmodule
