module dsp_chain_4_fp16_sop2_mult (clk,reset,top_a1,top_b1,bot_a1,bot_b1,top_a2,top_b2,bot_a2,bot_b2,top_a3,top_b3,bot_a3,bot_b3,top_a4,top_b4,bot_a4,bot_b4,result); 

input clk;
input reset; 
input [15:0] top_a1, top_b1, bot_a1, bot_b1, top_a2, top_b2, bot_a2, bot_b2, top_a3, top_b3, bot_a3, bot_b3, top_a4, top_b4, bot_a4, bot_b4; 
output [31:0] result; 

wire [31:0] chainin0, chainin1, chainin2, chainin3;
wire [31:0] chainout0, chainout1, chainout2, chainout3; 
wire [31:0] fp32_in1, fp32_in2, fp32_in3, fp32_in4; 
wire [31:0] result1, result2, result3, result4; 

assign fp32_in1 = 32'd0; 
assign fp32_in2 = 32'd0;
assign fp32_in3 = 32'd0;
assign fp32_in4 = 32'd0;
assign chainin0 = 32'd0; 

fp16_sop2_mult_dspchain inst1 (.clk(clk),.reset(reset),.top_a(top_a1),.top_b(top_b1),.bot_a(bot_a1),.bot_b(bot_b1),.fp32_in(fp32_in1),.mode_sigs(11'd0),.chainin(chainin0),.chainout(chainout0),.result(result1)); 
fp16_sop2_mult_dspchain inst2 (.clk(clk),.reset(reset),.top_a(top_a2),.top_b(top_b2),.bot_a(bot_a2),.bot_b(bot_b2),.fp32_in(fp32_in2),.mode_sigs(11'd0),.chainin(chainout0),.chainout(chainout1),.result(result2)); 
fp16_sop2_mult_dspchain inst3 (.clk(clk),.reset(reset),.top_a(top_a3),.top_b(top_b3),.bot_a(bot_a3),.bot_b(bot_b3),.fp32_in(fp32_in3),.mode_sigs(11'd0),.chainin(chainout1),.chainout(chainout2),.result(result3)); 
fp16_sop2_mult_dspchain inst4 (.clk(clk),.reset(reset),.top_a(top_a4),.top_b(top_b4),.bot_a(bot_a4),.bot_b(bot_b4),.fp32_in(fp32_in4),.mode_sigs(11'd0),.chainin(chainout2),.chainout(chainout3),.result(result4)); 

assign result = result4;  


endmodule
