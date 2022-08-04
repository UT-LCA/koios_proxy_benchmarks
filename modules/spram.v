module spram (
    clk,
    address,
    wren,
    data,
    out
);
parameter AWIDTH=10;
parameter NUM_WORDS=1024;
parameter DWIDTH=32;
input clk;
input [(AWIDTH-1):0] address;
input  wren;
input [(DWIDTH-1):0] data;
output [(DWIDTH-1):0] out;

`ifdef SIMULATION_MEMORY

reg [(DWIDTH-1):0] out;
reg [DWIDTH-1:0] ram[NUM_WORDS-1:0];
always @ (posedge clk) begin 
  if (wren) begin
      ram[address] <= data;
  end
  else begin
      out <= ram[address];
  end
end
  
`else

single_port_ram u_single_port_ram(
.addr(address),
.we(wren),
.data(data),
.out(out),
.clk(clk)
);

`endif

endmodule

