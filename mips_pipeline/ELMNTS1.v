`timescale 1ns/1ns

// module mux3_to_1 #(parameter num_bit)(input [num_bit-1:0]data1,data2,data3, input [1:0]sel,output [num_bit-1:0]out);
	
// 	assign out=~sel[1] ? (sel[0] ? data2 : data1 ) : data3;	
// endmodule

module mux3_to_1 #(parameter num_bit = 32)
(
    input  wire [num_bit-1:0] data1,
    input  wire [num_bit-1:0] data2,
    input  wire [num_bit-1:0] data3,
    input  wire [1:0]       sel,
    output reg  [num_bit-1:0] out
);
    always @(*) begin
        case (sel)
            2'b00: out = data1;
            2'b01: out = data2;
            2'b10: out = data3;
            default: out = data1;   // or 0, but never 'z
        endcase
    end
endmodule



// module mux2_to_1 #(parameter num_bit)(input [num_bit-1:0]data1,data2, input sel,output [num_bit-1:0]out);
// 	assign out=~sel?data1:data2;
// endmodule

module mux2_to_1 #(parameter WIDTH = 32)
(
    input  wire [WIDTH-1:0] data1,
    input  wire [WIDTH-1:0] data2,
    input  wire             sel,
    output wire [WIDTH-1:0] out
);
    assign out = sel ? data2 : data1;
endmodule


module sign_extension(input [15:0]primary, output [31:0] extended);

	assign extended=$signed(primary);
endmodule

module shl2 #(parameter num_bit)(input [num_bit-1:0]adr, output [num_bit-1:0]sh_adr);

	assign sh_adr=adr<<2;
endmodule

/*
module alu(input clk,input [31:0]data1,data2, input [3:0]alu_op, output reg[31:0]alu_result, output zero_flag);
	always@(alu_op,data1,data2) begin
		alu_result=32'b0;
		case (alu_op)
            4'b0000: alu_result = data1 + data2;           // ADD / ADDU
            4'b0001: alu_result = data1 - data2;           // SUB / SUBU
            4'b0010: alu_result = data1 & data2;           // AND
            4'b0011: alu_result = data1 | data2;           // OR
            4'b0100: alu_result = data1 ^ data2;           // XOR
            4'b0101: alu_result = ~(data1 | data2);        // NOR
            4'b0110: alu_result = ($signed(data1) < $signed(data2)) ? 1 : 0;  // slt/slt i
            4'b0111: alu_result = data1 << data2[4:0];     // SLL / SLLV (variable or shamt)
            4'b1000: alu_result = data1 >> data2[4:0];     // SRL / SRLV (logical)
            4'b1001: alu_result = $signed(data1) >>> data2[4:0];    // SRA / SRAV (arithmetic)
			4'b1010: alu_result = (data1 < data2) ? 1 : 0;   
            default: alu_result = 32'd0;
        endcase
	end
	assign zero_flag=(alu_result==32'b0) ? 1'b1:1'b0;
endmodule
*/

module alu(
    // input clk,
    input [31:0] data1, data2,
    input [3:0] alu_op,
    output reg [31:0] alu_result,
    output zero_flag,
    output reg overflow
);
    
    wire signed [31:0] s_data1;
    wire signed [31:0] s_data2;
    assign s_data1 = data1;
    assign s_data2 = data2;

    always @(*) begin
        alu_result = 32'b0;
        overflow = 1'b0;

        case (alu_op)
            4'b0000: begin 
                alu_result = data1 + data2;
                if (data1[31] == data2[31] && alu_result[31] != data1[31]) 
                    overflow = 1'b1;
            end

            4'b0001: begin 
                alu_result = data1 - data2;
                if (data1[31] != data2[31] && alu_result[31] != data1[31])
                    overflow = 1'b1;
            end

            4'b1100: begin 
                alu_result = data1 + data2;
                overflow = 1'b0; 
            end

            4'b1101: begin 
                alu_result = data1 - data2;
                overflow = 1'b0; 
            end

            4'b0010: alu_result = data1 & data2;
            4'b0011: alu_result = data1 | data2;
            4'b0100: alu_result = data1 ^ data2;
            4'b0101: alu_result = ~(data1 | data2);
            
            4'b0110: begin 
                if (s_data1 < s_data2) alu_result = 32'd1;
                else alu_result = 32'd0;
            end
            
            4'b1010: alu_result = (data1 < data2) ? 32'd1 : 32'd0;

            4'b0111: alu_result = data2 << data1[4:0];
            4'b1000: alu_result = data2 >> data1[4:0];
            4'b1001: alu_result = $signed(data2) >>> data1[4:0];
            
            default: alu_result = 32'd0;
        endcase
    end
    
    assign zero_flag = (alu_result == 32'b0) ? 1'b1 : 1'b0;
endmodule


module adder(input [31:0] data1,data2, output [31:0]sum);
	
	wire co;
	assign {co,sum}=data1+data2;
endmodule


module reg_file(input clk,rst,RegWrite,input [4:0] read_reg1,read_reg2,write_reg,input [31:0]write_data,
		output [31:0]read_data1,read_data2);

	reg [31:0] register[0:31];
	integer i;
	always@(posedge clk,rst) begin
		if(rst) begin
			for(i=0;i<32;i=i+1) register[i]<=32'b0;
		end
		else begin
			if(RegWrite) register[write_reg]<=write_data;
		end
	end
	assign read_data1=register[read_reg1];
	assign read_data2=register[read_reg2];
endmodule

module inst_memory(input rst,input [31:0]adr,output [31:0]instruction) ; 
	reg [31:0]mem_inst[0:255];
	initial begin
		$readmemb("instructionmemory.txt",mem_inst);
  	end
	assign instruction=mem_inst[adr>>2];
endmodule

module data_memory(input clk,rst,mem_read,mem_write,input [31:0]adr,write_data,output reg[31:0]read_data,
		   output [31:0] out1,out2);

	reg [31:0]mem_data[0:511];
	integer i,f;

	initial begin
		$readmemb("datamemory.txt",mem_data);
  	end

	always@(posedge clk) begin
		if(mem_write) mem_data[adr>>2]<=write_data;
	end

	always@(mem_read,adr) begin
		if(mem_read) read_data<=mem_data[adr>>2];
		else read_data<=32'b0;	
	end
	
	initial begin
		$writememb("datamemory.txt",mem_data); 
  	end

	initial begin
  		f = $fopen("datamemory.txt","w");
		for(i=0;i<512;i=i+1) begin
		$fwrite(f,"%b\n",mem_data[i]);
		end
		$fclose(f);  
	end

	assign out1=mem_data[500];
	assign out2=mem_data[501];
	
endmodule

module pc(input clk,rst,input [31:0]in,output reg[31:0]out);
	always @(posedge clk or posedge rst) begin
		if(rst) out<=32'b0;
		else out<=in;
	end
endmodule
