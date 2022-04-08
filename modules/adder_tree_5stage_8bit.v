module adder_tree_5stage_8bit (clk,reset,inp_00,inp_01,inp_10,inp_11,inp_20,inp_21,inp_30,inp_31,inp_40,inp_41,
inp_50,inp_51,inp_60,inp_61,inp_70,inp_71,inp_80,inp_81,inp_90,inp_91,inp_100,inp_101,
inp_110,inp_111,inp_120,inp_121,inp_130,inp_131,inp_140,inp_141,inp_150,inp_151,sum_out);

input clk;
input reset;
input [7:0] inp_00;
input [7:0] inp_01;
input [7:0] inp_10;
input [7:0] inp_11;
input [7:0] inp_20;
input [7:0] inp_21;
input [7:0] inp_30;
input [7:0] inp_31;
input [7:0] inp_40;
input [7:0] inp_41;
input [7:0] inp_50;
input [7:0] inp_51;
input [7:0] inp_60;
input [7:0] inp_61;
input [7:0] inp_70;
input [7:0] inp_71;
input [7:0] inp_80;
input [7:0] inp_81;
input [7:0] inp_90;
input [7:0] inp_91;
input [7:0] inp_100;
input [7:0] inp_101;
input [7:0] inp_110;
input [7:0] inp_111;
input [7:0] inp_120;
input [7:0] inp_121;
input [7:0] inp_130;
input [7:0] inp_131;
input [7:0] inp_140;
input [7:0] inp_141;
input [7:0] inp_150;
input [7:0] inp_151;
output reg [15:0] sum_out;

reg [8:0] S_0_0;
reg [8:0] S_0_1;
reg [8:0] S_0_2;
reg [8:0] S_0_3;
reg [8:0] S_0_4;
reg [8:0] S_0_5;
reg [8:0] S_0_6;
reg [8:0] S_0_7;
reg [8:0] S_0_8;
reg [8:0] S_0_9;
reg [8:0] S_0_10;
reg [8:0] S_0_11;
reg [8:0] S_0_12;
reg [8:0] S_0_13;
reg [8:0] S_0_14;
reg [8:0] S_0_15;

always@(posedge clk) begin

S_0_0 <= inp_00 + inp_01;
S_0_1 <= inp_10 + inp_11;
S_0_2 <= inp_20 + inp_21;
S_0_3 <= inp_30 + inp_31;
S_0_4 <= inp_40 + inp_41;
S_0_5 <= inp_50 + inp_51;
S_0_6 <= inp_60 + inp_61;
S_0_7 <= inp_70 + inp_71;
S_0_8 <= inp_80 + inp_81;
S_0_9 <= inp_90 + inp_91;
S_0_10 <= inp_100 + inp_101;
S_0_11 <= inp_110 + inp_111;
S_0_12 <= inp_120 + inp_121;
S_0_13 <= inp_130 + inp_131;
S_0_14 <= inp_140 + inp_141;
S_0_15 <= inp_150 + inp_151;

end

reg [9:0] S_1_0;
reg [9:0] S_1_1;
reg [9:0] S_1_2;
reg [9:0] S_1_3;
reg [9:0] S_1_4;
reg [9:0] S_1_5;
reg [9:0] S_1_6;
reg [9:0] S_1_7;


always@(posedge clk) begin

S_1_0 <= S_0_0 + S_0_1;
S_1_1 <= S_0_2 + S_0_3;
S_1_2 <= S_0_4 + S_0_5;
S_1_3 <= S_0_6 + S_0_7;
S_1_4 <= S_0_8 + S_0_9;
S_1_5 <= S_0_10 + S_0_11;
S_1_6 <= S_0_12 + S_0_13;
S_1_7 <= S_0_14 + S_0_15;

end

reg [10:0] S_2_0; 
reg [10:0] S_2_1; 
reg [10:0] S_2_2; 
reg [10:0] S_2_3;

always@(posedge clk) begin 

S_2_0 <= S_1_0 + S_1_1; 
S_2_1 <= S_1_2 + S_1_3;
S_2_2 <= S_1_4 + S_1_5;
S_2_3 <= S_1_6 + S_1_7;

end

reg [11:0] S_3_0; 
reg [11:0] S_3_1; 

always@(posedge clk) begin 

S_3_0 <= S_2_0 + S_2_1; 
S_3_1 <= S_2_2 + S_2_3; 

end

always@(posedge clk) begin 

	if (reset == 1'b1) begin 
		sum_out <= 16'd0;
	end	
	else begin 
		sum_out <= S_3_0 + S_3_1; 
	end

end

endmodule

