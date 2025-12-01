`timescale 1ns/1ns

module tb();
	reg clk, rst = 1'b0;
	wire [31:0] out1, out2;
	
	integer i;
	
	mips mips_processor(.clk(clk), .rst(rst), .out1(out1), .out2(out2));
	

	always begin
		#5 clk = ~clk;
	end

	initial begin
		clk = 1'b0;
		rst = 1'b1;

		#5000000; 

		$display("--------------------------------------------------");
		$display("       FINAL PIPELINE MEMORY DUMP                 ");
		$display("--------------------------------------------------");
	
		for (i = 0; i < 50; i = i + 1) begin
			$display("Mem[%0d] = %d", i, $signed(mips_processor.Memstage.data_mem.mem_data[i]));
		end
			
		$display("--------------------------------------------------");
		
		$stop;
	end
    
endmodule