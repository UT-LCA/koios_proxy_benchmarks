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

module adder_tree_1_8bit (input clk, input reset, input [15:0] inp, output reg [15:0] outp);

adder_tree_1stage_8bit inst(.clk(clk),.reset(reset),.inp00(inp[7:0]),.inp01(inp[15:8]),.sum_out(outp));

endmodule

module adder_tree_2_8bit (input clk, input reset, input [31:0] inp, output reg [15:0] outp);

adder_tree_2stage_8bit inst(.clk(clk),.reset(reset),.inp00(inp[7:0]),.inp01(inp[15:8]),.inp10(inp[23:16]),.inp11(inp[31:24]),.sum_out(outp));

endmodule

module adder_tree_3_8bit (input clk, input reset, input [63:0] inp, output reg [15:0] outp);

adder_tree_3stage_8bit inst (.clk(clk),.reset(reset),.inp00(inp[7:0]),.inp01(inp[15:8]),.inp10(inp[23:16]),.inp11(inp[31:24]),.inp20(inp[39:32]),.inp21(inp[47:40]),.inp30(inp[55:48]),.inp31(inp[63:56]),.sum_out(outp));

endmodule

module adder_tree_4_8bit (input clk, input reset, input [127:0] inp, output reg [15:0] outp);

adder_tree_4stage_8bit inst(.clk(clk),.reset(reset),.inp00(inp[7:0]),.inp01(inp[15:8]),.inp10(inp[23:16]),.inp11(inp[31:24]),.inp20(inp[39:32]),.inp21(inp[47:40]),.inp30(inp[55:48]),.inp31(inp[63:56]),.inp40(inp[71:64]),.inp41(inp[79:72]),.inp50(inp[87:80]),.inp51(inp[95:88]),.inp60(inp[103:96]),.inp61(inp[111:104]),.inp70(inp[119:112]),.inp71(inp[127:120]),.sum_out(outp));

endmodule

module adder_tree_1_4bit (input clk, input reset, input [7:0] inp, output reg [7:0] outp);

adder_tree_1stage_4bit inst(.clk(clk),.reset(reset),.inp00(inp[3:0]),.inp01(inp[7:4]),.sum_out(outp));

endmodule

module adder_tree_2_4bit (input clk, input reset, input [15:0] inp, output reg [7:0] outp);

adder_tree_2stage_4bit inst(.clk(clk),.reset(reset),.inp00(inp[3:0]),.inp01(inp[7:4]),.inp10(inp[11:8]),.inp11(inp[15:12]),.sum_out(outp));

endmodule

odule adder_tree_3_4bit (input clk, input reset, input [31:0] inp, output reg [7:0] outp);

adder_tree_3stage_4bit inst (.clk(clk),.reset(reset),.inp00(inp[3:0]),.inp01(inp[7:4]),.inp10(inp[11:8]),.inp11(inp[15:12]),.inp20(inp[19:16]),.inp21(inp[23:20]),.inp30(inp[27:24]),.inp31(inp[31:28]),.sum_out(outp));

endmodule

module adder_tree_4_4bit (input clk, input reset, input [63:0] inp, output reg [7:0] outp);

adder_tree_4stage_4bit inst(.clk(clk),.reset(reset),.inp00(inp[3:0]),.inp01(inp[7:4]),.inp10(inp[11:8]),.inp11(inp[15:12]),.inp20(inp[19:16]),.inp21(inp[23:20]),.inp30(inp[27:24]),.inp31(inp[31:28]),.inp40(inp[35:32]),.inp41(inp[39:36]),.inp50(inp[43:40]),.inp51(inp[47:44]),.inp60(inp[51:48]),.inp61(inp[55:52]),.inp70(inp[59:56]),.inp71(inp[63:60]),.sum_out(outp));

endmodule

module dpram_1024_32bit_module (input clk, input reset, input [85:0] inp, output reg [63:0] outp);

dpram inst (.clk(clk),.address_a(inp[9:0]),.address_b(inp[19:10]),.wren_a(inp[20]),.wren_b(inp[21]),.data_a(inp[53:22]),.data_b(inp[85:54]),.out_a(outp[31:0]),.out_b(outp[63:32]));

endmodule

module dpram_1024_64bit_module (input clk, input reset, input [149:0] inp, output reg [63:0] outp );

dpram_1024_64bit inst (.clk(clk),.address_a(inp[9:0]),.address_b(inp[19:10]),.wren_a(inp[20]),.wren_b(inp[21]),.data_a(inp[85:22]),.data_b(inp[149:86]),.out_a(outp[31:0]),.out_b(outp[63:32]));

endmodule

module dpram_2048_64bit_module (input clk, input reset, input [151:0] inp, output reg [127:0] outp);

dpram_2048_64bit inst (.clk(clk),.address_a(inp[10:0]),.address_b(inp[21:11]),.wren_a(inp[22]),.wren_b(inp[23]),.data_a(inp[87:24]),.data_b(inp[151:88]),.out_a(outp[63:0]),.out_b(outp[127:64]));

endmodule

module dpram_2048_32bit_module (input clk, input reset, input [87:0] inp, output reg [63:0] outp);

dpram_2048_32bit inst (.clk(clk),.address_a(inp[10:0]),.address_b(inp[21:11]),.wren_a(inp[22]),.wren_b(inp[23]),.data_a(inp[55:24]),.data_b(inp[87:56]),.out_a(outp[31:0]),.out_b(outp[63:32]));

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

