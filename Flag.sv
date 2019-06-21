`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Trevor Jones
// Date: 04/15/2019
// Description: Flag with set and clear
//////////////////////////////////////////////////////////////////////////////////


module Flag # (parameter WIDTH = 8) (
    input CLK, SET, CLR, LD, DIN,
    output logic DOUT = 0
    );
    
    always_ff @ (posedge CLK)
    begin
        if (SET)
            DOUT <= 1;
        else if (CLR)
            DOUT <= 0;
        else if (LD)
            DOUT <= DIN;
    end
        
endmodule
