
module dsp_chain_3_int_sop_3_module_8 (input clk, input reset, input[1775:0] inp, output [295:0] outp); 

 dsp_chain_3_int_sop_3_module inst0 (.clk(clk),.reset(reset),.inp(inp[221:0]),.outp(outp[36:0])); 

 dsp_chain_3_int_sop_3_module inst1 (.clk(clk),.reset(reset),.inp(inp[443:222]),.outp(outp[73:37])); 

 dsp_chain_3_int_sop_3_module inst2 (.clk(clk),.reset(reset),.inp(inp[665:444]),.outp(outp[110:74])); 

 dsp_chain_3_int_sop_3_module inst3 (.clk(clk),.reset(reset),.inp(inp[887:666]),.outp(outp[147:111])); 

 dsp_chain_3_int_sop_3_module inst4 (.clk(clk),.reset(reset),.inp(inp[1109:888]),.outp(outp[184:148])); 

 dsp_chain_3_int_sop_3_module inst5 (.clk(clk),.reset(reset),.inp(inp[1331:1110]),.outp(outp[221:185])); 

 dsp_chain_3_int_sop_3_module inst6 (.clk(clk),.reset(reset),.inp(inp[1553:1332]),.outp(outp[258:222])); 

 dsp_chain_3_int_sop_3_module inst7 (.clk(clk),.reset(reset),.inp(inp[1775:1554]),.outp(outp[295:259])); 

 endmodule 
