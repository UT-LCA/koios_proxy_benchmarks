
module dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module_8 (input clk, input reset, input[1023:0] inp, output [255:0] outp); 

 dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module inst0 (.clk(clk),.reset(reset),.inp(inp[127:0]),.outp(outp[31:0])); 

 dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module inst1 (.clk(clk),.reset(reset),.inp(inp[255:128]),.outp(outp[63:32])); 

 dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module inst2 (.clk(clk),.reset(reset),.inp(inp[383:256]),.outp(outp[95:64])); 

 dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module inst3 (.clk(clk),.reset(reset),.inp(inp[511:384]),.outp(outp[127:96])); 

 dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module inst4 (.clk(clk),.reset(reset),.inp(inp[639:512]),.outp(outp[159:128])); 

 dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module inst5 (.clk(clk),.reset(reset),.inp(inp[767:640]),.outp(outp[191:160])); 

 dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module inst6 (.clk(clk),.reset(reset),.inp(inp[895:768]),.outp(outp[223:192])); 

 dsp_chain_2_dsp_chain_2_fp16_sop2_mult_module inst7 (.clk(clk),.reset(reset),.inp(inp[1023:896]),.outp(outp[255:224])); 

 endmodule 
