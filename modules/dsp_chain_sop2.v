`ifdef complex_dsp
module int_sop_2_dspchain (mode_sigs,
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

output [36:0] resulta;
output [36:0] chainout;

wire [11:0] mode_sigs_int;
assign mode_sigs_int = {1'b0, mode_sigs};

int_sop_2 inst1(.clk(clk),.reset(reset),.ax(ax),.bx(bx),.ay(ay),.by(by),.mode_sigs(mode_sigs_int),.chainin(chainin),.result(resulta),.chainout(chainout)); 

endmodule
`else
module int_sop_2_dspchain (mode_sigs,
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

output [36:0] resulta;
output [36:0] chainout;
reg [17:0] ax_reg;
reg [18:0] ay_reg;
reg [17:0] bx_reg;
reg [18:0] by_reg;
reg [36:0] resulta_reg;
reg [36:0] resultaxy_reg;
reg [36:0] resultbxy_reg;
always @(posedge clk) begin
  if(reset) begin
    resulta_reg <= 0;
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
    resultaxy_reg <= ax_reg * ay_reg;
    resultbxy_reg <= bx_reg * by_reg;
    resulta_reg <= resultaxy_reg + resultbxy_reg + chainin;
  end
end
assign resulta = resulta_reg;
assign chainout = resulta_reg;
endmodule
`endif

