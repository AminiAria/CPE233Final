`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Trevor Jones
// Date: 04/15/2019
// Description: Variable width two to one mux
//////////////////////////////////////////////////////////////////////////////////


module Mux2 # (parameter WIDTH = 4) (
    input [WIDTH - 1:0] ZERO, ONE,
    input SEL,
    output logic [WIDTH - 1:0] MUXOUT
    );
    
    always_comb
    begin
        case (SEL)
            0: MUXOUT = ZERO;
            1: MUXOUT = ONE;
            default: MUXOUT = ZERO;
        endcase
    end
    
endmodule