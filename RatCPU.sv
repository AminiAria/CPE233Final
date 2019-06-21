`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Trevor Jones
// Date: 05/02/2019
// Description: Rat CPU
//////////////////////////////////////////////////////////////////////////////////


module RatCPU(

    //INPUTS
    input CLK, RESET, INT,
    input [7:0] IN_PORT,
    
    //OUTPUTS
    output logic IO_STRB,
    output logic [7:0] OUT_PORT, PORT_ID
    );
    
    /////////////
    // SIGNALS //
    /////////////
    
    //Program Counter and ProgRom Signals
    logic rst, pc_ld, pc_inc;
    logic [1:0] pc_mux_sel;
    logic [9:0] pc_mux_out, pc_count;
    logic [17:0] ir;
    
    //Register File Signals
    logic rf_wr;
    logic [1:0] rf_wr_sel;
    logic [7:0] rf_mux_out, dx_out, dy_out;
    
    //ALU Signals
    logic alu_opy_sel, c, z;
    logic [3:0] alu_sel;
    logic [7:0] alu_mux_out, alu_result;
    
    //Stack Pointer Signals
    logic sp_ld, sp_incr, sp_decr;
    logic [7:0] sp_data_out;
    
    //Scratch RAM Signals
    logic scr_we, scr_data_sel;
    logic [1:0] scr_addr_sel;
    logic [7:0] scr_addr;
    logic [9:0] scr_data_in, scr_data_out;
    
    //Flag Signals
    logic flg_c_set, flg_c_clr, flg_c_ld, flg_z_ld, flg_ld_sel, flg_shad_ld;
    logic c_flag, z_flag, flg_c_shad, flg_z_shad, flg_c_mux, flg_z_mux;
    logic i_set, i_clr, i_flag, i;
    
    /////////////
    // MODULES //
    /////////////
    
    //Control Unit
    ControlUnit ControlUnit ( .CLK(CLK), .C(c_flag), .Z(z_flag), .INT(i), .RESET(RESET),
                              .OPCODE_HI_5(ir[17:13]), .OPCODE_LO_2(ir[1:0]),
                              .RST(rst), .IO_STRB(IO_STRB),
                              .PC_LD(pc_ld), .PC_INC(pc_inc), .PC_MUX_SEL(pc_mux_sel),
                              .ALU_SEL(alu_sel), .ALU_OPY_SEL(alu_opy_sel),
                              .RF_WR(rf_wr), .RF_WR_SEL(rf_wr_sel),
                              .SP_LD(sp_ld), .SP_INCR(sp_incr), .SP_DECR(sp_decr),
                              .SCR_WE(scr_we), .SCR_DATA_SEL(scr_data_sel), .SCR_ADDR_SEL(scr_addr_sel),
                              .I_SET(i_set), .I_CLR(i_clr),
                              .FLG_C_SET(flg_c_set), .FLG_C_CLR(flg_c_clr), .FLG_C_LD(flg_c_ld),
                              .FLG_Z_LD(flg_z_ld), .FLG_LD_SEL(flg_ld_sel), .FLG_SHAD_LD(flg_shad_ld) );
    
    //Program Counter and ProgRom
    Mux4 #(10) PCMux ( .SEL(pc_mux_sel), .ZERO(ir[12:3]), .ONE(scr_data_out), .TWO(10'h3FF), .THREE(0), .MUXOUT(pc_mux_out) );
    Register #(10) PC ( .CLK(CLK), .RST(rst), .LD(pc_ld), .INC(pc_inc), .DIN(pc_mux_out), .DOUT(pc_count) );
    ProgRom ProgRom ( .PROG_CLK(CLK), .PROG_ADDR(pc_count), .PROG_IR(ir) );
    
    //Register File
    Mux4 #(8) RFMux ( .SEL(rf_wr_sel), .ZERO(alu_result), .ONE(scr_data_out[7:0]), .TWO(sp_data_out), .THREE(IN_PORT), .MUXOUT(rf_mux_out) );
    Ram #(5,8) RegFile ( .CLK(CLK), .DIN(rf_mux_out), .WE(rf_wr), .ADRX(ir[12:8]), .ADRY(ir[7:3]), .DX_OUT(dx_out), .DY_OUT(dy_out) );
    
    //Arithmetic Logic Unit
    Mux2 #(8) ALUMux ( .SEL(alu_opy_sel), .ZERO(dy_out), .ONE(ir[7:0]), .MUXOUT(alu_mux_out) );
    ALU ALU ( .CIN(c_flag), .SEL(alu_sel), .A(dx_out), .B(alu_mux_out), .RESULT(alu_result), .C(c), .Z(z) );
    
    //Stack Pointer and Scratch RAM
    Register #(8) SP ( .CLK(CLK), .LD(sp_ld), .INC(sp_incr), .DECR(sp_decr), .DIN(dx_out), .DOUT(sp_data_out) );
    Mux2 #(10) SCRDataMux ( .SEL(scr_data_sel), .ZERO(dx_out), .ONE(pc_count), .MUXOUT(scr_data_in) );
    Mux4 #(8) SCRAddrMux ( .SEL(scr_addr_sel), .ZERO(dy_out), .ONE(ir[7:0]), .TWO(sp_data_out), .THREE(sp_data_out-1), .MUXOUT(scr_addr) );
    Ram #(8,10) SCR ( .CLK(CLK), .DIN(scr_data_in), .WE(scr_we), .ADRX(scr_addr), .DX_OUT(scr_data_out) );
    
    //Flags
    Flag CFlag ( .CLK(CLK), .DIN(flg_c_mux), .LD(flg_c_ld), .SET(flg_c_set), .CLR(flg_c_clr), .DOUT(c_flag) );
    Flag ZFlag ( .CLK(CLK), .DIN(flg_z_mux), .LD(flg_z_ld), .DOUT(z_flag) );
    Flag ShadCFlag ( .CLK(CLK), .DIN(c_flag), .LD(flg_shad_ld), .DOUT(flg_c_shad) );
    Flag ShadZFlag ( .CLK(CLK), .DIN(z_flag), .LD(flg_shad_ld), .DOUT(flg_z_shad) );
    Mux2 CFlagMux ( .SEL(flg_ld_sel), .ZERO(c), .ONE(flg_c_shad), .MUXOUT(flg_c_mux) );
    Mux2 ZFlagMux ( .SEL(flg_ld_sel), .ZERO(z), .ONE(flg_z_shad), .MUXOUT(flg_z_mux) );
    Flag IFlag ( .CLK(CLK), .SET(i_set), .CLR(i_clr), .DOUT(i_flag) );
    assign i = INT & i_flag;
    
    assign OUT_PORT = dx_out;
    assign PORT_ID = ir[7:0];
    
endmodule
