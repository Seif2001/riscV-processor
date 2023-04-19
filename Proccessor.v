`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2023 05:36:23 PM
// Design Name: 
// Module Name: Proccessor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*

module ALUControl(
    input[1:0] op,
    input[31:0] inst,
    output reg[3:0] sel
);*/

//DATAMEM Address
//CHANGE INSTMEM
//data?
//load?
//Qsize?
// modify rca
//when to assign
//first value of pc
// input pClk, input [1:0] ledSel, input [4:0] ssdSel, output[15:0]leds, output[12:0] ssd 

`include "defines.v"
//,input pClk, input [1:0] ledSel, input [3:0] ssdsel, output reg [15:0]leds, output [3:0] anode,output [6:0]ledout
module Proccessor(input clk, input reset);
    wire [31:0] pc,data;
    wire [3:0] ALUcontrol;
    wire [31:0] instruction, WriteData, Read1, Read2, imm, ALU2muxOut, ALU1muxOut, ALUresult,shiftout, branchaddOut,pcadderOUT, writeToReg, AUIPC_add_out;
    wire jalr, branch, MemRead, MemWrite, ALUsrc1, ALUsrc2, Regwrite, zf, cf, vf, sf;
    wire [1:0] pcSel;
    wire [1:0] ALUOP, Memtoreg;
    wire [3:0] readwrite;
    reg [12:0]  sevensegin;
    

    Nbit_reg #( .N(32) ) PC(.clk(clk), .load(1), .reset(reset), .data(data), .Q(pc));
    RCA pcadder (.A(pc),.B(4),.Sum(pcadderOUT));
    InstMem Instructions(.addr({2'b00,pc[5:2]}), .data_out(instruction ));
    controlUnit control(.IR(instruction), .MemRead(MemRead), .Memtoreg(Memtoreg), .MemWrite(MemWrite), .ALUsrc1(ALUsrc1), .ALUsrc2(ALUsrc2),.j(jalr), .Regwrite(Regwrite), .ALUOP(ALUOP), .read_write(readwrite));
    ALUControl ALUcon(.op(ALUOP), .inst(instruction), .sel(ALUcontrol));
    NbitReg RegFile(.clk(clk), .rst(reset),.RS1(instruction[19:15]), .RS2(instruction[24:20]), .RD(instruction[11:7]),.WData(writeToReg),.regWrite(Regwrite),.R1(Read1), .R2(Read2));
    rv32_ImmGen ImmediateGenerator(.IR(instruction), .Imm(imm));
    RCA beqadder (.A(imm),.B(pc),.Sum(branchaddOut));
     
    
    mux2by1 muxr2(.in1(Read2), .in2(imm), .sel(ALUsrc2), .out( ALU2muxOut));
    mux2by1 muxr1(.in1(Read1), .in2(pc), .sel(ALUsrc1), .out( ALU1muxOut));

    prv32_ALU Alu(.a(ALU1muxOut), .b(ALU2muxOut),. shamt(instruction[`IR_shamt]),.r(ALUresult),.zf(zf), .cf(cf), .vf(vf), .sf(sf),.alufn(ALUcontrol));
    branchUnit bu(.zf(zf), .cf(cf), .vf(vf), .sf(sf), .funct3(instruction[`IR_funct3]),.IR(instruction),.flag(branch));
    assign pcSel[0] = jalr;
    assign pcSel[1] = branch;
    DataMem DataMemory(.clk(clk), .MemRead(MemRead), .MemWrite(MemWrite), .addr({ALUresult}), .data_in(Read2),.read_write(readwrite), .data_out(WriteData));
    mux4by2 MemOrRes(.i0(ALUresult), .i1(WriteData),.i2(pcadderOUT), .i3(0), .s(Memtoreg), .out(writeToReg));
    mux4by2 muxpc(.i0(pcadderOUT),.i1(0), .i2(branchaddOut), .i3(ALUresult), .s(pcSel),.out(data));
    
    
//    always@(ledSel)begin
//    if (ledSel==2'b00)
//    leds=instruction[15:0];
    
//    else if (ledSel==2'b01)
//    leds= instruction[31:16];
//    else if(ledSel==2'b10)
  
//    leds= {8'b00000000,ALUOP,ALUcontrol,zeroFlag,andout};
//    end
//    always @(ssdsel)begin
//    if (ssdsel==4'b0000)
//    sevensegin=pc;
//    else if(ssdsel==4'b0001)
//    sevensegin=pcadderOUT;
//    else if(ssdsel==4'b0010)
//    sevensegin=beqaddOut;
//    else if(ssdsel==4'b0011)
//    sevensegin=data;
//     else if(ssdsel==4'b0100)
//    sevensegin= Read1;
//      else if(ssdsel==4'b0101)
//    sevensegin= Read2;
//     else if(ssdsel==4'b0110)
//    sevensegin= writeToReg;
//     else if(ssdsel==4'b0111)
//    sevensegin= imm;
//      else if(ssdsel==4'b1000)
//    sevensegin= shiftout;
//     else if(ssdsel==4'b1001)
//    sevensegin= ALUmuxOut;
//       else if(ssdsel==4'b1010)
//    sevensegin= ALUresult;
//        else if(ssdsel==4'b1011)
//    sevensegin= WriteData;   
//    end
    
//    Four_Digit_Seven_Segment_Driver disp(.clk(clk),.num(sevensegin), .Anode(anode), .LED_out(ledout));
      
         
    
endmodule
