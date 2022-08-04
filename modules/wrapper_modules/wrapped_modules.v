module adder_tree_1_16bit (input clk,input reset,input [31:0] inp, output [31:0] outp);

adder_tree_1stage_16bit inst(.clk(clk),.reset(reset),.inp00(inp[15:0]),.inp01(inp[31:16]),.sum_out(outp));

endmodule

module adder_tree_2_16bit (input clk, input reset, input [63:0] inp, output [31:0] outp);

adder_tree_2stage_16bit inst(.clk(clk),.reset(reset),.inp00(inp[15:0]),.inp01(inp[31:16]),.inp10(inp[47:32]),.inp11(inp[63:48]),.sum_out(outp));

endmodule

module adder_tree_3_16bit (input clk, input reset, input [127:0] inp, output [31:0] outp);

adder_tree_3stage_16bit inst (.clk(clk),.reset(reset),.inp00(inp[15:0]),.inp01(inp[31:16]),.inp10(inp[47:32]),.inp11(inp[63:48]),.inp20(inp[79:64]),.inp21(inp[95:80]),.inp30(inp[111:96]),.inp31(inp[127:112]),.sum_out(outp));

endmodule

module adder_tree_4_16bit (input clk, input reset, input [255:0] inp, output [31:0] outp);

adder_tree_4stage_16bit inst(.clk(clk),.reset(reset),.inp00(inp[15:0]),.inp01(inp[31:16]),.inp10(inp[47:32]),.inp11(inp[63:48]),.inp20(inp[79:64]),.inp21(inp[95:80]),.inp30(inp[111:96]),.inp31(inp[127:112]),.inp40(inp[143:128]),.inp41(inp[159:144]),.inp50(inp[175:160]),.inp51(inp[191:176]),.inp60(inp[207:192]),.inp61(inp[223:208]),.inp70(inp[239:224]),.inp71(inp[255:240]),.sum_out(outp));

endmodule

module adder_tree_1_8bit (input clk, input reset, input [15:0] inp, output [15:0] outp);

adder_tree_1stage_8bit inst(.clk(clk),.reset(reset),.inp00(inp[7:0]),.inp01(inp[15:8]),.sum_out(outp));

endmodule

module adder_tree_2_8bit (input clk, input reset, input [31:0] inp, output [15:0] outp);

adder_tree_2stage_8bit inst(.clk(clk),.reset(reset),.inp00(inp[7:0]),.inp01(inp[15:8]),.inp10(inp[23:16]),.inp11(inp[31:24]),.sum_out(outp));

endmodule

module adder_tree_3_8bit (input clk, input reset, input [63:0] inp, output [15:0] outp);

adder_tree_3stage_8bit inst (.clk(clk),.reset(reset),.inp00(inp[7:0]),.inp01(inp[15:8]),.inp10(inp[23:16]),.inp11(inp[31:24]),.inp20(inp[39:32]),.inp21(inp[47:40]),.inp30(inp[55:48]),.inp31(inp[63:56]),.sum_out(outp));

endmodule

module adder_tree_4_8bit (input clk, input reset, input [127:0] inp, output [15:0] outp);

adder_tree_4stage_8bit inst(.clk(clk),.reset(reset),.inp00(inp[7:0]),.inp01(inp[15:8]),.inp10(inp[23:16]),.inp11(inp[31:24]),.inp20(inp[39:32]),.inp21(inp[47:40]),.inp30(inp[55:48]),.inp31(inp[63:56]),.inp40(inp[71:64]),.inp41(inp[79:72]),.inp50(inp[87:80]),.inp51(inp[95:88]),.inp60(inp[103:96]),.inp61(inp[111:104]),.inp70(inp[119:112]),.inp71(inp[127:120]),.sum_out(outp));

endmodule

module adder_tree_1_4bit (input clk, input reset, input [7:0] inp, output [7:0] outp);

adder_tree_1stage_4bit inst(.clk(clk),.reset(reset),.inp00(inp[3:0]),.inp01(inp[7:4]),.sum_out(outp));

endmodule

module adder_tree_2_4bit (input clk, input reset, input [15:0] inp, output [7:0] outp);

adder_tree_2stage_4bit inst(.clk(clk),.reset(reset),.inp00(inp[3:0]),.inp01(inp[7:4]),.inp10(inp[11:8]),.inp11(inp[15:12]),.sum_out(outp));

endmodule

module adder_tree_3_4bit (input clk, input reset, input [31:0] inp, output [7:0] outp);

