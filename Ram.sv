`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Trevor Jones
// Date: 04/22/2019
// Description: Generic dual port RAM
//////////////////////////////////////////////////////////////////////////////////


module Ram #(parameter ADDR_SIZE = 5, DATA_SIZE = 8)(
    input [ADDR_SIZE-1:0] ADRX, ADRY,
    input [DATA_SIZE-1:0] DIN,
    input CLK, WE,
    output logic [DATA_SIZE-1:0] DX_OUT, DY_OUT
    );

    logic [DATA_SIZE-1:0] mem [0:(1<<ADDR_SIZE)-1];
    
    //initialize all memory to zero
    initial begin
        for (int i = 0; i < (1<<ADDR_SIZE); i++) begin
            mem[i] = 0;
        end
    end
    
    //create synchronous write to port X
    always_ff @ (posedge CLK)
    begin
        if (WE == 1)
            mem[ADRX] <= DIN;
    end
    
    //asynchronous read to ports x and y
    assign DX_OUT = mem[ADRX];
    assign DY_OUT = mem[ADRY];    
   
endmodule
