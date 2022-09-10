/* 

    bram_buffer.v

    This module implements a 64 x 64 x 16-bit buffer using BRAM.

*/

`default_nettype none

module bram_buffer #(parameter BUFW = 64, parameter BUFH = 64) (
  input clk,
  input resetn,
  input [6:0] row,          // 0 to 127 
  input [6:0] col,          // 0 to 127
  input we,
  output reg [11:0] rgb     // 4-bit x 3 BGR 
);

// declare a reg from which 
// block RAM will be inferred 
localparam SZ = BUFW * BUFH;
// width for address to cover SZ elements
localparam WADDR = $clog2(SZ);
reg [11:0] buffer[SZ];

// initialize RAM 
`define USE_FILE
`ifdef USE_FILE 
// initialize from file 
initial begin 
    $readmemh("img.mem", buffer); 
end
`else // USE_FILE
// initialize with values 
integer k;
initial begin
    for (k = 0; k < SZ; k++) begin
        if (k < SZ/2)  
            buffer[k] = 12'h00F;
        else 
            buffer[k] = 12'hF00;
    end
end
`endif // USE_FILE

// compute read address 
wire [WADDR-1:0] read_addr = BUFW * row + col;
wire [WADDR-1:0] write_addr = BUFW * row + col;

// define read access 
always @ (posedge clk) begin
    rgb <= buffer[read_addr];
end

// define write access 
always @ (posedge clk) begin
    if (we)
        buffer[write_addr] <= 12'd0;
end

endmodule
