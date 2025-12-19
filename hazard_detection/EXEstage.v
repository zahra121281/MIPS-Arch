`timescale 1ns/1ns

module EXEstage (
    input wire              clk, 
    input wire [31:0]       read_data1_reg, 
    input wire [31:0]       read_data2_reg, 
    input wire [31:0]       inst_extended,  
    input wire [4:0]        shamnt,         
    input wire              AluSrc1,        
    input wire              AluSrc,         
    input wire [3:0]        AluOperation,   

   
    input wire [31:0]       alu_result_MEM, 
    input wire [31:0]       result_WB,      
    input wire [1:0]        ForwardA,       
    input wire [1:0]        ForwardB,       

   
    output wire             zero_flag,
    output wire [31:0]      alu_result, 
    output wire             overflow,
    

    output wire [31:0]      write_data_out 
);
    
    reg [31:0] mux_A_out; 
    reg [31:0] mux_B_out; 


    wire [31:0] alu_input1;
    wire [31:0] alu_input2;
    wire [31:0] shamnt_extended;


    assign shamnt_extended = {27'b0, shamnt};

    // ==========================================
    // 1. FORWARDING MUXES 
    // ==========================================
    
   
    always @(*) begin
        case (ForwardA)
            2'b00: mux_A_out = read_data1_reg; 
            2'b10: mux_A_out = alu_result_MEM; 
            2'b01: mux_A_out = result_WB;      
            default: mux_A_out = read_data1_reg;
        endcase
    end

    always @(*) begin
        case (ForwardB)
            2'b00: mux_B_out = read_data2_reg; 
            2'b10: mux_B_out = alu_result_MEM; 
            2'b01: mux_B_out = result_WB;     
            default: mux_B_out = read_data2_reg;
        endcase
    end

    // ==========================================
    // 2. ALU SOURCE MUXES 
    // ==========================================


    mux2_to_1 #32 alu_mux1(
        // .clk(clk),
        .data1(mux_A_out), 
        .data2(shamnt_extended),
        .sel(AluSrc1),
        .out(alu_input1)
    );


    mux2_to_1 #32 alu_mux2(
        // .clk(clk),
        .data1(mux_B_out),
        .data2(inst_extended),
        .sel(AluSrc),
        .out(alu_input2)
    );

    // ==========================================
    // 3. ALU INSTANTIATION
    // ==========================================
    alu ALU(
        // .clk(clk), 
        .data1(alu_input1),
        .data2(alu_input2),
        .alu_op(AluOperation),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .overflow(overflow)
    );
    
    // ==========================================
    // 4. OUTPUT ASSIGNMENT
    // ==========================================
    

    assign write_data_out = mux_B_out;

endmodule