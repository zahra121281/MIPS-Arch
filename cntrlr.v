`define RT 6'b000000
`define addi 6'b001000
`define slti 6'b001010
`define lw 6'b010111
`define sw 6'b101011
`define beq 6'b000100
`define j 6'b000010
`define jal 6'b000011
`define ori 6'b001101
`define xori 6'b001111
`define bne 6'b000101
`define andi 6'b000001
`define lui 6'b000111
`define sltiu 6'b001011

// have been tested : addi, lui, ori, add , sub, and , or, xor , nor , slt , sltu
// `define RT 6'b000000
// `define addi 6'b000001
// `define slti 6'b000010
// `define lw 6'b000011
// `define sw 6'b000100
// `define beq 6'b000101
// `define j 6'b000110
// `define jal 6'b000111
// `define jr 6'b001000

module controller(
	clk,
	rst,
	opcode,
	func,
	RegDst,
	Jmp,
	DataC,
	Regwrite,
	AluSrc,
	AluSrc1,
	Branch,
	not_equal_Branch,
	MemRead,
	MemWrite,
	MemtoReg,
	AluOperation
	);
	input 				clk,rst;
	input wire      [5:0] 	opcode,func;
	output reg [1:0]	RegDst,Jmp;
	output reg		    DataC,Regwrite,AluSrc,AluSrc1,Branch,MemRead,MemWrite,MemtoReg,not_equal_Branch;
	output reg [3:0]    AluOperation;

	always@(opcode,func) begin
		{RegDst,Jmp,DataC,Regwrite,AluSrc,AluSrc1,Branch,MemRead,MemWrite,MemtoReg,AluOperation,not_equal_Branch}=0;
		case(opcode) 
			`RT: begin
				RegDst     = 2'b01;
				Regwrite   = 1'b1;
				AluSrc     = 1'b0;      // use rt
				AluSrc1    = 1'b0;      // use rs (unless shift by shamt)
				MemRead    = 1'b0;
				MemWrite   = 1'b0;
				MemtoReg   = 1'b0;
				Branch     = 1'b0;
				Jmp        = 2'b00;
				case (func)
					6'b100000: AluOperation = 4'b0000;  // add
					6'b100001: AluOperation = 4'b0000;  // addu
					6'b100010: AluOperation = 4'b0001;  // sub
					6'b100011: AluOperation = 4'b0001;  // subu
					6'b100100: AluOperation = 4'b0010;  // and
					6'b100101: AluOperation = 4'b0011;  // or
					6'b100110: AluOperation = 4'b0100;  // xor
					6'b100111: AluOperation = 4'b0101;  // nor
					6'b101010: AluOperation = 4'b0110;  // slt
					6'b101011: AluOperation = 4'b1010;  // sltu 
					// Shifts by shamt (sll, srl, sra)
					6'b000000: begin                    // sll 
						AluSrc1      = 1'b1;            // data1 = shamt, data2 = rt
						AluOperation = 4'b0111;         // <<
					end
					6'b000010: begin                    // srl
						AluSrc1      = 1'b1;
						AluOperation = 4'b1000;         // >>
					end
					6'b000011: begin                    // sra
						AluSrc1      = 1'b1;
						AluOperation = 4'b1001;         // >>>
					end
					////////////////////////////////////////////////////////////
					// Variable shifts (sllv, srlv, srav) – use rs as shift amount
					6'b000100: AluOperation = 4'b0111;  // sllv  (rs in data1, rt in data2)
					6'b000110: AluOperation = 4'b1000;  // srlv
					6'b000111: AluOperation = 4'b1001;  // srav

					// Jump instructions
					6'b001000: begin                    // jr
						Regwrite = 1'b0;
						Jmp      = 2'b10;
					end
					6'b001001: begin                    // jalr
					//	RegDst   = 2'b10;  
						Jmp      = 2'b10;
						DataC=1;
					end

					default: Regwrite = 1'b0;

					// `jr: begin
					// 	Jmp=2'b10;
					//  end
					endcase
			end
				`addi: begin
					Regwrite=1;
					AluSrc=1;
					AluOperation=4'b0000;
				 end
				`slti: begin  // Set on Less Than Immediate” in MIPS
					Regwrite=1;
					AluSrc=1;
					AluOperation=4'b0110;
				 end
				 `sltiu: begin  // Set on Less Than Immediate” in MIPS
					Regwrite=1;
					AluSrc=1;
					AluOperation=4'b1010;
				 end
				`lw: begin
					Regwrite=1;
					AluSrc=1;
					AluOperation=4'b0000;
					MemRead=1;
					MemtoReg=1;
				 end
				`sw: begin
					AluSrc=1;
					AluOperation=4'b0000;
					MemWrite=1;
				 end
				`beq: begin
					AluOperation=4'b0001;
					Branch=1;
				end
				`bne: begin
					AluOperation=4'b0001;
					not_equal_Branch=1;
				end
				`j: begin
					Jmp=2'b01;
				 end
				 // not sure yet about DataC
				`jal: begin
					RegDst=2'b10;
					DataC=1;
					Regwrite=1;
					Jmp=2'b01;
				 end
				`ori: begin
					Regwrite=1;
					AluSrc=1;
					AluOperation=4'b0011;
				end
				`xori: begin
					Regwrite=1;
					AluSrc=1;
					AluOperation=4'b0100;
				 end
				`andi: begin
					Regwrite=1;
					AluSrc=1;
					AluOperation=4'b0010;
				end
				`lui: begin
					Regwrite=1;
					AluSrc=1;
					AluOperation=4'b1111;
				 end	 
			endcase
	end
endmodule