adder_tree_3stage_4bit inst (.clk(clk),.reset(reset),.inp00(inp[3:0]),.inp01(inp[7:4]),.inp10(inp[11:8]),.inp11(inp[15:12]),.inp20(inp[19:16]),.inp21(inp[23:20]),.inp30(inp[27:24]),.inp31(inp[31:28]),.sum_out(outp));

endmodule

module adder_tree_4_4bit (input clk, input reset, input [63:0] inp, output [7:0] outp);

adder_tree_4stage_4bit inst(.clk(clk),.reset(reset),.inp00(inp[3:0]),.inp01(inp[7:4]),.inp10(inp[11:8]),.inp11(inp[15:12]),.inp20(inp[19:16]),.inp21(inp[23:20]),.inp30(inp[27:24]),.inp31(inp[31:28]),.inp40(inp[35:32]),.inp41(inp[39:36]),.inp50(inp[43:40]),.inp51(inp[47:44]),.inp60(inp[51:48]),.inp61(inp[55:52]),.inp70(inp[59:56]),.inp71(inp[63:60]),.sum_out(outp));

endmodule

module adder_tree_3_fp16bit (input clk, input reset, input [131:0] inp, output [15:0] outp);

mode4_adder_tree inst(
  .inp0(inp[15:0]),
  .inp1(inp[31:16]),
  .inp2(inp[47:32]),
  .inp3(inp[63:48]),
  .inp4(inp[79:64]),
  .inp5(inp[95:80]),
  .inp6(inp[111:96]),
  .inp7(inp[127:112]),
  .mode4_stage0_run(inp[128]),
  .mode4_stage1_run(inp[129]),
  .mode4_stage2_run(inp[130]),
  .mode4_stage3_run(inp[131]),

  .clk(clk),
  .reset(reset),
  .outp(outp[15:0])
);

endmodule

module dpram_1024_32bit_module (input clk, input reset, input [85:0] inp, output [63:0] outp);

dpram inst (.clk(clk),.address_a(inp[9:0]),.address_b(inp[19:10]),.wren_a(inp[20]),.wren_b(inp[21]),.data_a(inp[53:22]),.data_b(inp[85:54]),.out_a(outp[31:0]),.out_b(outp[63:32]));

endmodule

module dpram_1024_64bit_module (input clk, input reset, input [149:0] inp, output [63:0] outp );

dpram_1024_64bit inst (.clk(clk),.address_a(inp[9:0]),.address_b(inp[19:10]),.wren_a(inp[20]),.wren_b(inp[21]),.data_a(inp[85:22]),.data_b(inp[149:86]),.out_a(outp[31:0]),.out_b(outp[63:32]));

endmodule

module dpram_2048_64bit_module (input clk, input reset, input [151:0] inp, output [127:0] outp);

dpram_2048_64bit inst (.clk(clk),.address_a(inp[10:0]),.address_b(inp[21:11]),.wren_a(inp[22]),.wren_b(inp[23]),.data_a(inp[87:24]),.data_b(inp[151:88]),.out_a(outp[63:0]),.out_b(outp[127:64]));

endmodule

module dpram_2048_32bit_module (input clk, input reset, input [87:0] inp, output [63:0] outp);

dpram_2048_32bit inst (.clk(clk),.address_a(inp[10:0]),.address_b(inp[21:11]),.wren_a(inp[22]),.wren_b(inp[23]),.data_a(inp[55:24]),.data_b(inp[87:56]),.out_a(outp[31:0]),.out_b(outp[63:32]));

endmodule

module dpram_1024_40bit_module (input clk, input reset, input [101:0] inp, output [79:0] outp);

dpram_1024_40bit inst (.clk(clk),.address_a(inp[9:0]),.address_b(inp[19:10]),.wren_a(inp[20]),.wren_b(inp[21]),.data_a(inp[61:22]),.data_b(inp[101:62]),.out_a(outp[39:0]),.out_b(outp[79:40]));

endmodule

module dpram_1024_60bit_module (input clk, input reset, input [141:0] inp, output [119:0] outp);

dpram_1024_60bit inst (.clk(clk),.address_a(inp[9:0]),.address_b(inp[19:10]),.wren_a(inp[20]),.wren_b(inp[21]),.data_a(inp[81:22]),.data_b(inp[141:82]),.out_a(outp[59:0]),.out_b(outp[119:60]));

endmodule

module dpram_2048_40bit_module (input clk, input reset, input [103:0] inp, output [79:0] outp);

