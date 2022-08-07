module tensor_block(
	clk,
	reset,
	
	data_in,
	cascade_in,
	acc0_in,
	acc1_in,
	acc2_in,
	accumulator_input1_select,

	out0,
	out1,
	out2,
	cascade_out,
	acc0_out,
	acc1_out,
	acc2_out,

	mux1_select,
	dot_unit_input_1_enable,
	bank0_data_in_enable,
	bank1_data_in_enable,
	cascade_out_select,
	dot_unit_input_2_select

	);

input 	[79:0] data_in;
input	[79:0] cascade_in;
input	[31:0] acc0_in;
input	[31:0] acc1_in;
input	[31:0] acc2_in;
input 	[2:0] accumulator_input1_select;


output	[24:0] out0;
output	[24:0] out1;
output	[24:0] out2;
output	[79:0] cascade_out;
output	[31:0] acc0_out;
output	[31:0] acc1_out;
output	[31:0] acc2_out;

//Inputs to take into account
input clk;
input reset;

// Logic to be created for 
input mux1_select;
input dot_unit_input_1_enable;
input bank0_data_in_enable;
input bank1_data_in_enable;
input cascade_out_select;
input dot_unit_input_2_select;


wire [79:0]mux1_out;
assign mux1_out = mux1_select ? cascade_in : data_in;

reg [79:0]dot_unit_input_1;

