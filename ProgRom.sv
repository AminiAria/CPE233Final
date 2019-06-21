`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   Cal Poly
// Engineer:  Paul Hummel
// 
// Create Date: 06/28/2018 01:00:34 AM
// Module Name: ProgRom
// Target Devices: RAT MCU on Basys3
// Description:  Generic 1024x18 ROM device
// 
// Dependencies: prog_rom.mem file is a raw listing of 1024 18-bit hex values
//               prog_rom.mem file is automatically created by the RAT
//               assembler / simulator from an assembly code program.
// 
// Revision:
// Revision 0.01 - File Created
// 
////////////////////////////////////////////////////////////////////////////////


module ProgRom(
    input PROG_CLK,
    input [9:0] PROG_ADDR,
    output logic [17:0] PROG_IR
    );
     
    (* rom_style="{distributed | block}" *)  // force the ROM to be block memory
    logic [17:0] rom[0:1023];
    
    // initialize the ROM with the prog_rom.mem file
    initial begin
        $readmemh("finalproject.mem", rom, 0, 1023);
    end 
    
    always_ff @(posedge PROG_CLK) begin
        PROG_IR <= rom[PROG_ADDR];
    end
              
endmodule