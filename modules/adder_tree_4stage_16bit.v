module adder_tree_4stage_16bit(clk,reset,inp00,inp01,inp10,inp11,inp20,inp21,inp30,inp31,inp40,inp41,inp50,inp51,inp60,inp61,inp70,inp71,sum_out);

input clk;
input reset; 
input [15:0] inp00; 
input [15:0] inp01;
input [15:0] inp10; 
input [15:0] inp11;
input [15:0] inp20; 
input [15:0] inp21;
input [15:0] inp30; 
input [15:0] inp31;
input [15:0] inp40; 
input [15:0] inp41;
input [15:0] inp50; 
input [15:0] inp51;
input [15:0] inp60; 
input [15:0] inp61;
input [15:0] inp70; 
input [15:0] inp71;
output reg [31:0] sum_out;

reg [16:0] S_0_0; 
reg [16:0] S_0_1;
reg [16:0] S_0_2;
reg [16:0] S_0_3;
reg [16:0] S_0_4;
reg [16:0] S_0_5;
reg [16:0] S_0_6;
reg [16:0] S_0_7;

always@(posedge clk) begin 

S_0_0 <= inp00 + inp01; 
S_0_1 <= inp10 + inp11;
S_0_2 <= inp20 + inp21;
S_0_3 <= inp30 + inp31;
S_0_4 <= inp40 + inp41; 
S_0_5 <= inp50 + inp51;
S_0_6 <= inp60 + inp61;
S_0_7 <= inp70 + inp71;

end 

reg [17:0] S_1_0;
reg [17:0] S_1_1;
reg [17:0] S_1_2;
reg [17:0] S_1_3;

always@(posedge clk) begin 

S_1_0 <= S_0_0 + S_0_1; 
S_1_1 <= S_0_2 + S_0_3;
S_1_2 <= S_0_4 + S_0_5; 
S_1_3 <= S_0_6 + S_0_7;

end

reg [18:0] S_2_0; 
reg [18:0] S_2_1;

always@(posedge clk) begin 

S_2_0 <= S_1_0 + S_1_1; 
S_2_1 <= S_1_2 + S_1_3;

end

always@(posedge clk) begin 

if (reset == 1'b1) begin 
  sum_out <= 32'd0; 
end
else begin 
  sum_out <= S_2_0 + S_2_1; 
end

end 

endmodule 
