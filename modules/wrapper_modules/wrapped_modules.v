module adder_tree_1_16bit (input clk,input reset,input [31:0] inp, output reg [31:0] outp);

adder_tree_1stage_16bit inst(.clk(clk),.reset(reset),.inp00(inp[15:0]),.inp01(inp[31:16]),.sum_out(outp));

endmodule 

module adder_tree_2_16bit (input clk, input reset, input [63:0] inp, output reg [31:0] outp); 

adder_tree_2stage_16bit inst(.clk(clk),.reset(reset),.inp00(inp[15:0]),.inp01(inp[31:16]),.inp10(inp[47:32]),.inp11(inp[63:48]),.sum_out(outp)); 

endmodule 

module adder_tree_3_16bit (input clk, input reset, input [127:0] inp, output reg [31:0] outp);

adder_tree_3stage_16bit inst (.clk(clk),.reset(reset),.inp00(inp[15:0]),.inp01(inp[31:16]),.inp10(inp[47:32]),.inp11(inp[63:48]),.inp20(inp[79:64]),.inp21(inp[95:80]),.inp30(inp[111:96]),.inp31(inp[127:112]),.sum_out(outp));

endmodule 

module adder_tree_4_16bit (input clk, input reset, input [255:0] inp, output reg [31:0] outp);

adder_tree_4stage_16bit inst(.clk(clk),.reset(reset),.inp00(inp[15:0]),.inp01(inp[31:16]),.inp10(inp[47:32]),.inp11(inp[63:48]),.inp20(inp[79:64]),.inp21(inp[95:80]),.inp30(inp[111:96]),.inp31(inp[127:112]),.inp40(inp[143:128]),.inp41(inp[159:144]),.inp50(inp[175:160]),.inp51(inp[191:176]),.inp60(inp[207:192]),.inp61(inp[223:208]),.inp70(inp[239:224]),.inp71(inp[255:240]),.sum_out(outp));

endmodule

module dpram_1024_32bit (input clk, input reset, input [85:0] inp, output reg [63:0] outp); 

dpram inst (.clk(clk),.address_a(inp[9:0]),.address_b(inp[19:10]),.wren_a(inp[20]),.wren_b(inp[21]),.data_a(inp[53:22]),.data_b(inp[85:54]),.out_a(outp[31:0]),.out_b(outp[63:32]));

endmodule 

module spram_1024_32bit (input clk,input reset,input [42:0] inp, output reg [31:0] outp);

spram inst (.clk(clk),.address(inp[9:0]),.wren(inp[10]),.data(inp[42:11]),.out(outp)); 

endmodule 

module tanh_16bit (input clk,input reset, input [15:0] inp, output reg [15:0] outp);

tanh inst (.x(inp),.tanh_out(outp));

endmodule 

module sigmoid_16bit (input clk,input reset, input [15:0] inp, output reg [15:0] outp);

sigmoid inst (.x(inp),.sig_out(outp));

endmodule

