module dpram_1024_64bit(
    clk,
    address_a,
    address_b,
    wren_a,
    wren_b,
    data_a,
    data_b,
    out_a,
    out_b
);

parameter AWIDTH=10;
parameter NUM_WORDS=1024;
parameter DWIDTH=64;
input clk;
input [(AWIDTH-1):0] address_a;
input [(AWIDTH-1):0] address_b;
input  wren_a;
input  wren_b;
input [(DWIDTH-1):0] data_a;
input [(DWIDTH-1):0] data_b;
output reg [(DWIDTH-1):0] out_a;
output reg [(DWIDTH-1):0] out_b;

dpram inst1(.clk(clk),.address_a(address_a),.address_b(address_b),.wren_a(wren_a),.wren_b(wren_b),.data_a(data_a[31:0]),.data_b(data_b[31:0]),.out_a(out_a[31:0]),.out_b(out_b[31:0])); 

dpram inst2(.clk(clk),.address_a(address_a),.address_b(address_b),.wren_a(wren_a),.wren_b(wren_b),.data_a(data_a[63:32]),.data_b(data_b[63:32]),.out_a(out_a[63:32]),.out_b(out_b[63:32]));

endmodule
