module dsp_chain_2_fp16_sop2_mult (clk,reset,top_a1,top_b1,bot_a1,bot_b1,top_a2,top_b2,bot_a2,bot_b2,result); 

input clk;
input reset; 
input [15:0] top_a1, top_b1, bot_a1, bot_b1, top_a2, top_b2, bot_a2, bot_b2; 
output [31:0] result; 

wire [31:0] chainin0, chainin1;
wire [31:0] chainout0, chainout1; 
wire [31:0] fp32_in1, fp32_in2; 
wire [31:0] result1, result2; 

assign fp32_in1 = 32'd0; 
assign fp32_in2 = 32'd0; 
//assign chainin0 = 32'd0; 

fp16_sop2_mult_dspchain inst1 (.clk(clk),.reset(reset),.top_a(top_a1),.top_b(top_b1),.bot_a(bot_a1),.bot_b(bot_b1),.fp32_in(fp32_in1),.mode_sigs(11'd0),.chainin(chainin0),.chainout(chainout0),.result(result1)); 
fp16_sop2_mult_dspchain inst2 (.clk(clk),.reset(reset),.top_a(top_a2),.top_b(top_b2),.bot_a(bot_a2),.bot_b(bot_b2),.fp32_in(fp32_in2),.mode_sigs(11'd0),.chainin(chainout0),.chainout(chainout1),.result(result2)); 

assign result = result2;  


endmodule
