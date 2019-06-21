`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Trevor Jones
// Date: 04/15/2019
// Description: Variable width four to one mux
//////////////////////////////////////////////////////////////////////////////////


module Mux4 # (parameter WIDTH = 4) (
    input [WIDTH - 1:0] ZERO, ONE, TWO, THREE,
    input [1:0] SEL,
    output logic [WIDTH - 1:0] MUXOUT
    );
    
    always_comb
    begin
        case (SEL)
            0: MUXOUT = ZERO;
            1: MUXOUT = ONE;
            2: MUXOUT = TWO;
            3: MUXOUT = THREE;
            default: MUXOUT = ZERO;
        endcase
    end
    
endmodule
