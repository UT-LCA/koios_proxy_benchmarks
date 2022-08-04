
module dsp_chain_2_int_sop_2_module_8 (input clk, input reset, input[1183:0] inp, output [295:0] outp); 

 dsp_chain_2_int_sop_2_module inst0 (.clk(clk),.reset(reset),.inp(inp[147:0]),.outp(outp[36:0])); 

 dsp_chain_2_int_sop_2_module inst1 (.clk(clk),.reset(reset),.inp(inp[295:148]),.outp(outp[73:37])); 

 dsp_chain_2_int_sop_2_module inst2 (.clk(clk),.reset(reset),.inp(inp[443:296]),.outp(outp[110:74])); 

 dsp_chain_2_int_sop_2_module inst3 (.clk(clk),.reset(reset),.inp(inp[591:444]),.outp(outp[147:111])); 

 dsp_chain_2_int_sop_2_module inst4 (.clk(clk),.reset(reset),.inp(inp[739:592]),.outp(outp[184:148])); 

 dsp_chain_2_int_sop_2_module inst5 (.clk(clk),.reset(reset),.inp(inp[887:740]),.outp(outp[221:185])); 

 dsp_chain_2_int_sop_2_module inst6 (.clk(clk),.reset(reset),.inp(inp[1035:888]),.outp(outp[258:222])); 

 dsp_chain_2_int_sop_2_module inst7 (.clk(clk),.reset(reset),.inp(inp[1183:1036]),.outp(outp[295:259])); 

 endmodule 
