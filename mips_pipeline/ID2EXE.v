`timescale 1ns/1ns

module ID2EXE(
    input clk, rst,

    // incoming from ID stage
    input [31:0] read_data1_in,
    input [31:0] read_data2_in,
    input [31:0] inst_extended_in,
    input [4:0] shamnt_in,
    input AluSrc1_in,
    input AluSrc_in,
    input [3:0] AluOperation_in,

    // outgoing to EXE stage
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] inst_extended_out,
    output reg [4:0] shamnt_out,
    output reg AluSrc1_out,
    output reg AluSrc_out,
    output reg [3:0] AluOperation_out
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        read_data1_out   <= 0;
        read_data2_out   <= 0;
        inst_extended_out <= 0;
        shamnt_out       <= 0;
        AluSrc1_out      <= 0;
        AluSrc_out       <= 0;
        AluOperation_out <= 0;
    end
    else begin
        read_data1_out   <= read_data1_in;
        read_data2_out   <= read_data2_in;
        inst_extended_out <= inst_extended_in;
        shamnt_out       <= shamnt_in;
        AluSrc1_out      <= AluSrc1_in;
        AluSrc_out       <= AluSrc_in;
        AluOperation_out <= AluOperation_in;
    end
end
endmodule
