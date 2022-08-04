
module dsp_chain_4_int_sop_4_module_8 (input clk, input reset, input[2367:0] inp, output [295:0] outp); 

 dsp_chain_4_int_sop_4_module inst0 (.clk(clk),.reset(reset),.inp(inp[295:0]),.outp(outp[36:0])); 

 dsp_chain_4_int_sop_4_module inst1 (.clk(clk),.reset(reset),.inp(inp[591:296]),.outp(outp[73:37])); 

 dsp_chain_4_int_sop_4_module inst2 (.clk(clk),.reset(reset),.inp(inp[887:592]),.outp(outp[110:74])); 

 dsp_chain_4_int_sop_4_module inst3 (.clk(clk),.reset(reset),.inp(inp[1183:888]),.outp(outp[147:111])); 

 dsp_chain_4_int_sop_4_module inst4 (.clk(clk),.reset(reset),.inp(inp[1479:1184]),.outp(outp[184:148])); 

 dsp_chain_4_int_sop_4_module inst5 (.clk(clk),.reset(reset),.inp(inp[1775:1480]),.outp(outp[221:185])); 

 dsp_chain_4_int_sop_4_module inst6 (.clk(clk),.reset(reset),.inp(inp[2071:1776]),.outp(outp[258:222])); 

 dsp_chain_4_int_sop_4_module inst7 (.clk(clk),.reset(reset),.inp(inp[2367:2072]),.outp(outp[295:259])); 

 endmodule 