dpram_2048_40bit inst (.clk(clk),.address_a(inp[10:0]),.address_b(inp[21:11]),.wren_a(inp[22]),.wren_b(inp[23]),.data_a(inp[63:24]),.data_b(inp[103:64]),.out_a(outp[39:0]),.out_b(outp[79:40]));

endmodule

module dpram_2048_60bit_module (input clk, input reset, input [143:0] inp, output [119:0] outp);

dpram_2048_60bit inst (.clk(clk),.address_a(inp[10:0]),.address_b(inp[21:11]),.wren_a(inp[22]),.wren_b(inp[23]),.data_a(inp[83:24]),.data_b(inp[143:84]),.out_a(outp[59:0]),.out_b(outp[119:60]));

endmodule

module dpram_4096_40bit_module (input clk, input reset, input [105:0] inp, output [79:0] outp);

dpram_4096_40bit inst (.clk(clk),.address_a(inp[11:0]),.address_b(inp[23:12]),.wren_a(inp[24]),.wren_b(inp[25]),.data_a(inp[65:26]),.data_b(inp[105:66]),.out_a(outp[39:0]),.out_b(outp[79:40]));

endmodule

module dpram_4096_60bit_module (input clk, input reset, input [145:0] inp, output [119:0] outp);

dpram_4096_60bit inst (.clk(clk),.address_a(inp[11:0]),.address_b(inp[23:12]),.wren_a(inp[24]),.wren_b(inp[25]),.data_a(inp[85:26]),.data_b(inp[145:86]),.out_a(outp[59:0]),.out_b(outp[119:60]));

endmodule

module spram_1024_32bit_module (input clk,input reset,input [42:0] inp, output [31:0] outp);

spram inst (.clk(clk),.address(inp[9:0]),.wren(inp[10]),.data(inp[42:11]),.out(outp));

endmodule

module spram_2048_40bit_module (input clk,input reset,input [51:0] inp, output [39:0] outp);

spram_2048_40bit inst (.clk(clk),.address(inp[10:0]),.wren(inp[11]),.data(inp[51:12]),.out(outp));

endmodule

module spram_2048_60bit_module (input clk,input reset,input [71:0] inp, output [59:0] outp);

spram_2048_60bit inst (.clk(clk),.address(inp[10:0]),.wren(inp[11]),.data(inp[71:12]),.out(outp));

endmodule

module spram_4096_40bit_module (input clk,input reset,input [52:0] inp, output [39:0] outp);

spram_4096_40bit inst (.clk(clk),.address(inp[11:0]),.wren(inp[12]),.data(inp[52:13]),.out(outp));

endmodule

module spram_4096_60bit_module (input clk,input reset,input [72:0] inp, output [59:0] outp);

spram_4096_60bit inst (.clk(clk),.address(inp[11:0]),.wren(inp[12]),.data(inp[72:13]),.out(outp));

endmodule

module dbram_2048_40bit_module (input clk,input reset,input [103:0] inp, output [79:0] outp);

dbram_2048_40bit inst (.clk(clk),.reset(reset),.address_a(inp[10:0]),.address_b(inp[21:11]),.wren_a(inp[22]),.wren_b(inp[23]),.data_a(inp[63:24]),.data_b(inp[103:64]),.out_a(outp[39:0]),.out_b(outp[79:40]));

endmodule

module dbram_2048_60bit_module (input clk,input reset,input [143:0] inp, output [119:0] outp);

dbram_2048_60bit inst (.clk(clk),.reset(reset),.address_a(inp[10:0]),.address_b(inp[21:11]),.wren_a(inp[22]),.wren_b(inp[23]),.data_a(inp[83:24]),.data_b(inp[143:84]),.out_a(outp[59:0]),.out_b(outp[119:60]));

endmodule

module dbram_4096_40bit_module (input clk,input reset,input [105:0] inp, output [79:0] outp);

dbram_4096_40bit inst (.clk(clk),.reset(reset),.address_a(inp[11:0]),.address_b(inp[23:12]),.wren_a(inp[24]),.wren_b(inp[25]),.data_a(inp[65:26]),.data_b(inp[105:66]),.out_a(outp[39:0]),.out_b(outp[79:40]));

endmodule

module dbram_4096_60bit_module (input clk,input reset,input [145:0] inp, output [119:0] outp);

dbram_4096_60bit inst (.clk(clk),.reset(reset),.address_a(inp[11:0]),.address_b(inp[23:12]),.wren_a(inp[24]),.wren_b(inp[25]),.data_a(inp[85:26]),.data_b(inp[145:86]),.out_a(outp[59:0]),.out_b(outp[119:60]));

