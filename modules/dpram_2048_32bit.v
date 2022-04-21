module dpram_2048_32bit (
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

parameter AWIDTH=11;
parameter NUM_WORDS=2048;
parameter DWIDTH=32;
input clk;
input [(AWIDTH-1):0] address_a;
input [(AWIDTH-1):0] address_b;
input  wren_a;
input  wren_b;
input [(DWIDTH-1):0] data_a;
input [(DWIDTH-1):0] data_b;
output [(DWIDTH-1):0] out_a;
output [(DWIDTH-1):0] out_b;

wire [(DWIDTH-1):0] out_a1;
wire [(DWIDTH-1):0] out_a2;

wire wren_a1,wren_a2,wren_b1,wren_b2;

assign out_a = address_a[10]?out_a2:out_a1; 
assign out_b = address_b[10]?out_b2:out_b1;

assign wren_a2 = address_a[10]|wren_a;
assign wren_a1 = ~address_a[10]|wren_a;
assign wren_b2 = address_a[10]|wren_b;
assign wren_b1 = ~address_a[10]|wren_b;

dpram inst1(.clk(clk),.address_a(address_a[9:0]),.address_b(address_b[9:0]),.wren_a(wren_a1),.wren_b(wren_b1),.data_a(data_a),.data_b(data_b),.out_a(out_a1),.out_b(out_b1));

dpram inst2(.clk(clk),.address_a(address_a[9:0]),.address_b(address_b[9:0]),.wren_a(wren_a2),.wren_b(wren_b2),.data_a(data_a),.data_b(data_b),.out_a(out_a2),.out_b(out_b2));


endmodule
