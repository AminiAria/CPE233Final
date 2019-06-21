`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Trevor Jones
// Date: 04/11/2019
// Description: Variable width register with increment, decrement, and reset
//////////////////////////////////////////////////////////////////////////////////


module Register # (parameter WIDTH = 8) (
    input CLK, INC, DECR, RST, LD,
    input [WIDTH - 1:0] DIN,
    output logic [WIDTH - 1:0] DOUT = 0
    );
    
    always_ff @ (posedge CLK)
    begin
        if (RST)
            DOUT <= 0;
        else if (LD)
            DOUT <= DIN;
        else if (INC)
            DOUT <= DOUT + 1;
        else if (DECR)
            DOUT <= DOUT - 1;
    end
        
endmodule