endmodule


module fifo_256_40bit_module (input clk,input reset,input [42:0] inp, output [41:0] outp);

fifo_256_40bit inst (.clk(clk),.rst(reset),.clr(inp[0]),.din(inp[40:1]),.we(inp[41]),.dout(outp[39:0]),.re(inp[42]),.full(outp[40]),.empty(outp[41]));

endmodule

module fifo_256_60bit_module (input clk,input reset,input [62:0] inp, output [61:0] outp);

fifo_256_60bit inst (.clk(clk),.rst(reset),.clr(inp[0]),.din(inp[60:1]),.we(inp[61]),.dout(outp[59:0]),.re(inp[62]),.full(outp[60]),.empty(outp[61]));

endmodule

module fifo_512_60bit_module (input clk,input reset,input [62:0] inp, output [61:0] outp);

fifo_512_60bit inst (.clk(clk),.rst(reset),.clr(inp[0]),.din(inp[60:1]),.we(inp[61]),.dout(outp[59:0]),.re(inp[62]),.full(outp[60]),.empty(outp[61]));

endmodule

module fifo_512_40bit_module (input clk,input reset,input [42:0] inp, output [41:0] outp);

fifo_512_40bit inst (.clk(clk),.rst(reset),.clr(inp[0]),.din(inp[40:1]),.we(inp[41]),.dout(outp[39:0]),.re(inp[42]),.full(outp[40]),.empty(outp[41]));

endmodule

module tanh_16bit (input clk,input reset, input [15:0] inp, output [15:0] outp);

tanh inst (.x(inp),.tanh_out(outp));

endmodule

module sigmoid_16bit (input clk,input reset, input [15:0] inp, output [15:0] outp);

sigmoid inst (.x(inp),.sig_out(outp));

endmodule

module systolic_array_4_16bit (input clk, input reset, input [254:0] inp, output [130:0] outp);

matmul_4x4_systolic inst(
 .clk(clk),
 .reset(inp[254]),
 .pe_reset(reset),
 .start_mat_mul(inp[0]),
 .done_mat_mul(outp[0]),
 .address_mat_a(inp[11:1]),
 .address_mat_b(inp[22:12]),
 .address_mat_c(inp[33:23]),
 .address_stride_a(inp[41:34]),
 .address_stride_b(inp[49:42]),
 .address_stride_c(inp[57:50]),
 .a_data(inp[89:58]),
 .b_data(inp[121:90]),
 .a_data_in(inp[153:122]), //Data values coming in from previous matmul - systolic connections
 .b_data_in(inp[185:154]),
 .c_data_in(inp[217:186]), //Data values coming in from previous matmul - systolic shifting
 .c_data_out(outp[32:1]), //Data values going out to next matmul - systolic shifting
 .a_data_out(outp[64:33]),
 .b_data_out(outp[96:65]),
 .a_addr(outp[107:97]),
 .b_addr(outp[118:108]),
 .c_addr(outp[129:119]),
 .c_data_available(outp[130]),
 .validity_mask_a_rows(inp[221:218]),
 .validity_mask_a_cols_b_rows(inp[225:222]),
 .validity_mask_b_cols(inp[229:226]),
 .final_mat_mul_size(inp[237:230]),
 .a_loc(inp[245:238]),
 .b_loc(inp[253:246])
);

endmodule

module systolic_array_8_16bit (input clk, input reset, input [785:0] inp, output [433:0] outp);

matmul_8x8_systolic inst(
 .clk(clk),
 .reset(reset),
 .pe_reset(inp[785]),
 .start_mat_mul(inp[0]),
 .done_mat_mul(outp[0]),
 .address_mat_a(inp[16:1]),
 .address_mat_b(inp[32:17]),
 .address_mat_c(inp[48:33]),
 .address_stride_a(inp[64:49]),
 .address_stride_b(inp[80:65]),
 .address_stride_c(inp[96:81]),
 .a_data(inp[224:97]),
 .b_data(inp[352:225]),
 .a_data_in(inp[480:353]), //Data values coming in from previous matmul - systolic connections
 .b_data_in(inp[608:481]),
 .c_data_in(inp[736:609]), //Data values coming in from previous matmul - systolic shifting
 .c_data_out(outp[128:1]), //Data values going out to next matmul - systolic shifting
 .a_data_out(outp[256:129]),
 .b_data_out(outp[384:257]),
 .a_addr(outp[400:385]),
 .b_addr(outp[416:401]),
 .c_addr(outp[432:417]),
 .c_data_available(outp[433]),
 .validity_mask_a_rows(inp[744:737]),
 .validity_mask_a_cols_b_rows(inp[752:745]),
 .validity_mask_b_cols(inp[760:753]),
 .final_mat_mul_size(inp[768:761]),
 .a_loc(inp[776:769]),
 .b_loc(inp[784:777])
);

