`ifdef complex_dsp

`else
module int_sop_2 (mode_sigs,
	clk,
	reset,
	ax,
	ay,
	bx,
	by,
	chainin,
	resulta,
	chainout);
input [10:0] mode_sigs;
input clk;
input reset; 
input [17:0] ax, bx;
input [18:0] ay, by;
input [36:0] chainin;

output reg [36:0] resulta;
output reg [36:0] chainout;
reg [17:0] ax_reg;
reg [18:0] ay_reg;
reg [17:0] bx_reg;
reg [18:0] by_reg;
reg [36:0] resulta;
always @(posedge clk) begin
  if(reset) begin
    resulta <= 0;
    ax_reg <= 0;
    ay_reg <= 0;
    bx_reg <= 0;
    by_reg <= 0;
  end
  else begin
    ax_reg <= ax;
    ay_reg <= ay;
    bx_reg <= bx;
    by_reg <= by;
    resulta <= ax_reg * ay_reg + bx_reg * by_reg + chainin;
  end
end
assign chainout = resulta;
endmodule
`endif

