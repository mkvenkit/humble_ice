/*

top.v

A simple test pattern using the hvsync_generator module.

VGA code adapted from:

DESIGNING VIDEO GAME HARDWARE IN VERILOG by Steven Hugg

*/

module vga_bram(
    input clk,
    output hsync,     // hysnc 
    output vsync,     // vsync
    output [3:0] R, // red 
    output [3:0] G, // green 
    output [3:0] B, // blue 
    output reg LED   // LED 
);

// PLL 
wire clk_25mhz;
wire locked;
pll pll25(
    .clock_in(clk),
    .clock_out(clk_25mhz),
    .locked(locked)
);
  

// BEGIN - init hack
// iCE40 does not allow registers to initialised to 
// anything other than 0
// For workaround see:
// https://github.com/YosysHQ/yosys/issues/103
reg [7:0] resetn_counter = 0;
wire resetn = &resetn_counter;

always @(posedge clk_25mhz) 
begin
    if (!resetn)
    begin
        resetn_counter <= resetn_counter + 1;
    end
end


wire display_on;
wire [10:0] hpos;
wire [10:0] vpos;
reg [22:0] counter;

// hook up hsync/vsync     
hvsync_generator hvsync_gen(
    .clk(clk_25mhz),
    .resetn(resetn),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
);

// bram module
reg [6:0] offset;
wire [11:0] rgb;
wire we = 1'b0;
bram_buffer buf_rgb (
    .clk(clk_25mhz),
    .resetn(resetn),
    .row(vpos[6:0]),
    .col(hpos[6:0] + offset),
    .we(we),
    .rgb(rgb)
);

// assign RGB out 
assign {B, G, R} = display_on ? rgb : 12'd0;

reg RL;
reg [22:0] counter;

always @ (posedge clk_25mhz) begin 
    if (!resetn) begin
        counter <= 0;
        LED <= 0;
    end
    else begin
        counter <= counter + 1;
        // LED blink
        if(!counter)
            LED <= ~LED;
        // update offset for scrolling
        if(!counter[20:0]) begin
            offset <= offset + 1; 
        end
    end
end

endmodule