endmodule

module systolic_array_4_fp16bit (input clk, input reset, input [417:0] inp, output [223:0] outp);

matmul_4x4_fp_systolic inst(
 .clk(clk),
 .reset(reset),
 .pe_reset(inp[417]),
 .start_mat_mul(inp[0]),
 .done_mat_mul(outp[0]),
 .address_mat_a(inp[10:1]),
 .address_mat_b(inp[20:11]),
 .address_mat_c(inp[30:21]),
 .address_stride_a(inp[40:31]),
 .address_stride_b(inp[50:41]),
 .address_stride_c(inp[60:51]),
 .a_data(inp[124:61]),
 .b_data(inp[188:125]),
 .a_data_in(inp[252:189]), //Data values coming in from previous matmul - systolic connections
 .b_data_in(inp[316:253]),
 .c_data_in(inp[380:317]), //Data values coming in from previous matmul - systolic shifting
 .c_data_out(outp[64:1]), //Data values going out to next matmul - systolic shifting
 .a_data_out(outp[128:65]),
 .b_data_out(outp[192:129]),
 .a_addr(outp[202:193]),
 .b_addr(outp[212:203]),
 .c_addr(outp[222:213]),
 .c_data_available(outp[223]),
 .validity_mask_a_rows(inp[384:381]),
 .validity_mask_a_cols_b_rows(inp[388:385]),
 .validity_mask_b_cols(inp[392:389]),
 .final_mat_mul_size(inp[400:393]),
 .a_loc(inp[408:401]),
 .b_loc(inp[416:409])
);

endmodule

module dsp_chain_2_int_sop_2_module (input clk, input reset, input [147:0] inp, output [36:0] outp);

dsp_chain_2_int_sop_2 inst(.clk(clk),.reset(reset),.ax1(inp[17:0]),.ay1(inp[36:18]),.bx1(inp[54:37]),.by1(inp[73:55]),.ax2(inp[91:74]),.ay2(inp[110:92]),.bx2(inp[128:111]),.by2(inp[147:129]),.result(outp[36:0]));

endmodule

module dsp_chain_3_int_sop_2_module (input clk, input reset, input [221:0] inp, output [36:0] outp);

dsp_chain_3_int_sop_2 inst(.clk(clk),.reset(reset),.ax1(inp[17:0]),.ay1(inp[36:18]),.bx1(inp[54:37]),.by1(inp[73:55]),.ax2(inp[91:74]),.ay2(inp[110:92]),.bx2(inp[128:111]),.by2(inp[147:129]),.ax3(inp[165:148]),.ay3(inp[184:166]),.bx3(inp[202:185]),.by3(inp[221:203]),.result(outp[36:0]));

endmodule

module dsp_chain_4_int_sop_2_module (input clk, input reset, input [295:0] inp, output [36:0] outp);

dsp_chain_4_int_sop_2 inst(.clk(clk),.reset(reset),.ax1(inp[17:0]),.ay1(inp[36:18]),.bx1(inp[54:37]),.by1(inp[73:55]),.ax2(inp[91:74]),.ay2(inp[110:92]),.bx2(inp[128:111]),.by2(inp[147:129]),.ax3(inp[165:148]),.ay3(inp[184:166]),.bx3(inp[202:185]),.by3(inp[221:203]),.ax4(inp[239:222]),.ay4(inp[258:240]),.bx4(inp[276:259]),.by4(inp[295:277]),.result(outp[36:0]));

endmodule

module dsp_chain_2_fp16_sop2_mult_module (input clk, input reset, input [127:0] inp, output [31:0] outp);

dsp_chain_2_fp16_sop2_mult inst(.clk(clk),.reset(reset),.top_a1(inp[15:0]),.top_b1(inp[31:16]),.bot_a1(inp[47:32]),.bot_b1(inp[63:48]),.top_a2(inp[79:64]),.top_b2(inp[95:80]),.bot_a2(inp[111:96]),.bot_b2(inp[127:112]),.result(outp));

endmodule

