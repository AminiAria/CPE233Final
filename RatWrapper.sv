`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Trevor Jones
// Date: 05/14/2019
// Description: Rat Wrapper
//////////////////////////////////////////////////////////////////////////////////


module RatWrapper(
    input clk, btnC, btnL, btnR, btnU, btnD,
    input [15:0] sw,
    input PS2CLK,
    input PS2DATA,
    output logic [15:0] led,
    output logic [7:0] seg,
    output logic [3:0] an,
    output logic [7:0] VGA_RGB,
    output VGA_HS,
    output VGA_VS
    );
    
    //constants
    localparam SWITCHES_LO_ID   = 8'h20;
    localparam SWITCHES_HI_ID   = 8'h21;
    localparam LEDS_LO_ID       = 8'h40;
    localparam LEDS_HI_ID       = 8'h41;
    localparam KEYBOARD_ID      = 8'h44;
    localparam SEG_ID_1         = 8'h81;
    localparam SEG_ID_2         = 8'h82;
    localparam VGA_HADDR_ID     = 8'h90;
    localparam VGA_LADDR_ID     = 8'h91;
    localparam VGA_COLOR_ID     = 8'h92;
    localparam VGA_READ_ID      = 8'h93;
    localparam BUTTONS_ID       = 8'hFF;
    
    //variables
    logic [7:0] output_port, port_id, input_port;
    logic [7:0] switches_lo, switches_hi, led_lo, led_hi, buttons, seg_val_1, seg_val_2;
    logic io_strb, DB_btnL;
    logic slow_clk = 0;
    assign switches_hi = sw[15:8];
    assign switches_lo = sw[7:0];
    assign led = {led_hi, led_lo};
    assign buttons = {4'h0, btnL, btnU, btnR, btnD};
    
    // Signals for connecting Keyboard Driver
    logic [7:0] s_scancode;
    logic s_interrupt;
    
    // Signals for connecting VGA Framebuffer Driver
    logic r_vga_we;             // write enable
    logic [12:0] r_vga_wa;      // address of framebuffer to read and write
    logic [7:0] r_vga_wd;       // pixel color data to write to framebuffer
    logic [7:0] r_vga_rd;       // pixel color data read from framebuffer
    
    //clock divider
    always_ff @ (posedge clk) begin
        slow_clk <= ~slow_clk;
    end
    
    //RatCPU Instance
    RatCPU CPUInst ( .CLK(slow_clk),    .RESET(btnC),   .INT(s_interrupt),   .IN_PORT(input_port), 
                     .IO_STRB(io_strb), .OUT_PORT(output_port),    .PORT_ID(port_id) );
                   
    //Drivers
    debounce_one_shot Debouncer ( .CLK(slow_clk), .BTN(btnL), .DB_BTN(DB_btnL) );
    univ_sseg SSegDecoder ( .cnt1(seg_val_1), .cnt2(seg_val_2), .valid(1), .dp_en(0), .dp_sel(0),
                            .mod_sel(1), .sign(0), .clk(clk), .ssegs(seg), .disp_en(an) );
    KeyboardDriver KEYBD (.CLK(clk), .PS2DATA(PS2DATA), .PS2CLK(PS2CLK),
                          .INTRPT(s_interrupt), .SCANCODE(s_scancode));
    vga_fb_driver VGA( .CLK(slow_clk), .WA(r_vga_wa), .WD(r_vga_wd),
                       .WE(r_vga_we), .RD(r_vga_rd), .ROUT(VGA_RGB[7:5]),
                       .GOUT(VGA_RGB[4:2]), .BOUT(VGA_RGB[1:0]),
                       .HS(VGA_HS), .VS(VGA_VS));
    
    
    //input mux
    always_comb begin
        case (port_id)
            SWITCHES_LO_ID:
                input_port = switches_lo;
            SWITCHES_HI_ID:
                input_port = switches_hi;
            BUTTONS_ID:
                input_port = buttons;
            KEYBOARD_ID:
                input_port = s_scancode;
            VGA_READ_ID:
                input_port = r_vga_rd;
            default:
                input_port = 8'h00;
        endcase
    end
    
    //output demux
    always_ff @ (posedge slow_clk) begin
        r_vga_we <= 1'b0;
        if (io_strb) begin
            case (port_id)
                LEDS_LO_ID:
                    led_lo <= output_port;
                LEDS_HI_ID:
                    led_hi <= output_port;
                SEG_ID_1:
                    seg_val_1 <= output_port;
                SEG_ID_2:
                    seg_val_2 <= output_port;
                VGA_HADDR_ID:   // Y coordinate
                    r_vga_wa[12:7] <= output_port[5:0];
                VGA_LADDR_ID:   // X coordinate
                    r_vga_wa[6:0] <= output_port[6:0];
                VGA_COLOR_ID: begin
                    r_vga_we <= 1'b1; // write enable to save data to framebuffer
                    r_vga_wd <= output_port;
                end
            endcase
        end
    end
    
endmodule
