`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Trevor Jones
// Date: 04/23/2019
// Description: Arithmetic Logic Unit
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [3:0] SEL,
    input [7:0] A, B,
    input CIN,
    output logic C, Z,
    output logic [7:0] RESULT
    );
    
    logic [8:0] ninebit;
    
    always_comb
    begin
    
        case (SEL)
            0:  ninebit = {1'b0,A} + {1'b0,B};               //ADD
            1:  ninebit = {1'b0,A} + {1'b0,B} + {8'b0,CIN};  //ADDC
            2:  ninebit = {1'b0,A} - {1'b0,B};               //SUB
            3:  ninebit = {1'b0,A} - {1'b0,B} - {8'b0,CIN};  //SUBC
            4:  ninebit = {1'b0,A} - {1'b0,B};               //CMP
            5:  ninebit = {1'b0,A} & {1'b0,B};               //AND
            6:  ninebit = {1'b0,A} | {1'b0,B};               //OR
            7:  ninebit = {1'b0,A} ^ {1'b0,B};               //EXOR
            8:  ninebit = {1'b0,A} & {1'b0,B};               //TEST
            9:  ninebit = {A[7:0],CIN};                      //LSL
            10: ninebit = {A[0],CIN,A[7:1]};                 //LSR
            11: ninebit = {A[7:0],A[7]};                     //ROL
            12: ninebit = {A[0],A[0],A[7:1]};                //ROR
            13: ninebit = {A[0],A[7],A[7:1]};                //ASR
            14: ninebit = {1'b0,B};                          //MOV
            default: ninebit = 9'b0;                         //unused
        endcase
        
        C = ninebit[8];
        RESULT = ninebit[7:0];
        Z = (ninebit[7:0] == '0);
        
    end
    
endmodule