module dsp_chain_3_fp16_sop2_mult_module (input clk, input reset, input [191:0] inp, output [31:0] outp);

dsp_chain_3_fp16_sop2_mult inst(.clk(clk),.reset(reset),.top_a1(inp[15:0]),.top_b1(inp[31:16]),.bot_a1(inp[47:32]),.bot_b1(inp[63:48]),.top_a2(inp[79:64]),.top_b2(inp[95:80]),.bot_a2(inp[111:96]),.bot_b2(inp[127:112]),.top_a3(inp[143:128]),.top_b3(inp[159:144]),.bot_a3(inp[175:160]),.bot_b3(inp[191:176]),.result(outp));

endmodule

module dsp_chain_4_fp16_sop2_mult_module (input clk, input reset, input [255:0] inp, output [31:0] outp);

dsp_chain_4_fp16_sop2_mult inst(.clk(clk),.reset(reset),.top_a1(inp[15:0]),.top_b1(inp[31:16]),.bot_a1(inp[47:32]),.bot_b1(inp[63:48]),.top_a2(inp[79:64]),.top_b2(inp[95:80]),.bot_a2(inp[111:96]),.bot_b2(inp[127:112]),.top_a3(inp[143:128]),.top_b3(inp[159:144]),.bot_a3(inp[175:160]),.bot_b3(inp[191:176]),.top_a4(inp[207:192]),.top_b4(inp[223:208]),.bot_a4(inp[239:224]),.bot_b4(inp[255:240]),.result(outp));

endmodule

module tensor_block_bf16_module (input clk, input reset, input [264:0] inp, output [271:0] outp);

tensor_block_bf16 inst(
	.clk(clk),
	.reset(reset),

	.data_in(inp[79:0]),
	.cascade_in(inp[159:80]),
	.acc0_in(inp[191:160]),
	.acc1_in(inp[223:192]),
	.acc2_in(inp[255:224]),
	.accumulator_input1_select(inp[258:256]),

	.out0(outp[31:0]),
	.out1(outp[63:32]),
	.out2(outp[95:64]),
	.cascade_out(outp[175:96]),
	.acc0_out(outp[207:176]),
	.acc1_out(outp[239:208]),
	.acc2_out(outp[271:240]),

	.mux1_select(inp[259]),
	.dot_unit_input_1_enable(inp[260]),
	.bank0_data_in_enable(inp[261]),
	.bank1_data_in_enable(inp[262]),
	.cascade_out_select(inp[263]),
	.dot_unit_input_2_select(inp[264])

	);

endmodule

module tensor_block_int8_module (input clk, input reset, input [264:0] inp, output [250:0] outp);

tensor_block inst(
	.clk(clk),
	.reset(reset),

	.data_in(inp[79:0]),
	.cascade_in(inp[159:80]),
	.acc0_in(inp[191:160]),
	.acc1_in(inp[223:192]),
	.acc2_in(inp[255:224]),
	.accumulator_input1_select(inp[258:256]),

	.out0(outp[24:0]),
	.out1(outp[49:25]),
	.out2(outp[74:50]),
	.cascade_out(outp[154:75]),
	.acc0_out(outp[186:155]),
	.acc1_out(outp[218:187]),
	.acc2_out(outp[250:219]),

	.mux1_select(inp[259]),
	.dot_unit_input_1_enable(inp[260]),
	.bank0_data_in_enable(inp[261]),
	.bank1_data_in_enable(inp[262]),
	.cascade_out_select(inp[263]),
	.dot_unit_input_2_select(inp[264])

	);

endmodule


module activation_32_8bit_module (input clk, input reset, input [260:0] inp, output [257:0] outp);

activation_32_8bit inst (
    .activation_type(inp[0]),
    .enable_activation(inp[1]),
    .in_data_available(inp[2]),
    .inp_data(inp[258:3]),
    .out_data(outp[255:0]),
    .out_data_available(outp[256]),
    .validity_mask(inp[260:259]),
    .done_activation(outp[257]),
    .clk(clk),
    .reset(reset)
);

endmodule

module activation_32_16bit_module (input clk, input reset, input [515:0] inp, output [513:0] outp);

activation_32_16bit inst (
    .activation_type(inp[0]),
    .enable_activation(inp[1]),
    .in_data_available(inp[2]),
    .inp_data(inp[514:3]),
    .out_data(outp[511:0]),
    .out_data_available(outp[512]),
    .validity_mask(inp[515:514]),
    .done_activation(outp[513]),
    .clk(clk),
    .reset(reset)
);

endmodule

