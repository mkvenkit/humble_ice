/*

top.v

A simple test pattern using the hvsync_generator module.

Code adapted from:

DESIGNING VIDEO GAME HARDWARE IN VERILOG by Steven Hugg

*/

`default_nettype none

module blinky(
  input clk,
  output led   // LED 
);

// BEGIN - init hack
// iCE40 does not allow registers to initialised to 
// anything other than 0
// For workaround see:
// https://github.com/YosysHQ/yosys/issues/103
reg [7:0] resetn_counter = 0;
wire resetn = &resetn_counter;

always @(posedge clk) 
begin
    if (!resetn)
    begin
        resetn_counter <= resetn_counter + 1;
    end
end

reg RL;
reg [22:0] counter;

always @ (posedge clk) begin 
    if (!resetn) begin
        counter <= 0;
    end
    else begin
        counter <= counter + 1;
        if(!counter)
            RL <= ~RL;
    end
end

// set LED
assign led = RL;

endmodule