// D Flip Flop with reset and enable
always @ (posedge clk) begin
	if (reset == 1'b1) dot_unit_input_1 <= 0;
	else if (dot_unit_input_1_enable) dot_unit_input_1 <= data_in;
end

// Register Bank 0 
reg[79:0] bank0_reg0;
reg[79:0] bank0_reg1;
reg[79:0] bank0_reg2;

always @ (posedge clk) begin
	if (reset == 1'b1) begin
		bank0_reg0 <= 0;
		bank0_reg1 <= 0;
		bank0_reg2 <= 0;
	end
	else if (bank0_data_in_enable) begin
		bank0_reg0 <= mux1_out;
		bank0_reg1 <= bank0_reg0;
		bank0_reg2 <= bank0_reg1;
	end
end

// Register Bank 1 
reg[79:0] bank1_reg0;
reg[79:0] bank1_reg1;
reg[79:0] bank1_reg2;

always @ (posedge clk) begin
	if (reset == 1'b1) begin
		bank1_reg0 <= 0;
		bank1_reg1 <= 0;
		bank1_reg2 <= 0;
	end
	else if (bank1_data_in_enable) begin
		bank1_reg0 <= mux1_out;
		bank1_reg1 <= bank0_reg0;
		bank1_reg2 <= bank0_reg1;
	end
end

// Output cascade out
assign cascade_out = cascade_out_select ? bank1_reg2 : bank0_reg2;

// Providing second input to all 3 dot product units
wire [79:0]dot_unit_input_2_0;
wire [79:0]dot_unit_input_2_1;
wire [79:0]dot_unit_input_2_2;

assign dot_unit_input_2_0 = dot_unit_input_2_select ? bank1_reg0 : bank0_reg0;
assign dot_unit_input_2_1 = dot_unit_input_2_select ? bank1_reg1 : bank0_reg1;
assign dot_unit_input_2_2 = dot_unit_input_2_select ? bank1_reg2 : bank0_reg2;

wire [19:0] dot_unit_output_0;
wire [19:0] dot_unit_output_1;
wire [19:0] dot_unit_output_2;

dot_product_unit dot_unit0 (dot_unit_input_1, dot_unit_input_2_0, dot_unit_output_0,clk);
dot_product_unit dot_unit1 (dot_unit_input_1, dot_unit_input_2_1, dot_unit_output_1,clk);
dot_product_unit dot_unit2 (dot_unit_input_1, dot_unit_input_2_2, dot_unit_output_2,clk);

// Flopping after dot product compute
reg [19:0] dot_unit_output_0_flopped;
reg [19:0] dot_unit_output_1_flopped;
reg [19:0] dot_unit_output_2_flopped;

always @ (posedge clk) begin
	if (reset == 1'b1) begin
		dot_unit_output_0_flopped <= 0;
		dot_unit_output_1_flopped <= 0;
		dot_unit_output_2_flopped <= 0;
	end
	else begin
		dot_unit_output_0_flopped <= dot_unit_output_0;
		dot_unit_output_1_flopped <= dot_unit_output_1;
		dot_unit_output_2_flopped <= dot_unit_output_2;
	end
end

wire [31:0] accumulator_unit0_input1;
wire [31:0] accumulator_unit1_input1;
wire [31:0] accumulator_unit2_input1;

wire [31:0] accumulator_unit_output_0;
wire [31:0] accumulator_unit_output_1;
wire [31:0] accumulator_unit_output_2;

reg [31:0] accumulator_unit_output_0_flopped;
reg [31:0] accumulator_unit_output_1_flopped;
reg [31:0] accumulator_unit_output_2_flopped;

reg [31:0] acc0_in_flopped;
reg [31:0] acc1_in_flopped;
reg [31:0] acc2_in_flopped;

// 3 mux's for selecting acc_in or acc_out_flopped
assign accumulator_unit0_input1 = accumulator_input1_select[0] ?  accumulator_unit_output_0_flopped : acc0_in_flopped;
assign accumulator_unit1_input1 = accumulator_input1_select[1] ?  accumulator_unit_output_1_flopped : acc1_in_flopped;
assign accumulator_unit2_input1 = accumulator_input1_select[2] ?  accumulator_unit_output_2_flopped : acc2_in_flopped;

// Flopping the accumulator outputs and acc_in 
always @ (posedge clk) begin
	if (reset == 1'b1) begin
		accumulator_unit_output_0_flopped <= 0;
		accumulator_unit_output_1_flopped <= 0;
		accumulator_unit_output_2_flopped <= 0;
		acc0_in_flopped <= 0;
		acc1_in_flopped <= 0;
		acc2_in_flopped <= 0;
	end
	else begin
		accumulator_unit_output_0_flopped <= accumulator_unit_output_0;
		accumulator_unit_output_1_flopped <= accumulator_unit_output_1;
		accumulator_unit_output_2_flopped <= accumulator_unit_output_2;
		acc0_in_flopped <= acc0_in;
		acc1_in_flopped <= acc1_in;
		acc2_in_flopped <= acc2_in;
	end
end

// Accumulator units
accumulator acc_unit0 (dot_unit_output_0_flopped, accumulator_unit0_input1, accumulator_unit_output_0 );
accumulator acc_unit1 (dot_unit_output_1_flopped, accumulator_unit1_input1, accumulator_unit_output_1 );
accumulator acc_unit2 (dot_unit_output_2_flopped, accumulator_unit2_input1, accumulator_unit_output_2 );

assign acc0_out = accumulator_unit_output_0;
assign acc1_out = accumulator_unit_output_1;
assign acc2_out = accumulator_unit_output_2;

//Taking the top 25 bits from the 32 bit accumulation number
assign out0= accumulator_unit_output_0[31:7];
assign out1= accumulator_unit_output_1[31:7];
assign out2= accumulator_unit_output_2[31:7];

endmodule

module dot_product_unit (
	data_in_1,
	data_in_2,
	data_out,
  clk
	);

input clk;
input [79:0] data_in_1;
input [79:0] data_in_2;
output reg [19:0] data_out;

wire [7:0] mult1_in1;
wire [7:0] mult1_in2;
reg [15:0] mult1_out;
wire [7:0] mult2_in1;
wire [7:0] mult2_in2;
reg [15:0] mult2_out;
wire [7:0] mult3_in1;
wire [7:0] mult3_in2;
reg [15:0] mult3_out;
wire [7:0] mult4_in1;
wire [7:0] mult4_in2;
reg [15:0] mult4_out;
wire [7:0] mult5_in1;
wire [7:0] mult5_in2;
reg [15:0] mult5_out;
wire [7:0] mult6_in1;
wire [7:0] mult6_in2;
reg [15:0] mult6_out;
wire [7:0] mult7_in1;
wire [7:0] mult7_in2;
reg [15:0] mult7_out;
wire [7:0] mult8_in1;
wire [7:0] mult8_in2;
reg [15:0] mult8_out;
wire [7:0] mult9_in1;
wire [7:0] mult9_in2;
reg [15:0] mult9_out;
wire [7:0] mult10_in1;
wire [7:0] mult10_in2;
reg [15:0] mult10_out;

assign mult1_in1 = data_in_1[7:0];
assign mult1_in2 = data_in_2[7:0];

assign mult2_in1 = data_in_1[15:8];
assign mult2_in2 = data_in_2[15:8];


assign mult3_in1 = data_in_1[23:16];
assign mult3_in2 = data_in_2[23:16];

assign mult4_in1 = data_in_1[31:24];
assign mult4_in2 = data_in_2[31:24];

assign mult5_in1 = data_in_1[39:32];
assign mult5_in2 = data_in_2[39:32];

assign mult6_in1 = data_in_1[47:40];
assign mult6_in2 = data_in_2[47:40];

assign mult7_in1 = data_in_1[55:48];
assign mult7_in2 = data_in_2[55:48];

assign mult8_in1 = data_in_1[63:56];
assign mult8_in2 = data_in_2[63:56];

assign mult9_in1 = data_in_1[71:64];
assign mult9_in2 = data_in_2[71:64];


assign mult10_in1 = data_in_1[79:72];
assign mult10_in2 = data_in_2[79:72];

always@(posedge clk) begin 
mult1_out <= mult1_in1 * mult1_in2;
mult2_out <= mult2_in1 * mult2_in2;
mult3_out <= mult3_in1 * mult3_in2;
mult4_out <= mult4_in1 * mult4_in2;
mult5_out <= mult5_in1 * mult5_in2;
mult6_out <= mult6_in1 * mult6_in2;
mult7_out <= mult7_in1 * mult7_in2;
mult8_out <= mult8_in1 * mult8_in2;
mult9_out <= mult9_in1 * mult9_in2;
mult10_out <= mult10_in1 * mult10_in2;
end



reg [16:0] s01,s02,s03,s04,s05;

always@(posedge clk) begin 
  s01<= mult1_out + mult2_out;
  s02<= mult3_out + mult4_out;
  s03<= mult5_out + mult6_out;
  s04<= mult7_out + mult8_out;
  s05<= mult9_out + mult10_out;
end

reg [17:0] s11,s12;

always@(posedge clk) begin 
s11<= s01 + s02;
s12<= s03 + s04; 
end

reg [18:0] s21;

always@(posedge clk) begin 
s21<= s11 + s12;
data_out <= s21 + s05; 
end



endmodule


module accumulator (
	input_accumlator_1,
	input_accumlator_2,
	output_accumlator
	);

input [19:0] input_accumlator_1;
input [31:0] input_accumlator_2;
output [31:0] output_accumlator;

assign output_accumlator = input_accumlator_1 + input_accumlator_2;

endmodule