module systolic_array_4_16bit (input clk, input reset, input [275:0] inp, output reg [97:0] outp);

matmul_4x4_systolic inst(
 .clk(clk),
 .reset(reset),
 .pe_reset(inp[0]),
 .start_mat_mul(inp[1]),
 .done_mat_mul(outp[0]),
 .address_mat_a(inp[11:1]),
 .address_mat_b(inp[22:12]),
 .address_mat_c(inp[33:23]),
 .address_stride_a(inp[40:33]),
 .address_stride_b(inp[48:41]),
 .address_stride_c(inp[56:49]),
 .a_data(inp[88:57]),
 .b_data(inp[120:89]),
 .a_data_in(inp[152:121]), //Data values coming in from previous matmul - systolic connections
 .b_data_in(inp[184:153]),
 .c_data_in(inp[216:185]), //Data values coming in from previous matmul - systolic shifting
 .c_data_out(outp[32:1]), //Data values going out to next matmul - systolic shifting
 .a_data_out(outp[64:33]),
 .b_data_out(outp[96:65]),
 .a_addr(inp[227:217]),
 .b_addr(inp[238:228]),
 .c_addr(inp[249:239]),
 .c_data_available(outp[97]),
 .validity_mask_a_rows(inp[252:250]),
 .validity_mask_a_cols_b_rows(inp[255:253]),
 .validity_mask_b_cols(inp[258:256]),
 .final_mat_mul_size(inp[266:259]),
 .a_loc(inp[267:260]),
 .b_loc(inp[275:268])
);

endmodule

module dsp_chain_2_int_sop_2_module (input clk, input reset, input [147:0] inp, output reg [36:0] outp);

dsp_chain_2_int_sop_2 inst(.clk(clk),.reset(reset),.ax1(inp[17:0]),.ay1(inp[36:18]),.bx1(inp[54:37]),.by1(inp[73:55]),.ax2(inp[91:74]),.ay2(inp[110:92]),.bx2(inp[128:111]),.by2(inp[147:129]),.result(outp[36:0]));

endmodule

module dsp_chain_3_int_sop_2_module (input clk, input reset, input [221:0] inp, output reg [36:0] outp);

dsp_chain_3_int_sop_2 inst(.clk(clk),.reset(reset),.ax1(inp[17:0]),.ay1(inp[36:18]),.bx1(inp[54:37]),.by1(inp[73:55]),.ax2(inp[91:74]),.ay2(inp[110:92]),.bx2(inp[128:111]),.by2(inp[147:129]),.ax3(inp[165:148]),.ay3(inp[184:166]),.bx3(inp[202:185]),.by3(inp[221:203]),.result(outp[36:0]));

endmodule

module dsp_chain_4_int_sop_2_module (input clk, input reset, input [295:0] inp, output reg [36:0] outp);

dsp_chain_4_int_sop_2 inst(.clk(clk),.reset(reset),.ax1(inp[17:0]),.ay1(inp[36:18]),.bx1(inp[54:37]),.by1(inp[73:55]),.ax2(inp[91:74]),.ay2(inp[110:92]),.bx2(inp[128:111]),.by2(inp[147:129]),.ax3(inp[165:148]),.ay3(inp[184:166]),.bx3(inp[202:185]),.by3(inp[221:203]),.ax4(inp[239:222]),.ay4(inp[258:240]),.bx4(inp[276:259]),.by4(inp[295:277]),.result(outp[36:0]));

endmodule

module dsp_chain_2_fp16_sop2_mult_module (input clk, input reset, input [127:0] inp, output reg [31:0] outp);

dsp_chain_2_fp16_sop2_mult inst(.clk(clk),.reset(reset),.top_a1(inp[15:0]),.top_b1(inp[31:16]),.bot_a1(inp[47:32]),.bot_b1(inp[63:48]),.top_a2(inp[79:64]),.top_b2(inp[95:80]),.bot_a2(inp[111:96]),.bot_b2(inp[127:112]),.result(outp));

endmodule

module dsp_chain_3_fp16_sop2_mult_module (input clk, input reset, input [191:0] inp, output reg [31:0] outp);

dsp_chain_3_fp16_sop2_mult inst(.clk(clk),.reset(reset),.top_a1(inp[15:0]),.top_b1(inp[31:16]),.bot_a1(inp[47:32]),.bot_b1(inp[63:48]),.top_a2(inp[79:64]),.top_b2(inp[95:80]),.bot_a2(inp[111:96]),.bot_b2(inp[127:112]),.top_a3(inp[143:128]),.top_b3(inp[159:144]),.bot_a3(inp[175:160]),.bot_b3(inp[191:176]),.result(outp));

endmodule

module dsp_chain_4_fp16_sop2_mult_module (input clk, input reset, input [255:0] inp, output reg [31:0] outp);

dsp_chain_4_fp16_sop2_mult inst(.clk(clk),.reset(reset),.top_a1(inp[15:0]),.top_b1(inp[31:16]),.bot_a1(inp[47:32]),.bot_b1(inp[63:48]),.top_a2(inp[79:64]),.top_b2(inp[95:80]),.bot_a2(inp[111:96]),.bot_b2(inp[127:112]),.top_a3(inp[143:128]),.top_b3(inp[159:144]),.bot_a3(inp[175:160]),.bot_b3(inp[191:176]),.top_a4(inp[207:192]),.top_b4(inp[223:208]),.bot_a4(inp[239:224]),.bot_b4(inp[255:240]),.result(outp));

endmodule

