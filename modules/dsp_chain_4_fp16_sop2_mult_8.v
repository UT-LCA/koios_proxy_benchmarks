
module dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module_8 (input clk, input reset, input[2047:0] inp, output [255:0] outp); 

 dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module inst0 (.clk(clk),.reset(reset),.inp(inp[255:0]),.outp(outp[31:0])); 

 dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module inst1 (.clk(clk),.reset(reset),.inp(inp[511:256]),.outp(outp[63:32])); 

 dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module inst2 (.clk(clk),.reset(reset),.inp(inp[767:512]),.outp(outp[95:64])); 

 dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module inst3 (.clk(clk),.reset(reset),.inp(inp[1023:768]),.outp(outp[127:96])); 

 dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module inst4 (.clk(clk),.reset(reset),.inp(inp[1279:1024]),.outp(outp[159:128])); 

 dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module inst5 (.clk(clk),.reset(reset),.inp(inp[1535:1280]),.outp(outp[191:160])); 

 dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module inst6 (.clk(clk),.reset(reset),.inp(inp[1791:1536]),.outp(outp[223:192])); 

 dsp_chain_4_dsp_chain_4_fp16_sop2_mult_module inst7 (.clk(clk),.reset(reset),.inp(inp[2047:1792]),.outp(outp[255:224])); 

 endmodule 
