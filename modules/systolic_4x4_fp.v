
`timescale 1ns / 1ps
//`define complex_dsp
`define DWIDTH 16
`define AWIDTH 10
`define MEM_SIZE 1024

`define MAT_MUL_SIZE 4
`define MASK_WIDTH 4
`define LOG2_MAT_MUL_SIZE 2

`define NUM_CYCLES_IN_MAC 3
`define MEM_ACCESS_LATENCY 1
`define REG_DATAWIDTH 32
`define REG_ADDRWIDTH 8
`define ADDR_STRIDE_WIDTH 10
`define MAX_BITS_POOL 3
`define EXPONENT 5
`define MANTISSA 10
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2020 11:43:24 PM
// Design Name: 
// Module Name: matmul_4x4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module matmul_4x4_fp_systolic(
 clk,
 reset,
 pe_reset,
 start_mat_mul,
 done_mat_mul,
 address_mat_a,
 address_mat_b,
 address_mat_c,
 address_stride_a,
 address_stride_b,
 address_stride_c,
 a_data,
 b_data,
 a_data_in, //Data values coming in from previous matmul - systolic connections
 b_data_in,
 c_data_in, //Data values coming in from previous matmul - systolic shifting
 c_data_out, //Data values going out to next matmul - systolic shifting
 a_data_out,
 b_data_out,
 a_addr,
 b_addr,
 c_addr,
 c_data_available,
 validity_mask_a_rows,
 validity_mask_a_cols_b_rows,
 validity_mask_b_cols,
 final_mat_mul_size,
 a_loc,
 b_loc
);

 input clk;
 input reset;
 input pe_reset;
 input start_mat_mul;
 output done_mat_mul;
 input [`AWIDTH-1:0] address_mat_a;
 input [`AWIDTH-1:0] address_mat_b;
 input [`AWIDTH-1:0] address_mat_c;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
 input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_in;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_in;
 input [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
 output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;
 output [`AWIDTH-1:0] a_addr;
 output [`AWIDTH-1:0] b_addr;
 output [`AWIDTH-1:0] c_addr;
 output c_data_available;
 input [`MASK_WIDTH-1:0] validity_mask_a_rows;
 input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
 input [`MASK_WIDTH-1:0] validity_mask_b_cols;
//7:0 is okay here. We aren't going to make a matmul larger than 128x128
//In fact, these will get optimized out by the synthesis tool, because
//we hardcode them at the instantiation level.
 input [7:0] final_mat_mul_size;
 input [7:0] a_loc;
 input [7:0] b_loc;

//////////////////////////////////////////////////////////////////////////
// Logic for clock counting and when to assert done
//////////////////////////////////////////////////////////////////////////

reg done_mat_mul;
//This is 7 bits because the expectation is that clock count will be pretty
//small. For large matmuls, this will need to increased to have more bits.
//In general, a systolic multiplier takes 4*N-2+P cycles, where N is the size 
//of the matmul and P is the number of pipleine stages in the MAC block.
reg [7:0] clk_cnt;

//Finding out number of cycles to assert matmul done.
//When we have to save the outputs to accumulators, then we don't need to
//shift out data. So, we can assert done_mat_mul early.
//In the normal case, we have to include the time to shift out the results. 
//Note: the count expression used to contain "4*final_mat_mul_size", but 
//to avoid multiplication, we now use "final_mat_mul_size<<2"
wire [7:0] clk_cnt_for_done;
assign clk_cnt_for_done = 
                          ((final_mat_mul_size<<2) - 2 + `NUM_CYCLES_IN_MAC) ;  

always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    clk_cnt <= 0;
    done_mat_mul <= 0;
  end
  else if (clk_cnt == clk_cnt_for_done) begin
    done_mat_mul <= 1;
    clk_cnt <= clk_cnt + 1;
  end
  else if (done_mat_mul == 0) begin
    clk_cnt <= clk_cnt + 1;
  end    
  else begin
    done_mat_mul <= 0;
    clk_cnt <= clk_cnt + 1;
  end
end


wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;
wire [`DWIDTH-1:0] a1_data_delayed_1;
wire [`DWIDTH-1:0] a2_data_delayed_1;
wire [`DWIDTH-1:0] a2_data_delayed_2;
wire [`DWIDTH-1:0] a3_data_delayed_1;
wire [`DWIDTH-1:0] a3_data_delayed_2;
wire [`DWIDTH-1:0] a3_data_delayed_3;
wire [`DWIDTH-1:0] b1_data_delayed_1;
wire [`DWIDTH-1:0] b2_data_delayed_1;
wire [`DWIDTH-1:0] b2_data_delayed_2;
wire [`DWIDTH-1:0] b3_data_delayed_1;
wire [`DWIDTH-1:0] b3_data_delayed_2;
wire [`DWIDTH-1:0] b3_data_delayed_3;

//////////////////////////////////////////////////////////////////////////
// Instantiation of systolic data setup
//////////////////////////////////////////////////////////////////////////
systolic_data_setup_systolic_4x4_fp u_systolic_data_setup_systolic_4x4_fp(
.clk(clk),
.reset(reset),
.start_mat_mul(start_mat_mul),
.a_addr(a_addr),
.b_addr(b_addr),
.address_mat_a(address_mat_a),
.address_mat_b(address_mat_b),
.address_stride_a(address_stride_a),
.address_stride_b(address_stride_b),
.a_data(a_data),
.b_data(b_data),
.clk_cnt(clk_cnt),
.a0_data(a0_data),
.a1_data_delayed_1(a1_data_delayed_1),
.a2_data_delayed_2(a2_data_delayed_2),
.a3_data_delayed_3(a3_data_delayed_3),
.b0_data(b0_data),
.b1_data_delayed_1(b1_data_delayed_1),
.b2_data_delayed_2(b2_data_delayed_2),
.b3_data_delayed_3(b3_data_delayed_3),
.validity_mask_a_rows(validity_mask_a_rows),
.validity_mask_a_cols_b_rows(validity_mask_a_cols_b_rows),
.validity_mask_b_cols(validity_mask_b_cols),
.final_mat_mul_size(final_mat_mul_size),
.a_loc(a_loc),
.b_loc(b_loc)
);


//////////////////////////////////////////////////////////////////////////
// Logic to mux data_in coming from neighboring matmuls
//////////////////////////////////////////////////////////////////////////
wire [`DWIDTH-1:0] a0;
wire [`DWIDTH-1:0] a1;
wire [`DWIDTH-1:0] a2;
wire [`DWIDTH-1:0] a3;
wire [`DWIDTH-1:0] b0;
wire [`DWIDTH-1:0] b1;
wire [`DWIDTH-1:0] b2;
wire [`DWIDTH-1:0] b3;

wire [`DWIDTH-1:0] a0_data_in;
wire [`DWIDTH-1:0] a1_data_in;
wire [`DWIDTH-1:0] a2_data_in;
wire [`DWIDTH-1:0] a3_data_in;
assign a0_data_in = a_data_in[`DWIDTH-1:0];
assign a1_data_in = a_data_in[2*`DWIDTH-1:`DWIDTH];
assign a2_data_in = a_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign a3_data_in = a_data_in[4*`DWIDTH-1:3*`DWIDTH];

wire [`DWIDTH-1:0] b0_data_in;
wire [`DWIDTH-1:0] b1_data_in;
wire [`DWIDTH-1:0] b2_data_in;
wire [`DWIDTH-1:0] b3_data_in;
assign b0_data_in = b_data_in[`DWIDTH-1:0];
assign b1_data_in = b_data_in[2*`DWIDTH-1:`DWIDTH];
assign b2_data_in = b_data_in[3*`DWIDTH-1:2*`DWIDTH];
assign b3_data_in = b_data_in[4*`DWIDTH-1:3*`DWIDTH];

//If b_loc is 0, that means this matmul block is on the top-row of the
//final large matmul. In that case, b will take inputs from mem.
//If b_loc != 0, that means this matmul block is not on the top-row of the
//final large matmul. In that case, b will take inputs from the matmul on top
//of this one.
assign a0 = (b_loc==0) ? a0_data           : a0_data_in;
assign a1 = (b_loc==0) ? a1_data_delayed_1 : a1_data_in;
assign a2 = (b_loc==0) ? a2_data_delayed_2 : a2_data_in;
assign a3 = (b_loc==0) ? a3_data_delayed_3 : a3_data_in;

//If a_loc is 0, that means this matmul block is on the left-col of the
//final large matmul. In that case, a will take inputs from mem.
//If a_loc != 0, that means this matmul block is not on the left-col of the
//final large matmul. In that case, a will take inputs from the matmul on left
//of this one.
assign b0 = (a_loc==0) ? b0_data           : b0_data_in;
assign b1 = (a_loc==0) ? b1_data_delayed_1 : b1_data_in;
assign b2 = (a_loc==0) ? b2_data_delayed_2 : b2_data_in;
assign b3 = (a_loc==0) ? b3_data_delayed_3 : b3_data_in;


wire [`DWIDTH-1:0] matrixC00;
wire [`DWIDTH-1:0] matrixC01;
wire [`DWIDTH-1:0] matrixC02;
wire [`DWIDTH-1:0] matrixC03;
wire [`DWIDTH-1:0] matrixC10;
wire [`DWIDTH-1:0] matrixC11;
wire [`DWIDTH-1:0] matrixC12;
wire [`DWIDTH-1:0] matrixC13;
wire [`DWIDTH-1:0] matrixC20;
wire [`DWIDTH-1:0] matrixC21;
wire [`DWIDTH-1:0] matrixC22;
wire [`DWIDTH-1:0] matrixC23;
wire [`DWIDTH-1:0] matrixC30;
wire [`DWIDTH-1:0] matrixC31;
wire [`DWIDTH-1:0] matrixC32;
wire [`DWIDTH-1:0] matrixC33;


//////////////////////////////////////////////////////////////////////////
// Instantiation of the output logic
//////////////////////////////////////////////////////////////////////////
output_logic_systolic_4x4_fp u_output_logic_systolic_4x4_fp(
.clk(clk),
.reset(reset),
.start_mat_mul(start_mat_mul),
.done_mat_mul(done_mat_mul),
.address_mat_c(address_mat_c),
.address_stride_c(address_stride_c),
.c_data_out(c_data_out),
.c_data_in(c_data_in),
.c_addr(c_addr),
.c_data_available(c_data_available),
.clk_cnt(clk_cnt),
.final_mat_mul_size(final_mat_mul_size),
.matrixC00(matrixC00),
.matrixC01(matrixC01),
.matrixC02(matrixC02),
.matrixC03(matrixC03),
.matrixC10(matrixC10),
.matrixC11(matrixC11),
.matrixC12(matrixC12),
.matrixC13(matrixC13),
.matrixC20(matrixC20),
.matrixC21(matrixC21),
.matrixC22(matrixC22),
.matrixC23(matrixC23),
.matrixC30(matrixC30),
.matrixC31(matrixC31),
.matrixC32(matrixC32),
.matrixC33(matrixC33)
);

//////////////////////////////////////////////////////////////////////////
// Instantiations of the actual PEs
//////////////////////////////////////////////////////////////////////////
systolic_pe_matrix_systolic_4x4_fp u_systolic_pe_matrix_systolic_4x4_fp(
.reset(reset),
.clk(clk),
.pe_reset(pe_reset),
.start_mat_mul(start_mat_mul),
.a0(a0), 
.a1(a1), 
.a2(a2), 
.a3(a3),
.b0(b0), 
.b1(b1), 
.b2(b2), 
.b3(b3),
.matrixC00(matrixC00),
.matrixC01(matrixC01),
.matrixC02(matrixC02),
.matrixC03(matrixC03),
.matrixC10(matrixC10),
.matrixC11(matrixC11),
.matrixC12(matrixC12),
.matrixC13(matrixC13),
.matrixC20(matrixC20),
.matrixC21(matrixC21),
.matrixC22(matrixC22),
.matrixC23(matrixC23),
.matrixC30(matrixC30),
.matrixC31(matrixC31),
.matrixC32(matrixC32),
.matrixC33(matrixC33),
.a_data_out(a_data_out),
.b_data_out(b_data_out)
);

endmodule

//////////////////////////////////////////////////////////////////////////
// Output logic
//////////////////////////////////////////////////////////////////////////
module output_logic_systolic_4x4_fp(
clk,
reset,
start_mat_mul,
done_mat_mul,
address_mat_c,
address_stride_c,
c_data_in,
c_data_out, //Data values going out to next matmul - systolic shifting
c_addr,
c_data_available,
clk_cnt,
final_mat_mul_size,
matrixC00,
matrixC01,
matrixC02,
matrixC03,
matrixC10,
matrixC11,
matrixC12,
matrixC13,
matrixC20,
matrixC21,
matrixC22,
matrixC23,
matrixC30,
matrixC31,
matrixC32,
matrixC33
);

input clk;
input reset;
input start_mat_mul;
input done_mat_mul;
input [`AWIDTH-1:0] address_mat_c;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_c;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_in;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
output [`AWIDTH-1:0] c_addr;
output c_data_available;
input [7:0] clk_cnt;
//output row_latch_en;
input [7:0] final_mat_mul_size;
input [`DWIDTH-1:0] matrixC00;
input [`DWIDTH-1:0] matrixC01;
input [`DWIDTH-1:0] matrixC02;
input [`DWIDTH-1:0] matrixC03;
input [`DWIDTH-1:0] matrixC10;
input [`DWIDTH-1:0] matrixC11;
input [`DWIDTH-1:0] matrixC12;
input [`DWIDTH-1:0] matrixC13;
input [`DWIDTH-1:0] matrixC20;
input [`DWIDTH-1:0] matrixC21;
input [`DWIDTH-1:0] matrixC22;
input [`DWIDTH-1:0] matrixC23;
input [`DWIDTH-1:0] matrixC30;
input [`DWIDTH-1:0] matrixC31;
input [`DWIDTH-1:0] matrixC32;
input [`DWIDTH-1:0] matrixC33;

wire row_latch_en;

//////////////////////////////////////////////////////////////////////////
// Logic to capture matrix C data from the PEs and shift it out
//////////////////////////////////////////////////////////////////////////

//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + (a_loc+b_loc) * `BB_MAT_MUL_SIZE + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Writing the line above to avoid multiplication:
//assign row_latch_en = (clk_cnt==(`MAT_MUL_SIZE + ((a_loc+b_loc) << `LOG2_MAT_MUL_SIZE) + 10 +  `NUM_CYCLES_IN_MAC - 1));
//Fixing bug. The line above is inaccurate. Using the line below. 
//TODO: This line needs to be fixed to include a_loc and b_loc ie. when final_mat_mul_size is different from `MAT_MUL_SIZE
assign row_latch_en =  
                       //((clk_cnt == ((`MAT_MUL_SIZE<<2) - `MAT_MUL_SIZE -2 +`NUM_CYCLES_IN_MAC)));
                       ((clk_cnt == ((final_mat_mul_size<<2) - final_mat_mul_size -1 +`NUM_CYCLES_IN_MAC)));

reg c_data_available;
reg [`AWIDTH-1:0] c_addr;
reg start_capturing_c_data;
integer counter;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out_1;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out_2;
reg [`MAT_MUL_SIZE*`DWIDTH-1:0] c_data_out_3;

wire [`MAT_MUL_SIZE*`DWIDTH-1:0] col0;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] col1;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] col2;
wire [`MAT_MUL_SIZE*`DWIDTH-1:0] col3;
assign col0 = {matrixC30, matrixC20, matrixC10, matrixC00};
assign col1 = {matrixC31, matrixC21, matrixC11, matrixC01};
assign col2 = {matrixC32, matrixC22, matrixC12, matrixC02};
assign col3 = {matrixC33, matrixC23, matrixC13, matrixC03};

//If save_output_to_accum is asserted, that means we are not intending to shift
//out the outputs, because the outputs are still partial sums. 
wire condition_to_start_shifting_output;
assign condition_to_start_shifting_output = 
                          row_latch_en ;  

//For larger matmuls, this logic will have more entries in the case statement
always @(posedge clk) begin
  if (reset | ~start_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= address_mat_c+address_stride_c;
    c_data_out <= 0;
    counter <= 0;
    c_data_out_1 <= 0; 
    c_data_out_2 <= 0; 
    c_data_out_3 <= 0; 
  end
  else if (condition_to_start_shifting_output) begin
    start_capturing_c_data <= 1'b1;
    c_data_available <= 1'b1;
    c_addr <= c_addr - address_stride_c;
    c_data_out <= col0; 
    c_data_out_1 <= col1; 
    c_data_out_2 <= col2; 
    c_data_out_3 <= col3; 
    counter <= counter + 1;
  end 
  else if (done_mat_mul) begin
    start_capturing_c_data <= 1'b0;
    c_data_available <= 1'b0;
    c_addr <= address_mat_c+address_stride_c;
    c_data_out <= 0;
    c_data_out_1 <= 0;
    c_data_out_2 <= 0;
    c_data_out_3 <= 0;
  end 
  else if (counter >= `MAT_MUL_SIZE) begin
    c_addr <= c_addr - address_stride_c;
    c_data_out <= c_data_out_1;
    c_data_out_1 <= c_data_out_2;
    c_data_out_2 <= c_data_out_3;
    c_data_out_3 <= c_data_in;
  end
  else if (start_capturing_c_data) begin
    c_data_available <= 1'b1;
    c_addr <= c_addr - address_stride_c;
    counter <= counter + 1;
    c_data_out <= c_data_out_1;
    c_data_out_1 <= c_data_out_2;
    c_data_out_2 <= c_data_out_3;
    c_data_out_3 <= c_data_in;
  end
end

endmodule

//////////////////////////////////////////////////////////////////////////
// Systolic data setup
//////////////////////////////////////////////////////////////////////////
module systolic_data_setup_systolic_4x4_fp(
clk,
reset,
start_mat_mul,
a_addr,
b_addr,
address_mat_a,
address_mat_b,
address_stride_a,
address_stride_b,
a_data,
b_data,
clk_cnt,
a0_data,
a1_data_delayed_1,
a2_data_delayed_2,
a3_data_delayed_3,
b0_data,
b1_data_delayed_1,
b2_data_delayed_2,
b3_data_delayed_3,
validity_mask_a_rows,
validity_mask_a_cols_b_rows,
validity_mask_b_cols,
final_mat_mul_size,
a_loc,
b_loc
);

input clk;
input reset;
input start_mat_mul;
output [`AWIDTH-1:0] a_addr;
output [`AWIDTH-1:0] b_addr;
input [`AWIDTH-1:0] address_mat_a;
input [`AWIDTH-1:0] address_mat_b;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_a;
input [`ADDR_STRIDE_WIDTH-1:0] address_stride_b;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data;
input [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data;
input [7:0] clk_cnt;
output [`DWIDTH-1:0] a0_data;
output [`DWIDTH-1:0] a1_data_delayed_1;
output [`DWIDTH-1:0] a2_data_delayed_2;
output [`DWIDTH-1:0] a3_data_delayed_3;
output [`DWIDTH-1:0] b0_data;
output [`DWIDTH-1:0] b1_data_delayed_1;
output [`DWIDTH-1:0] b2_data_delayed_2;
output [`DWIDTH-1:0] b3_data_delayed_3;
input [`MASK_WIDTH-1:0] validity_mask_a_rows;
input [`MASK_WIDTH-1:0] validity_mask_a_cols_b_rows;
input [`MASK_WIDTH-1:0] validity_mask_b_cols;
input [7:0] final_mat_mul_size;
input [7:0] a_loc;
input [7:0] b_loc;

wire [`DWIDTH-1:0] a0_data;
wire [`DWIDTH-1:0] a1_data;
wire [`DWIDTH-1:0] a2_data;
wire [`DWIDTH-1:0] a3_data;
wire [`DWIDTH-1:0] b0_data;
wire [`DWIDTH-1:0] b1_data;
wire [`DWIDTH-1:0] b2_data;
wire [`DWIDTH-1:0] b3_data;

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM A
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] a_addr;
reg a_mem_access; //flag that tells whether the matmul is trying to access memory or not

always @(posedge clk) begin
  //else if (clk_cnt >= a_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  if ((reset || ~start_mat_mul) || (clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
      a_addr <= address_mat_a-address_stride_a;
    a_mem_access <= 0;
  end

  //else if ((clk_cnt >= a_loc*`MAT_MUL_SIZE) && (clk_cnt < a_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (a_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (a_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
      a_addr <= a_addr + address_stride_a;
    a_mem_access <= 1;
  end
end  

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM A
//////////////////////////////////////////////////////////////////////////
reg [7:0] a_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    a_mem_access_counter <= 0;
  end
  else if (a_mem_access == 1) begin
    a_mem_access_counter <= a_mem_access_counter + 1;  

  end
  else begin
    a_mem_access_counter <= 0;
  end
end

wire a_data_valid; //flag that tells whether the data from memory is valid
assign a_data_valid = 
       ((validity_mask_a_cols_b_rows[0]==1'b0 && a_mem_access_counter==1) ||
        (validity_mask_a_cols_b_rows[1]==1'b0 && a_mem_access_counter==2) ||
        (validity_mask_a_cols_b_rows[2]==1'b0 && a_mem_access_counter==3) ||
        (validity_mask_a_cols_b_rows[3]==1'b0 && a_mem_access_counter==4)) ?
        1'b0 : (a_mem_access_counter >= `MEM_ACCESS_LATENCY);

//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM A (systolic data setup)
//////////////////////////////////////////////////////////////////////////
//Slice data into chunks and qualify it with whether it is valid or not
assign a0_data = a_data[`DWIDTH-1:0] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[0]}};
assign a1_data = a_data[2*`DWIDTH-1:`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[1]}};
assign a2_data = a_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[2]}};
assign a3_data = a_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{a_data_valid}} & {`DWIDTH{validity_mask_a_rows[3]}};

//For larger matmuls, more such delaying flops will be needed
reg [`DWIDTH-1:0] a1_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_1;
reg [`DWIDTH-1:0] a2_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_1;
reg [`DWIDTH-1:0] a3_data_delayed_2;
reg [`DWIDTH-1:0] a3_data_delayed_3;
always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
    a1_data_delayed_1 <= 0;
    a2_data_delayed_1 <= 0;
    a2_data_delayed_2 <= 0;
    a3_data_delayed_1 <= 0;
    a3_data_delayed_2 <= 0;
    a3_data_delayed_3 <= 0;
  end
  else begin
    a1_data_delayed_1 <= a1_data;
    a2_data_delayed_1 <= a2_data;
    a2_data_delayed_2 <= a2_data_delayed_1;
    a3_data_delayed_1 <= a3_data;
    a3_data_delayed_2 <= a3_data_delayed_1;
    a3_data_delayed_3 <= a3_data_delayed_2;
  end
end

//////////////////////////////////////////////////////////////////////////
// Logic to generate addresses to BRAM B
//////////////////////////////////////////////////////////////////////////
reg [`AWIDTH-1:0] b_addr;
reg b_mem_access; //flag that tells whether the matmul is trying to access memory or not

always @(posedge clk) begin
  //else if (clk_cnt >= b_loc*`MAT_MUL_SIZE+final_mat_mul_size) begin
  //Writing the line above to avoid multiplication:
  if ((reset || ~start_mat_mul) || (clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
      b_addr <= address_mat_b - address_stride_b;
    b_mem_access <= 0;
  end
  //else if ((clk_cnt >= b_loc*`MAT_MUL_SIZE) && (clk_cnt < b_loc*`MAT_MUL_SIZE+final_mat_mul_size)) begin
  //Writing the line above to avoid multiplication:
  else if ((clk_cnt >= (b_loc<<`LOG2_MAT_MUL_SIZE)) && (clk_cnt < (b_loc<<`LOG2_MAT_MUL_SIZE)+final_mat_mul_size)) begin
      b_addr <= b_addr + address_stride_b;
    b_mem_access <= 1;
  end
end  

//////////////////////////////////////////////////////////////////////////
// Logic to generate valid signals for data coming from BRAM B
//////////////////////////////////////////////////////////////////////////
reg [7:0] b_mem_access_counter;
always @(posedge clk) begin
  if (reset || ~start_mat_mul) begin
    b_mem_access_counter <= 0;
  end
  else if (b_mem_access == 1) begin
    b_mem_access_counter <= b_mem_access_counter + 1;  
  end
  else begin
    b_mem_access_counter <= 0;
  end
end

wire b_data_valid; //flag that tells whether the data from memory is valid
assign b_data_valid = 
       ((validity_mask_a_cols_b_rows[0]==1'b0 && b_mem_access_counter==1) ||
        (validity_mask_a_cols_b_rows[1]==1'b0 && b_mem_access_counter==2) ||
        (validity_mask_a_cols_b_rows[2]==1'b0 && b_mem_access_counter==3) ||
        (validity_mask_a_cols_b_rows[3]==1'b0 && b_mem_access_counter==4)) ?
        1'b0 : (b_mem_access_counter >= `MEM_ACCESS_LATENCY);


//////////////////////////////////////////////////////////////////////////
// Logic to delay certain parts of the data received from BRAM B (systolic data setup)
//////////////////////////////////////////////////////////////////////////
//Slice data into chunks and qualify it with whether it is valid or not
assign b0_data = b_data[`DWIDTH-1:0] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[0]}};
assign b1_data = b_data[2*`DWIDTH-1:`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[1]}};
assign b2_data = b_data[3*`DWIDTH-1:2*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[2]}};
assign b3_data = b_data[4*`DWIDTH-1:3*`DWIDTH] & {`DWIDTH{b_data_valid}} & {`DWIDTH{validity_mask_b_cols[3]}};

//For larger matmuls, more such delaying flops will be needed
reg [`DWIDTH-1:0] b1_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_1;
reg [`DWIDTH-1:0] b2_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_1;
reg [`DWIDTH-1:0] b3_data_delayed_2;
reg [`DWIDTH-1:0] b3_data_delayed_3;
always @(posedge clk) begin
  if (reset || ~start_mat_mul || clk_cnt==0) begin
    b1_data_delayed_1 <= 0;
    b2_data_delayed_1 <= 0;
    b2_data_delayed_2 <= 0;
    b3_data_delayed_1 <= 0;
    b3_data_delayed_2 <= 0;
    b3_data_delayed_3 <= 0;
  end
  else begin
    b1_data_delayed_1 <= b1_data;
    b2_data_delayed_1 <= b2_data;
    b2_data_delayed_2 <= b2_data_delayed_1;
    b3_data_delayed_1 <= b3_data;
    b3_data_delayed_2 <= b3_data_delayed_1;
    b3_data_delayed_3 <= b3_data_delayed_2;
  end
end


endmodule



//////////////////////////////////////////////////////////////////////////
// Systolically connected PEs
//////////////////////////////////////////////////////////////////////////
module systolic_pe_matrix_systolic_4x4_fp(
reset,
clk,
pe_reset,
start_mat_mul,
a0, a1, a2, a3,
b0, b1, b2, b3,
matrixC00,
matrixC01,
matrixC02,
matrixC03,
matrixC10,
matrixC11,
matrixC12,
matrixC13,
matrixC20,
matrixC21,
matrixC22,
matrixC23,
matrixC30,
matrixC31,
matrixC32,
matrixC33,
a_data_out,
b_data_out
);

input clk;
input reset;
input pe_reset;
input start_mat_mul;
input [`DWIDTH-1:0] a0;
input [`DWIDTH-1:0] a1;
input [`DWIDTH-1:0] a2;
input [`DWIDTH-1:0] a3;
input [`DWIDTH-1:0] b0;
input [`DWIDTH-1:0] b1;
input [`DWIDTH-1:0] b2;
input [`DWIDTH-1:0] b3;
output [`DWIDTH-1:0] matrixC00;
output [`DWIDTH-1:0] matrixC01;
output [`DWIDTH-1:0] matrixC02;
output [`DWIDTH-1:0] matrixC03;
output [`DWIDTH-1:0] matrixC10;
output [`DWIDTH-1:0] matrixC11;
output [`DWIDTH-1:0] matrixC12;
output [`DWIDTH-1:0] matrixC13;
output [`DWIDTH-1:0] matrixC20;
output [`DWIDTH-1:0] matrixC21;
output [`DWIDTH-1:0] matrixC22;
output [`DWIDTH-1:0] matrixC23;
output [`DWIDTH-1:0] matrixC30;
output [`DWIDTH-1:0] matrixC31;
output [`DWIDTH-1:0] matrixC32;
output [`DWIDTH-1:0] matrixC33;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] a_data_out;
output [`MAT_MUL_SIZE*`DWIDTH-1:0] b_data_out;

wire [`DWIDTH-1:0] a00to01, a01to02, a02to03, a03to04;
wire [`DWIDTH-1:0] a10to11, a11to12, a12to13, a13to14;
wire [`DWIDTH-1:0] a20to21, a21to22, a22to23, a23to24;
wire [`DWIDTH-1:0] a30to31, a31to32, a32to33, a33to34;

wire [`DWIDTH-1:0] b00to10, b10to20, b20to30, b30to40; 
wire [`DWIDTH-1:0] b01to11, b11to21, b21to31, b31to41;
wire [`DWIDTH-1:0] b02to12, b12to22, b22to32, b32to42;
wire [`DWIDTH-1:0] b03to13, b13to23, b23to33, b33to43;

wire effective_rst;
assign effective_rst = reset | pe_reset;

 processing_element_systolic_4x4_fp pe00(.reset(effective_rst), .clk(clk),  .in_a(a0),      .in_b(b0),  .out_a(a00to01), .out_b(b00to10), .out_c(matrixC00));
 processing_element_systolic_4x4_fp pe01(.reset(effective_rst), .clk(clk),  .in_a(a00to01), .in_b(b1),  .out_a(a01to02), .out_b(b01to11), .out_c(matrixC01));
 processing_element_systolic_4x4_fp pe02(.reset(effective_rst), .clk(clk),  .in_a(a01to02), .in_b(b2),  .out_a(a02to03), .out_b(b02to12), .out_c(matrixC02));
 processing_element_systolic_4x4_fp pe03(.reset(effective_rst), .clk(clk),  .in_a(a02to03), .in_b(b3),  .out_a(a03to04), .out_b(b03to13), .out_c(matrixC03));

 processing_element_systolic_4x4_fp pe10(.reset(effective_rst), .clk(clk),  .in_a(a1),      .in_b(b00to10), .out_a(a10to11), .out_b(b10to20), .out_c(matrixC10));
 processing_element_systolic_4x4_fp pe11(.reset(effective_rst), .clk(clk),  .in_a(a10to11), .in_b(b01to11), .out_a(a11to12), .out_b(b11to21), .out_c(matrixC11));
 processing_element_systolic_4x4_fp pe12(.reset(effective_rst), .clk(clk),  .in_a(a11to12), .in_b(b02to12), .out_a(a12to13), .out_b(b12to22), .out_c(matrixC12));
 processing_element_systolic_4x4_fp pe13(.reset(effective_rst), .clk(clk),  .in_a(a12to13), .in_b(b03to13), .out_a(a13to14), .out_b(b13to23), .out_c(matrixC13));

 processing_element_systolic_4x4_fp pe20(.reset(effective_rst), .clk(clk),  .in_a(a2),      .in_b(b10to20), .out_a(a20to21), .out_b(b20to30), .out_c(matrixC20));
 processing_element_systolic_4x4_fp pe21(.reset(effective_rst), .clk(clk),  .in_a(a20to21), .in_b(b11to21), .out_a(a21to22), .out_b(b21to31), .out_c(matrixC21));
 processing_element_systolic_4x4_fp pe22(.reset(effective_rst), .clk(clk),  .in_a(a21to22), .in_b(b12to22), .out_a(a22to23), .out_b(b22to32), .out_c(matrixC22));
 processing_element_systolic_4x4_fp pe23(.reset(effective_rst), .clk(clk),  .in_a(a22to23), .in_b(b13to23), .out_a(a23to24), .out_b(b23to33), .out_c(matrixC23));

 processing_element_systolic_4x4_fp pe30(.reset(effective_rst), .clk(clk),  .in_a(a3),      .in_b(b20to30), .out_a(a30to31), .out_b(b30to40), .out_c(matrixC30));
 processing_element_systolic_4x4_fp pe31(.reset(effective_rst), .clk(clk),  .in_a(a30to31), .in_b(b21to31), .out_a(a31to32), .out_b(b31to41), .out_c(matrixC31));
 processing_element_systolic_4x4_fp pe32(.reset(effective_rst), .clk(clk),  .in_a(a31to32), .in_b(b22to32), .out_a(a32to33), .out_b(b32to42), .out_c(matrixC32));
 processing_element_systolic_4x4_fp pe33(.reset(effective_rst), .clk(clk),  .in_a(a32to33), .in_b(b23to33), .out_a(a33to34), .out_b(b33to43), .out_c(matrixC33));

assign a_data_out = {a33to34,a23to24,a13to14,a03to04};
assign b_data_out = {b33to43,b32to42,b31to41,b30to40};

endmodule



//////////////////////////////////////////////////////////////////////////
// Definition of a processing element (basically a MAC)
//////////////////////////////////////////////////////////////////////////
module  processing_element_systolic_4x4_fp(
 reset, 
 clk, 
 in_a,
 in_b, 
 out_a, 
 out_b, 
 out_c
 );

 input reset;
 input clk;
 input  [`DWIDTH-1:0] in_a;
 input  [`DWIDTH-1:0] in_b;
 output [`DWIDTH-1:0] out_a;
 output [`DWIDTH-1:0] out_b;
 output [`DWIDTH-1:0] out_c;  //reduced precision

 reg [`DWIDTH-1:0] out_a;
 reg [`DWIDTH-1:0] out_b;
 wire [`DWIDTH-1:0] out_c;

 wire [`DWIDTH-1:0] out_mac;

 assign out_c = out_mac;

 `ifdef complex_dsp
 mac_fp_16 u_mac(.a(in_a), .b(in_b), .out(out_mac), .reset(reset), .clk(clk));
 `else
 seq_mac_systolic_4x4_fp u_mac(.a(in_a), .b(in_b), .out(out_mac), .reset(reset), .clk(clk));
 `endif

 always @(posedge clk)begin
    if(reset) begin
      out_a<=0;
      out_b<=0;
    end
    else begin  
      out_a<=in_a;
      out_b<=in_b;
    end
 end
 
endmodule

//////////////////////////////////////////////////////////////////////////
// Multiply-and-accumulate (MAC) block
//////////////////////////////////////////////////////////////////////////
//module seq_mac_systolic_4x4_fp(a, b, out, reset, clk);
//input [`DWIDTH-1:0] a;
//input [`DWIDTH-1:0] b;
//input reset;
//input clk;
//output [`DWIDTH-1:0] out;
//
//reg [2*`DWIDTH-1:0] out_temp;
//wire [`DWIDTH-1:0] mul_out;
//wire [2*`DWIDTH-1:0] add_out;
//
//reg [`DWIDTH-1:0] a_flopped;
//reg [`DWIDTH-1:0] b_flopped;
//
//wire [2*`DWIDTH-1:0] mul_out_temp;
//reg [2*`DWIDTH-1:0] mul_out_temp_reg;
//
//always @(posedge clk) begin
//  if (reset) begin
//    a_flopped <= 0;
//    b_flopped <= 0;
//  end else begin
//    a_flopped <= a;
//    b_flopped <= b;
//  end
//end
//
////assign mul_out = a * b;
//qmult_systolic_4x4_fp mult_u1(.i_multiplicand(a_flopped), .i_multiplier(b_flopped), .o_result(mul_out_temp));
//
//always @(posedge clk) begin
//  if (reset) begin
//    mul_out_temp_reg <= 0;
//  end else begin
//    mul_out_temp_reg <= mul_out_temp;
//  end
//end
//
////we just truncate the higher bits of the product
////assign add_out = mul_out + out;
//qadd_systolic_4x4_fp add_u1(.a(out_temp), .b(mul_out_temp_reg), .c(add_out));
//
//always @(posedge clk) begin
//  if (reset) begin
//    out_temp <= 0;
//  end else begin
//    out_temp <= add_out;
//  end
//end
//
////down cast the result
//assign out = 
//    (out_temp[2*`DWIDTH-1] == 0) ?  //positive number
//        (
//           (|(out_temp[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 1, that means overlfow
//             {out_temp[2*`DWIDTH-1] , {(`DWIDTH-1){1'b1}}} : //sign bit and then all 1s
//             {out_temp[2*`DWIDTH-1] , out_temp[`DWIDTH-2:0]} 
//        )
//        : //negative number
//        (
//           (|(out_temp[2*`DWIDTH-2 : `DWIDTH-1])) ?  //is any bit from 14:7 is 0, that means overlfow
//             {out_temp[2*`DWIDTH-1] , out_temp[`DWIDTH-2:0]} :
//             {out_temp[2*`DWIDTH-1] , {(`DWIDTH-1){1'b0}}} //sign bit and then all 0s
//        );
//
//endmodule
//
//module qmult_systolic_4x4_fp(i_multiplicand,i_multiplier,o_result);
//input [`DWIDTH-1:0] i_multiplicand;
//input [`DWIDTH-1:0] i_multiplier;
//output [2*`DWIDTH-1:0] o_result;
//
//assign o_result = i_multiplicand * i_multiplier;
////DW02_mult #(`DWIDTH,`DWIDTH) u_mult(.A(i_multiplicand), .B(i_multiplier), .TC(1'b1), .PRODUCT(o_result));
//
//endmodule
//
//module qadd_systolic_4x4_fp(a,b,c);
//input [2*`DWIDTH-1:0] a;
//input [2*`DWIDTH-1:0] b;
//output [2*`DWIDTH-1:0] c;
//
//assign c = a + b;
////DW01_add #(`DWIDTH) u_add(.A(a), .B(b), .CI(1'b0), .SUM(c), .CO());
//endmodule

`ifndef complex_dsp

//////////////////////////////////////////////////////////////////////////
// Multiply-and-accumulate (MAC) block
//////////////////////////////////////////////////////////////////////////
module seq_mac_systolic_4x4_fp(a, b, out, reset, clk);
input [`DWIDTH-1:0] a;
input [`DWIDTH-1:0] b;
input reset;
input clk;
output [`DWIDTH-1:0] out;

reg [2*`DWIDTH-1:0] out_temp;
wire [2*`DWIDTH-1:0] mul_out;
wire [2*`DWIDTH-1:0] add_out;

reg [`DWIDTH-1:0] a_flopped;
reg [`DWIDTH-1:0] b_flopped;

wire [2*`DWIDTH-1:0] mul_out_temp;
reg [2*`DWIDTH-1:0] mul_out_temp_reg;

always @(posedge clk) begin
  if (reset) begin
    a_flopped <= 0;
    b_flopped <= 0;
  end else begin
    a_flopped <= a;
    b_flopped <= b;
  end
end

//assign mul_out = a * b;
qmult_systolic_4x4_fp mult_u1(.clk(clk), .rst(reset), .i_multiplicand(a_flopped), .i_multiplier(b_flopped), .o_result(mul_out_temp));

always @(posedge clk) begin
  if (reset) begin
    mul_out_temp_reg <= 0;
  end else begin
    mul_out_temp_reg <= mul_out_temp;
  end
end

assign mul_out = mul_out_temp_reg;

qadd_systolic_4x4_fp add_u1(.clk(clk), .rst(reset), .a(out_temp), .b(mul_out), .c(add_out));

always @(posedge clk) begin
  if (reset) begin
    out_temp <= 0;
  end else begin
    out_temp <= add_out;
  end
end

//fp32 to fp16 conversion
wire [15:0] fpadd_16_result;
fp32_to_fp16_systolic_4x4_fp u_32to16 (.a(out_temp), .b(out));

endmodule


//////////////////////////////////////////////////////////////////////////
// Multiplier
//////////////////////////////////////////////////////////////////////////
module qmult_systolic_4x4_fp(clk,rst,i_multiplicand,i_multiplier,o_result);
input clk;
input rst;
input [`DWIDTH-1:0] i_multiplicand;
input [`DWIDTH-1:0] i_multiplier;
output [2*`DWIDTH-1:0] o_result;

wire FPMult_16_systolic_4x4_fp_clk_NC;
wire FPMult_16_systolic_4x4_fp_rst_NC;
wire [15:0] FPMult_16_systolic_4x4_fp_result;
wire [4:0] FPMult_16_systolic_4x4_fp_flags;

FPMult_16_systolic_4x4_fp u_FPMult_16_systolic_4x4_fp(
   .clk(clk),
   .rst(rst),
   .a(i_multiplicand[15:0]),
   .b(i_multiplier[15:0]),
   .result(FPMult_16_systolic_4x4_fp_result),
   .flags(FPMult_16_systolic_4x4_fp_flags)
 );

//Convert fp16 to fp32
fp16_to_fp32_systolic_4x4_fp u_16to32 (.a(FPMult_16_systolic_4x4_fp_result), .b(o_result));

endmodule


//////////////////////////////////////////////////////////////////////////
// Adder
//////////////////////////////////////////////////////////////////////////
module qadd_systolic_4x4_fp(clk,rst,a,b,c);
input clk;
input rst;
input [2*`DWIDTH-1:0] a;
input [2*`DWIDTH-1:0] b;
output [2*`DWIDTH-1:0] c;

wire fpadd_32_clk_NC;
wire fpadd_32_rst_NC;
wire [4:0] fpadd_32_flags;

FPAddSub_single_systolic_4x4_fp u_fpaddsub_32(
  .clk(clk),
  .rst(rst),
  .a(a),
  .b(b),
  .operation(1'b0), 
  .result(c),
  .flags(fpadd_32_flags));

endmodule
`endif

`ifndef complex_dsp

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
// Definition of a 16-bit floating point multiplier
// This is a heavily modified version of:
// https://github.com/fbrosser/DSP48E1-FP/tree/master/src/FPMult
// Original author: Fredrik Brosser
// Abridged by: Samidh Mehta
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

module FPMult_16_systolic_4x4_fp(
		clk,
		rst,
		a,
		b,
		result,
		flags
    );
	
	// Input Ports
	input clk ;							// Clock
	input rst ;							// Reset signal
	input [`DWIDTH-1:0] a;						// Input A, a 32-bit floating point number
	input [`DWIDTH-1:0] b;						// Input B, a 32-bit floating point number
	
	// Output ports
	output [`DWIDTH-1:0] result ;					// Product, result of the operation, 32-bit FP number
	output [4:0] flags ;						// Flags indicating exceptions according to IEEE754
	
	// Internal signals
	wire [`DWIDTH-1:0] Z_int ;					// Product, result of the operation, 32-bit FP number
	wire [4:0] Flags_int ;						// Flags indicating exceptions according to IEEE754
	
	wire Sa ;							// A's sign
	wire Sb ;							// B's sign
	wire Sp ;							// Product sign
	wire [`EXPONENT-1:0] Ea ;					// A's exponent
	wire [`EXPONENT-1:0] Eb ;					// B's exponent
	wire [2*`MANTISSA+1:0] Mp ;					// Product mantissa
	wire [4:0] InputExc ;						// Exceptions in inputs
	wire [`MANTISSA-1:0] NormM ;					// Normalized mantissa
	wire [`EXPONENT:0] NormE ;					// Normalized exponent
	wire [`MANTISSA:0] RoundM ;					// Normalized mantissa
	wire [`EXPONENT:0] RoundE ;					// Normalized exponent
	wire [`MANTISSA:0] RoundMP ;					// Normalized mantissa
	wire [`EXPONENT:0] RoundEP ;					// Normalized exponent
	wire GRS ;

	//reg [63:0] pipe_0;						// Pipeline register Input->Prep
	reg [2*`DWIDTH-1:0] pipe_0;					// Pipeline register Input->Prep

	//reg [92:0] pipe_1;						// Pipeline register Prep->Execute
	//reg [3*`MANTISSA+2*`EXPONENT+7:0] pipe_1;			// Pipeline register Prep->Execute
	reg [3*`MANTISSA+2*`EXPONENT+18:0] pipe_1;

	//reg [38:0] pipe_2;						// Pipeline register Execute->Normalize
	reg [`MANTISSA+`EXPONENT+7:0] pipe_2;				// Pipeline register Execute->Normalize
	
	//reg [72:0] pipe_3;						// Pipeline register Normalize->Round
	reg [2*`MANTISSA+2*`EXPONENT+10:0] pipe_3;			// Pipeline register Normalize->Round

	//reg [36:0] pipe_4;						// Pipeline register Round->Output
	reg [`DWIDTH+4:0] pipe_4;					// Pipeline register Round->Output
	
	assign result = pipe_4[`DWIDTH+4:5] ;
	assign flags = pipe_4[4:0] ;
	
	// Prepare the operands for alignment and check for exceptions
	FPMult_PrepModule_systolic_4x4_fp PrepModule(clk, rst, pipe_0[2*`DWIDTH-1:`DWIDTH], pipe_0[`DWIDTH-1:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA+1:0], InputExc[4:0]) ;

	// Perform (unsigned) mantissa multiplication
	FPMult_ExecuteModule_systolic_4x4_fp ExecuteModule(pipe_1[3*`MANTISSA+`EXPONENT*2+7:2*`MANTISSA+2*`EXPONENT+8], pipe_1[2*`MANTISSA+2*`EXPONENT+7:2*`MANTISSA+7], pipe_1[2*`MANTISSA+6:5], pipe_1[2*`MANTISSA+2*`EXPONENT+6:2*`MANTISSA+`EXPONENT+7], pipe_1[2*`MANTISSA+`EXPONENT+6:2*`MANTISSA+7], pipe_1[2*`MANTISSA+2*`EXPONENT+8], pipe_1[2*`MANTISSA+2*`EXPONENT+7], Sp, NormE[`EXPONENT:0], NormM[`MANTISSA-1:0], GRS) ;

	// Round result and if necessary, perform a second (post-rounding) normalization step
	FPMult_NormalizeModule_systolic_4x4_fp NormalizeModule(pipe_2[`MANTISSA-1:0], pipe_2[`MANTISSA+`EXPONENT:`MANTISSA], RoundE[`EXPONENT:0], RoundEP[`EXPONENT:0], RoundM[`MANTISSA:0], RoundMP[`MANTISSA:0]) ;		

	// Round result and if necessary, perform a second (post-rounding) normalization step
	//FPMult_RoundModule_systolic_4x4_fp RoundModule(pipe_3[47:24], pipe_3[23:0], pipe_3[65:57], pipe_3[56:48], pipe_3[66], pipe_3[67], pipe_3[72:68], Z_int[31:0], Flags_int[4:0]) ;		
	FPMult_RoundModule_systolic_4x4_fp RoundModule(pipe_3[2*`MANTISSA+1:`MANTISSA+1], pipe_3[`MANTISSA:0], pipe_3[2*`MANTISSA+2*`EXPONENT+3:2*`MANTISSA+`EXPONENT+3], pipe_3[2*`MANTISSA+`EXPONENT+2:2*`MANTISSA+2], pipe_3[2*`MANTISSA+2*`EXPONENT+4], pipe_3[2*`MANTISSA+2*`EXPONENT+5], pipe_3[2*`MANTISSA+2*`EXPONENT+10:2*`MANTISSA+2*`EXPONENT+6], Z_int[`DWIDTH-1:0], Flags_int[4:0]) ;		

//adding always@ (*) instead of posedge clock to make design combinational
	always @ (posedge clk) begin	
		if(rst) begin
			pipe_0 <= 0;
			pipe_1 <= 0;
			pipe_2 <= 0; 
			pipe_3 <= 0;
			pipe_4 <= 0;
		end 
		else begin		
			/* PIPE 0
				[2*`DWIDTH-1:`DWIDTH] A
				[`DWIDTH-1:0] B
			*/
                       pipe_0 <= {a, b} ;


			/* PIPE 1
				[2*`EXPONENT+3*`MANTISSA + 18: 2*`EXPONENT+2*`MANTISSA + 18] //pipe_0[`DWIDTH+`MANTISSA-1:`DWIDTH] , mantissa of A
				[2*`EXPONENT+2*`MANTISSA + 17 :2*`EXPONENT+2*`MANTISSA + 9] // pipe_0[8:0]
				[2*`EXPONENT+2*`MANTISSA + 8] Sa
				[2*`EXPONENT+2*`MANTISSA + 7] Sb
				[2*`EXPONENT+2*`MANTISSA + 6:`EXPONENT+2*`MANTISSA+7] Ea
				[`EXPONENT +2*`MANTISSA+6:2*`MANTISSA+7] Eb
				[2*`MANTISSA+1+5:5] Mp
				[4:0] InputExc
			*/
			//pipe_1 <= {pipe_0[`DWIDTH+`MANTISSA-1:`DWIDTH], pipe_0[`MANTISSA_MUL_SPLIT_LSB-1:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA-1:0], InputExc[4:0]} ;
			pipe_1 <= {pipe_0[`DWIDTH+`MANTISSA-1:`DWIDTH], pipe_0[8:0], Sa, Sb, Ea[`EXPONENT-1:0], Eb[`EXPONENT-1:0], Mp[2*`MANTISSA+1:0], InputExc[4:0]} ;
			
			/* PIPE 2
				[`EXPONENT + `MANTISSA + 7:`EXPONENT + `MANTISSA + 3] InputExc
				[`EXPONENT + `MANTISSA + 2] GRS
				[`EXPONENT + `MANTISSA + 1] Sp
				[`EXPONENT + `MANTISSA:`MANTISSA] NormE
				[`MANTISSA-1:0] NormM
			*/
			pipe_2 <= {pipe_1[4:0], GRS, Sp, NormE[`EXPONENT:0], NormM[`MANTISSA-1:0]} ;
			/* PIPE 3
				[2*`EXPONENT+2*`MANTISSA+10:2*`EXPONENT+2*`MANTISSA+6] InputExc
				[2*`EXPONENT+2*`MANTISSA+5] GRS
				[2*`EXPONENT+2*`MANTISSA+4] Sp	
				[2*`EXPONENT+2*`MANTISSA+3:`EXPONENT+2*`MANTISSA+3] RoundE
				[`EXPONENT+2*`MANTISSA+2:2*`MANTISSA+2] RoundEP
				[2*`MANTISSA+1:`MANTISSA+1] RoundM
				[`MANTISSA:0] RoundMP
			*/
			pipe_3 <= {pipe_2[`EXPONENT+`MANTISSA+7:`EXPONENT+`MANTISSA+1], RoundE[`EXPONENT:0], RoundEP[`EXPONENT:0], RoundM[`MANTISSA:0], RoundMP[`MANTISSA:0]} ;
			/* PIPE 4
				[`DWIDTH+4:5] Z
				[4:0] Flags
			*/				
			pipe_4 <= {Z_int[`DWIDTH-1:0], Flags_int[4:0]} ;
		end
	end
		
endmodule



module FPMult_PrepModule_systolic_4x4_fp (
		clk,
		rst,
		a,
		b,
		Sa,
		Sb,
		Ea,
		Eb,
		Mp,
		InputExc
	);
	
	// Input ports
	input clk ;
	input rst ;
	input [`DWIDTH-1:0] a ;								// Input A, a 32-bit floating point number
	input [`DWIDTH-1:0] b ;								// Input B, a 32-bit floating point number
	
	// Output ports
	output Sa ;										// A's sign
	output Sb ;										// B's sign
	output [`EXPONENT-1:0] Ea ;								// A's exponent
	output [`EXPONENT-1:0] Eb ;								// B's exponent
	output [2*`MANTISSA+1:0] Mp ;							// Mantissa product
	output [4:0] InputExc ;						// Input numbers are exceptions
	
	// Internal signals							// If signal is high...
	wire ANaN ;										// A is a signalling NaN
	wire BNaN ;										// B is a signalling NaN
	wire AInf ;										// A is infinity
	wire BInf ;										// B is infinity
    wire [`MANTISSA-1:0] Ma;
    wire [`MANTISSA-1:0] Mb;
	
	assign ANaN = &(a[`DWIDTH-2:`MANTISSA]) &  |(a[`DWIDTH-2:`MANTISSA]) ;			// All one exponent and not all zero mantissa - NaN
	assign BNaN = &(b[`DWIDTH-2:`MANTISSA]) &  |(b[`MANTISSA-1:0]);			// All one exponent and not all zero mantissa - NaN
	assign AInf = &(a[`DWIDTH-2:`MANTISSA]) & ~|(a[`DWIDTH-2:`MANTISSA]) ;		// All one exponent and all zero mantissa - Infinity
	assign BInf = &(b[`DWIDTH-2:`MANTISSA]) & ~|(b[`DWIDTH-2:`MANTISSA]) ;		// All one exponent and all zero mantissa - Infinity
	
	// Check for any exceptions and put all flags into exception vector
	assign InputExc = {(ANaN | BNaN | AInf | BInf), ANaN, BNaN, AInf, BInf} ;
	//assign InputExc = {(ANaN | ANaN | BNaN |BNaN), ANaN, ANaN, BNaN,BNaN} ;
	
	// Take input numbers apart
	assign Sa = a[`DWIDTH-1] ;							// A's sign
	assign Sb = b[`DWIDTH-1] ;							// B's sign
	assign Ea = a[`DWIDTH-2:`MANTISSA];						// Store A's exponent in Ea, unless A is an exception
	assign Eb = b[`DWIDTH-2:`MANTISSA];						// Store B's exponent in Eb, unless B is an exception	
//    assign Ma = a[`MANTISSA_MSB:`MANTISSA_LSB];
  //  assign Mb = b[`MANTISSA_MSB:`MANTISSA_LSB];
	


	//assign Mp = ({4'b0001, a[`MANTISSA-1:0]}*{4'b0001, b[`MANTISSA-1:9]}) ;
	assign Mp = ({1'b1,a[`MANTISSA-1:0]}*{1'b1, b[`MANTISSA-1:0]}) ;

	
    //We multiply part of the mantissa here
    //Full mantissa of A
    //Bits MANTISSA_MUL_SPLIT_MSB:MANTISSA_MUL_SPLIT_LSB of B
   // wire [`ACTUAL_MANTISSA-1:0] inp_A;
   // wire [`ACTUAL_MANTISSA-1:0] inp_B;
   // assign inp_A = {1'b1, Ma};
   // assign inp_B = {{(`MANTISSA-(`MANTISSA_MUL_SPLIT_MSB-`MANTISSA_MUL_SPLIT_LSB+1)){1'b0}}, 1'b1, Mb[`MANTISSA_MUL_SPLIT_MSB:`MANTISSA_MUL_SPLIT_LSB]};
   // DW02_mult #(`ACTUAL_MANTISSA,`ACTUAL_MANTISSA) u_mult(.A(inp_A), .B(inp_B), .TC(1'b0), .PRODUCT(Mp));
endmodule


module FPMult_ExecuteModule_systolic_4x4_fp(
		a,
		b,
		MpC,
		Ea,
		Eb,
		Sa,
		Sb,
		Sp,
		NormE,
		NormM,
		GRS
    );

	// Input ports
	input [`MANTISSA-1:0] a ;
	input [2*`EXPONENT:0] b ;
	input [2*`MANTISSA+1:0] MpC ;
	input [`EXPONENT-1:0] Ea ;						// A's exponent
	input [`EXPONENT-1:0] Eb ;						// B's exponent
	input Sa ;								// A's sign
	input Sb ;								// B's sign
	
	// Output ports
	output Sp ;								// Product sign
	output [`EXPONENT:0] NormE ;													// Normalized exponent
	output [`MANTISSA-1:0] NormM ;												// Normalized mantissa
	output GRS ;
	
	wire [2*`MANTISSA+1:0] Mp ;
	
	assign Sp = (Sa ^ Sb) ;												// Equal signs give a positive product
	
   // wire [`ACTUAL_MANTISSA-1:0] inp_a;
   // wire [`ACTUAL_MANTISSA-1:0] inp_b;
   // assign inp_a = {1'b1, a};
   // assign inp_b = {{(`MANTISSA-`MANTISSA_MUL_SPLIT_LSB){1'b0}}, 1'b0, b};
   // DW02_mult #(`ACTUAL_MANTISSA,`ACTUAL_MANTISSA) u_mult(.A(inp_a), .B(inp_b), .TC(1'b0), .PRODUCT(Mp_temp));
   // DW01_add #(2*`ACTUAL_MANTISSA) u_add(.A(Mp_temp), .B(MpC<<`MANTISSA_MUL_SPLIT_LSB), .CI(1'b0), .SUM(Mp), .CO());

	//assign Mp = (MpC<<(2*`EXPONENT+1)) + ({4'b0001, a[`MANTISSA-1:0]}*{1'b0, b[2*`EXPONENT:0]}) ;
	assign Mp = MpC;


	assign NormM = (Mp[2*`MANTISSA+1] ? Mp[2*`MANTISSA:`MANTISSA+1] : Mp[2*`MANTISSA-1:`MANTISSA]); 	// Check for overflow
	assign NormE = (Ea + Eb + Mp[2*`MANTISSA+1]);								// If so, increment exponent
	
	assign GRS = ((Mp[`MANTISSA]&(Mp[`MANTISSA+1]))|(|Mp[`MANTISSA-1:0])) ;
	
endmodule

module FPMult_NormalizeModule_systolic_4x4_fp(
		NormM,
		NormE,
		RoundE,
		RoundEP,
		RoundM,
		RoundMP
    );

	// Input Ports
	input [`MANTISSA-1:0] NormM ;									// Normalized mantissa
	input [`EXPONENT:0] NormE ;									// Normalized exponent

	// Output Ports
	output [`EXPONENT:0] RoundE ;
	output [`EXPONENT:0] RoundEP ;
	output [`MANTISSA:0] RoundM ;
	output [`MANTISSA:0] RoundMP ; 
	
// EXPONENT = 5 
// EXPONENT -1 = 4
// NEED to subtract 2^4 -1 = 15

wire [`EXPONENT-1 : 0] bias;

assign bias =  ((1<< (`EXPONENT -1)) -1);

	assign RoundE = NormE - bias ;
	assign RoundEP = NormE - bias -1 ;
	assign RoundM = NormM ;
	assign RoundMP = NormM ;

endmodule

module FPMult_RoundModule_systolic_4x4_fp(
		RoundM,
		RoundMP,
		RoundE,
		RoundEP,
		Sp,
		GRS,
		InputExc,
		Z,
		Flags
    );

	// Input Ports
	input [`MANTISSA:0] RoundM ;									// Normalized mantissa
	input [`MANTISSA:0] RoundMP ;									// Normalized exponent
	input [`EXPONENT:0] RoundE ;									// Normalized mantissa + 1
	input [`EXPONENT:0] RoundEP ;									// Normalized exponent + 1
	input Sp ;												// Product sign
	input GRS ;
	input [4:0] InputExc ;
	
	// Output Ports
	output [`DWIDTH-1:0] Z ;										// Final product
	output [4:0] Flags ;
	
	// Internal Signals
	wire [`EXPONENT:0] FinalE ;									// Rounded exponent
	wire [`MANTISSA:0] FinalM;
	wire [`MANTISSA:0] PreShiftM;
	
	assign PreShiftM = GRS ? RoundMP : RoundM ;	// Round up if R and (G or S)
	
	// Post rounding normalization (potential one bit shift> use shifted mantissa if there is overflow)
	assign FinalM = (PreShiftM[`MANTISSA] ? {1'b0, PreShiftM[`MANTISSA:1]} : PreShiftM[`MANTISSA:0]) ;
	
	assign FinalE = (PreShiftM[`MANTISSA] ? RoundEP : RoundE) ; // Increment exponent if a shift was done
	
	assign Z = {Sp, FinalE[`EXPONENT-1:0], FinalM[`MANTISSA-1:0]} ;   // Putting the pieces together
	assign Flags = InputExc[4:0];

endmodule

`endif

 
//////////////////////////////////////////////////////////////////////////
// A floating point 16-bit to floating point 32-bit converter
//////////////////////////////////////////////////////////////////////////
`ifndef complex_dsp
module fp16_to_fp32_systolic_4x4_fp (input [15:0] a , output [31:0] b);

reg [31:0]b_temp;
reg [3:0] j;
reg [3:0] k;
reg [3:0] k_temp;
always @ (*) begin

if ( a [14: 0] == 15'b0 ) begin //signed zero
	b_temp [31] = a[15]; //sign bit
	b_temp[30:0] = 31'b0;
end

else begin

	if ( a[14 : 10] == 5'b0 ) begin //denormalized (covert to normalized)
		
		for (j=0; j<=9; j=j+1) begin
			if (a[j] == 1'b1) begin 
			    k_temp = j;	
			end
		end
	k = 9 - k_temp;

	b_temp [22:0] = ( (a [9:0] << (k+1'b1)) & 10'h3FF ) << 13;
	b_temp [30:23] =  7'd127 - 4'd15 - k;
	b_temp [31] = a[15];
	end

	else if ( a[14 : 10] == 5'b11111 ) begin //Infinity/ NAN
	b_temp [22:0] = a [9:0] << 13;
	b_temp [30:23] = 8'hFF;
	b_temp [31] = a[15];
	end

	else begin //Normalized Number
	b_temp [22:0] = a [9:0] << 13;
	b_temp [30:23] =  7'd127 - 4'd15 + a[14:10];
	b_temp [31] = a[15];
	end
end
end

assign b = b_temp;


endmodule

//////////////////////////////////////////////////////////////////////////
// A floating point 32-bit to floating point 16-bit converter
//////////////////////////////////////////////////////////////////////////
module fp32_to_fp16_systolic_4x4_fp (input [31:0] a , output [15:0] b);

reg [15:0]b_temp;
//integer j;
//reg [3:0]k;
always @ (*) begin

if ( a [30: 0] == 15'b0 ) begin //signed zero
	b_temp [15] = a[30]; //sign bit
	b_temp [14:0] = 15'b0; 
end

else begin

	if ( a[30 : 23] <= 8'd112  &&  a[30 : 23] >= 8'd103 ) begin //denormalized (covert to normalized)
		
	b_temp [9:0] = {1'b1, a[22:13]} >> {8'd112 - a[30 : 23] + 1'b1} ;  
	b_temp [14:10] =  5'b0;
	b_temp [15] = a[31];
	end

	else if ( a[ 30 : 23] == 8'b11111111 ) begin //Infinity/ NAN
	b_temp [9:0] = a [22:13];
	b_temp [14:10] = 5'h1F;
	b_temp [15] = a[31];
	end

	else begin //Normalized Number
	b_temp [9:0] = a [22:13];
	b_temp [14:10] = 4'd15 - 7'd127  + a[30:23]; //number should be in the range which can be depicted by fp16 (exp for fp32: 70h, 8Eh ; normalized exp for fp32: -15 to 15)
	b_temp [15] = a[31];
	end
end
end

assign b = b_temp;


endmodule
`endif

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
// Definition of a 32-bit floating point adder/subtractor
// This is a heavily modified version of:
// https://github.com/fbrosser/DSP48E1-FP/tree/master/src/FP_AddSub
// Original author: Fredrik Brosser
// Abridged by: Samidh Mehta
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

`ifndef complex_dsp
module FPAddSub_single_systolic_4x4_fp(
		clk,
		rst,
		a,
		b,
		operation,
		result,
		flags
	);

// Clock and reset
	input clk ;										// Clock signal
	input rst ;										// Reset (active high, resets pipeline registers)
	
	// Input ports
	input [31:0] a ;								// Input A, a 32-bit floating point number
	input [31:0] b ;								// Input B, a 32-bit floating point number
	input operation ;								// Operation select signal
	
	// Output ports
	output [31:0] result ;						// Result of the operation
	output [4:0] flags ;							// Flags indicating exceptions according to IEEE754

	reg [68:0]pipe_1;
	reg [54:0]pipe_2;
	reg [45:0]pipe_3;


//internal module wires

//output ports
	wire Opout;
	wire Sa;
	wire Sb;
	wire MaxAB;
	wire [7:0] CExp;
	wire [4:0] Shift;
	wire [22:0] Mmax;
	wire [4:0] InputExc;
	wire [23:0] Mmin_3;

	wire [32:0] SumS_5 ;
	wire [4:0] Shift_1;							
	wire PSgn ;							
	wire Opr ;	
	
	wire [22:0] NormM ;				// Normalized mantissa
	wire [8:0] NormE ;					// Adjusted exponent
	wire ZeroSum ;						// Zero flag
	wire NegE ;							// Flag indicating negative exponent
	wire R ;								// Round bit
	wire S ;								// Final sticky bit
	wire FG ;

FPAddSub_a_systolic_4x4_fp M1(a,b,operation,Opout,Sa,Sb,MaxAB,CExp,Shift,Mmax,InputExc,Mmin_3);

FPAddSub_b_systolic_4x4_fp M2(pipe_1[51:29],pipe_1[23:0],pipe_1[67],pipe_1[66],pipe_1[65],pipe_1[68],SumS_5,Shift_1,PSgn,Opr);

FPAddSub_c_systolic_4x4_fp M3(pipe_2[54:22],pipe_2[21:17],pipe_2[16:9],NormM,NormE,ZeroSum,NegE,R,S,FG);

FPAddSub_d_systolic_4x4_fp M4(pipe_3[13],pipe_3[22:14],pipe_3[45:23],pipe_3[11],pipe_3[10],pipe_3[9],pipe_3[8],pipe_3[7],pipe_3[6],pipe_3[5],pipe_3[12],pipe_3[4:0],result,flags );


always @ (posedge clk) begin	
		if(rst) begin
			pipe_1 <= 0;
			pipe_2 <= 0;
			pipe_3 <= 0;
		end 
		else begin
/*
pipe_1:
	[68] Opout;
	[67] Sa;
	[66] Sb;
	[65] MaxAB;
	[64:57] CExp;
	[56:52] Shift;
	[51:29] Mmax;
	[28:24] InputExc;
	[23:0] Mmin_3;	
*/

pipe_1 <= {Opout,Sa,Sb,MaxAB,CExp,Shift,Mmax,InputExc,Mmin_3};

/*
pipe_2:
	[54:22]SumS_5;
	[21:17]Shift;
	[16:9]CExp;	
	[8]Sa;
	[7]Sb;
	[6]operation;
	[5]MaxAB;	
	[4:0]InputExc
*/

pipe_2 <= {SumS_5,Shift_1,pipe_1[64:57], pipe_1[67], pipe_1[66], pipe_1[68], pipe_1[65], pipe_1[28:24] };

/*
pipe_3:
	[45:23] NormM ;				
	[22:14] NormE ;					
	[13]ZeroSum ;						
	[12]NegE ;							
	[11]R ;								
	[10]S ;								
	[9]FG ;
	[8]Sa;
	[7]Sb;
	[6]operation;
	[5]MaxAB;	
	[4:0]InputExc
*/

pipe_3 <= {NormM,NormE,ZeroSum,NegE,R,S,FG, pipe_2[8], pipe_2[7], pipe_2[6], pipe_2[5], pipe_2[4:0] };

end
end

endmodule

// Prealign + Align + Shift 1 + Shift 2
module FPAddSub_a_systolic_4x4_fp(
		A,
		B,
		operation,
		Opout,
		Sa,
		Sb,
		MaxAB,
		CExp,
		Shift,
		Mmax,
		InputExc,
		Mmin_3
		
		
	);
	
	// Input ports
	input [31:0] A ;										// Input A, a 32-bit floating point number
	input [31:0] B ;										// Input B, a 32-bit floating point number
	input operation ;
	
	//output ports
	output Opout;
	output Sa;
	output Sb;
	output MaxAB;
	output [7:0] CExp;
	output [4:0] Shift;
	output [22:0] Mmax;
	output [4:0] InputExc;
	output [23:0] Mmin_3;	
							
	wire [9:0] ShiftDet ;							
	wire [30:0] Aout ;
	wire [30:0] Bout ;
	

	// Internal signals									// If signal is high...
	wire ANaN ;												// A is a NaN (Not-a-Number)
	wire BNaN ;												// B is a NaN
	wire AInf ;												// A is infinity
	wire BInf ;												// B is infinity
	wire [7:0] DAB ;										// ExpA - ExpB					
	wire [7:0] DBA ;										// ExpB - ExpA	
	
	assign ANaN = &(A[30:23]) & |(A[22:0]) ;		// All one exponent and not all zero mantissa - NaN
	assign BNaN = &(B[30:23]) & |(B[22:0]);		// All one exponent and not all zero mantissa - NaN
	assign AInf = &(A[30:23]) & ~|(A[22:0]) ;	// All one exponent and all zero mantissa - Infinity
	assign BInf = &(B[30:23]) & ~|(B[22:0]) ;	// All one exponent and all zero mantissa - Infinity
	
	// Put all flags into exception vector
	assign InputExc = {(ANaN | BNaN | AInf | BInf), ANaN, BNaN, AInf, BInf} ;
	
	//assign DAB = (A[30:23] - B[30:23]) ;
	//assign DBA = (B[30:23] - A[30:23]) ;
  assign DAB = (A[30:23] + ~(B[30:23]) + 1) ;
	assign DBA = (B[30:23] + ~(A[30:23]) + 1) ;

	assign Sa = A[31] ;									// A's sign bit
	assign Sb = B[31] ;									// B's sign	bit
	assign ShiftDet = {DBA[4:0], DAB[4:0]} ;		// Shift data
	assign Opout = operation ;
	assign Aout = A[30:0] ;
	assign Bout = B[30:0] ;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Output ports
													// Number of steps to smaller mantissa shift right
	wire [22:0] Mmin_1 ;							// Smaller mantissa 
	
	// Internal signals
	//wire BOF ;										// Check for shifting overflow if B is larger
	//wire AOF ;										// Check for shifting overflow if A is larger
	
	assign MaxAB = (Aout[30:0] < Bout[30:0]) ;	
	//assign BOF = ShiftDet[9:5] < 25 ;		// Cannot shift more than 25 bits
	//assign AOF = ShiftDet[4:0] < 25 ;		// Cannot shift more than 25 bits
	
	// Determine final shift value
	//assign Shift = MaxAB ? (BOF ? ShiftDet[9:5] : 5'b11001) : (AOF ? ShiftDet[4:0] : 5'b11001) ;
	
	assign Shift = MaxAB ? ShiftDet[9:5] : ShiftDet[4:0] ;
	
	// Take out smaller mantissa and append shift space
	assign Mmin_1 = MaxAB ? Aout[22:0] : Bout[22:0] ; 
	
	// Take out larger mantissa	
	assign Mmax = MaxAB ? Bout[22:0]: Aout[22:0] ;	
	
	// Common exponent
	assign CExp = (MaxAB ? Bout[30:23] : Aout[30:23]) ;	

// Input ports
					// Smaller mantissa after 16|12|8|4 shift
	wire [2:0] Shift_1 ;						// Shift amount
	
	assign Shift_1 = Shift [4:2];

	wire [23:0] Mmin_2 ;						// The smaller mantissa
	
	// Internal signals
	reg	  [23:0]		Lvl1;
	reg	  [23:0]		Lvl2;
	wire    [47:0]    Stage1;	
	integer           i;                // Loop variable
	
	always @(*) begin						
		// Rotate by 16?
		Lvl1 <= Shift_1[2] ? {17'b00000000000000001, Mmin_1[22:16]} : {1'b1, Mmin_1}; 
	end
	
	assign Stage1 = {Lvl1, Lvl1};
	
	always @(*) begin    					// Rotate {0 | 4 | 8 | 12} bits
	  case (Shift_1[1:0])
			// Rotate by 0	
			2'b00:  Lvl2 <= Stage1[23:0];       			
			// Rotate by 4	
			2'b01:  begin for (i=0; i<=23; i=i+1) begin Lvl2[i] <= Stage1[i+4]; end Lvl2[23:19] <= 0; end
			// Rotate by 8
			2'b10:  begin for (i=0; i<=23; i=i+1) begin Lvl2[i] <= Stage1[i+8]; end Lvl2[23:15] <= 0; end
			// Rotate by 12	
			2'b11:  begin for (i=0; i<=23; i=i+1) begin Lvl2[i] <= Stage1[i+12]; end Lvl2[23:11] <= 0; end
	  endcase
	end
	
	// Assign output to next shift stage
	assign Mmin_2 = Lvl2;
								// Smaller mantissa after 16|12|8|4 shift
	wire [1:0] Shift_2 ;						// Shift amount
	
	assign Shift_2 =Shift  [1:0] ;
					// The smaller mantissa
	
	// Internal Signal
	reg	  [23:0]		Lvl3;
	wire    [47:0]    Stage2;	
	integer           j;               // Loop variable
	
	assign Stage2 = {Mmin_2, Mmin_2};

	always @(*) begin    // Rotate {0 | 1 | 2 | 3} bits
	  case (Shift_2[1:0])
			// Rotate by 0
			2'b00:  Lvl3 <= Stage2[23:0];   
			// Rotate by 1
			2'b01:  begin for (j=0; j<=23; j=j+1)  begin Lvl3[j] <= Stage2[j+1]; end Lvl3[23] <= 0; end 
			// Rotate by 2
			2'b10:  begin for (j=0; j<=23; j=j+1)  begin Lvl3[j] <= Stage2[j+2]; end Lvl3[23:22] <= 0; end 
			// Rotate by 3
			2'b11:  begin for (j=0; j<=23; j=j+1)  begin Lvl3[j] <= Stage2[j+3]; end Lvl3[23:21] <= 0; end 	  
	  endcase
	end
	
	// Assign output
	assign Mmin_3 = Lvl3;	

	
endmodule

module FPAddSub_b_systolic_4x4_fp(
		Mmax,
		Mmin,
		Sa,
		Sb,
		MaxAB,
		OpMode,
		SumS_5,
		Shift,
		PSgn,
		Opr
);
	input [22:0] Mmax ;					// The larger mantissa
	input [23:0] Mmin ;					// The smaller mantissa
	input Sa ;								// Sign bit of larger number
	input Sb ;								// Sign bit of smaller number
	input MaxAB ;							// Indicates the larger number (0/A, 1/B)
	input OpMode ;							// Operation to be performed (0/Add, 1/Sub)
	
	// Output ports
	wire [32:0] Sum ;	
						// Output ports
	output [32:0] SumS_5 ;					// Mantissa after 16|0 shift
	output [4:0] Shift ;					// Shift amount				// The result of the operation
	output PSgn ;							// The sign for the result
	output Opr ;							// The effective (performed) operation

	assign Opr = (OpMode^Sa^Sb); 		// Resolve sign to determine operation

	// Perform effective operation
	assign Sum = (OpMode^Sa^Sb) ? ({1'b1, Mmax, 8'b00000000} - {Mmin, 8'b00000000}) : ({1'b1, Mmax, 8'b00000000} + {Mmin, 8'b00000000}) ;
	// Assign result sign
	assign PSgn = (MaxAB ? Sb : Sa) ;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		// Determine normalization shift amount by finding leading nought
	assign Shift =  ( 
		Sum[32] ? 5'b00000 :	 
		Sum[31] ? 5'b00001 : 
		Sum[30] ? 5'b00010 : 
		Sum[29] ? 5'b00011 : 
		Sum[28] ? 5'b00100 : 
		Sum[27] ? 5'b00101 : 
		Sum[26] ? 5'b00110 : 
		Sum[25] ? 5'b00111 :
		Sum[24] ? 5'b01000 :
		Sum[23] ? 5'b01001 :
		Sum[22] ? 5'b01010 :
		Sum[21] ? 5'b01011 :
		Sum[20] ? 5'b01100 :
		Sum[19] ? 5'b01101 :
		Sum[18] ? 5'b01110 :
		Sum[17] ? 5'b01111 :
		Sum[16] ? 5'b10000 :
		Sum[15] ? 5'b10001 :
		Sum[14] ? 5'b10010 :
		Sum[13] ? 5'b10011 :
		Sum[12] ? 5'b10100 :
		Sum[11] ? 5'b10101 :
		Sum[10] ? 5'b10110 :
		Sum[9] ? 5'b10111 :
		Sum[8] ? 5'b11000 :
		Sum[7] ? 5'b11001 : 5'b11010
	);
	
	reg	  [32:0]		Lvl1;
	
	always @(*) begin
		// Rotate by 16?
		Lvl1 <= Shift[4] ? {Sum[16:0], 16'b0000000000000000} : Sum; 
	end
	
	// Assign outputs
	assign SumS_5 = Lvl1;	

endmodule

module FPAddSub_c_systolic_4x4_fp(
		SumS_5,
		Shift,
		CExp,
		NormM,
		NormE,
		ZeroSum,
		NegE,
		R,
		S,
		FG
	);
	
	// Input ports
	input [32:0] SumS_5 ;						// Smaller mantissa after 16|12|8|4 shift
	
	input [4:0] Shift ;						// Shift amount
	
// Input ports
	
	input [7:0] CExp ;
	

	// Output ports
	output [22:0] NormM ;				// Normalized mantissa
	output [8:0] NormE ;					// Adjusted exponent
	output ZeroSum ;						// Zero flag
	output NegE ;							// Flag indicating negative exponent
	output R ;								// Round bit
	output S ;								// Final sticky bit
	output FG ;


	wire [3:0]Shift_1;
	assign Shift_1 = Shift [3:0];
	// Output ports
	wire [32:0] SumS_7 ;						// The smaller mantissa
	
	reg	  [32:0]		Lvl2;
	wire    [65:0]    Stage1;	
	reg	  [32:0]		Lvl3;
	wire    [65:0]    Stage2;	
	integer           i;               	// Loop variable
	
	assign Stage1 = {SumS_5, SumS_5};

	always @(*) begin    					// Rotate {0 | 4 | 8 | 12} bits
	  case (Shift[3:2])
			// Rotate by 0
			2'b00: Lvl2 <= Stage1[32:0];       		
			// Rotate by 4
			2'b01: begin for (i=65; i>=33; i=i-1) begin Lvl2[i-33] <= Stage1[i-4]; end Lvl2[3:0] <= 0; end
			// Rotate by 8
			2'b10: begin for (i=65; i>=33; i=i-1) begin Lvl2[i-33] <= Stage1[i-8]; end Lvl2[7:0] <= 0; end
			// Rotate by 12
			2'b11: begin for (i=65; i>=33; i=i-1) begin Lvl2[i-33] <= Stage1[i-12]; end Lvl2[11:0] <= 0; end
	  endcase
	end
	
	assign Stage2 = {Lvl2, Lvl2};

	always @(*) begin   				 		// Rotate {0 | 1 | 2 | 3} bits
	  case (Shift_1[1:0])
			// Rotate by 0
			2'b00:  Lvl3 <= Stage2[32:0];
			// Rotate by 1
			2'b01: begin for (i=65; i>=33; i=i-1) begin Lvl3[i-33] <= Stage2[i-1]; end Lvl3[0] <= 0; end 
			// Rotate by 2
			2'b10: begin for (i=65; i>=33; i=i-1) begin Lvl3[i-33] <= Stage2[i-2]; end Lvl3[1:0] <= 0; end
			// Rotate by 3
			2'b11: begin for (i=65; i>=33; i=i-1) begin Lvl3[i-33] <= Stage2[i-3]; end Lvl3[2:0] <= 0; end
	  endcase
	end
	
	// Assign outputs
	assign SumS_7 = Lvl3;						// Take out smaller mantissa



	
	// Internal signals
	wire MSBShift ;						// Flag indicating that a second shift is needed
	wire [8:0] ExpOF ;					// MSB set in sum indicates overflow
	wire [8:0] ExpOK ;					// MSB not set, no adjustment
	
	// Calculate normalized exponent and mantissa, check for all-zero sum
	assign MSBShift = SumS_7[32] ;		// Check MSB in unnormalized sum
	assign ZeroSum = ~|SumS_7 ;			// Check for all zero sum
	assign ExpOK = CExp - Shift ;		// Adjust exponent for new normalized mantissa
	assign NegE = ExpOK[8] ;			// Check for exponent overflow
	assign ExpOF = CExp - Shift + 1'b1 ;		// If MSB set, add one to exponent(x2)
	assign NormE = MSBShift ? ExpOF : ExpOK ;			// Check for exponent overflow
	assign NormM = SumS_7[31:9] ;		// The new, normalized mantissa
	
	// Also need to compute sticky and round bits for the rounding stage
	assign FG = SumS_7[8] ; 
	assign R = SumS_7[7] ;
	assign S = |SumS_7[6:0] ;		
	
endmodule

module FPAddSub_d_systolic_4x4_fp(
		ZeroSum,
		NormE,
		NormM,
		R,
		S,
		G,
		Sa,
		Sb,
		Ctrl,
		MaxAB,
		NegE,
		InputExc,
		P,
		Flags 
    );

	// Input ports
	input ZeroSum ;					// Sum is zero
	input [8:0] NormE ;				// Normalized exponent
	input [22:0] NormM ;				// Normalized mantissa
	input R ;							// Round bit
	input S ;							// Sticky bit
	input G ;
	input Sa ;							// A's sign bit
	input Sb ;							// B's sign bit
	input Ctrl ;						// Control bit (operation)
	input MaxAB ;
	

	input NegE ;						// Negative exponent?
	input [4:0] InputExc ;					// Exceptions in inputs A and B

	// Output ports
	output [31:0] P ;					// Final result
	output [4:0] Flags ;				// Exception flags
	
	// 
	wire [31:0] Z ;					// Final result
	wire EOF ;
	
	// Internal signals
	wire [23:0] RoundUpM ;			// Rounded up sum with room for overflow
	wire [22:0] RoundM ;				// The final rounded sum
	wire [8:0] RoundE ;				// Rounded exponent (note extra bit due to poential overflow	)
	wire RoundUp ;						// Flag indicating that the sum should be rounded up
	wire ExpAdd ;						// May have to add 1 to compensate for overflow 
	wire RoundOF ;						// Rounding overflow
	wire FSgn;
	// The cases where we need to round upwards (= adding one) in Round to nearest, tie to even
	assign RoundUp = (G & ((R | S) | NormM[0])) ;
	
	// Note that in the other cases (rounding down), the sum is already 'rounded'
	assign RoundUpM = (NormM + 1) ;								// The sum, rounded up by 1
	assign RoundM = (RoundUp ? RoundUpM[22:0] : NormM) ; 	// Compute final mantissa	
	assign RoundOF = RoundUp & RoundUpM[23] ; 				// Check for overflow when rounding up

	// Calculate post-rounding exponent
	assign ExpAdd = (RoundOF ? 1'b1 : 1'b0) ; 				// Add 1 to exponent to compensate for overflow
	assign RoundE = ZeroSum ? 8'b00000000 : (NormE + ExpAdd) ; 							// Final exponent

	// If zero, need to determine sign according to rounding
	assign FSgn = (ZeroSum & (Sa ^ Sb)) | (ZeroSum ? (Sa & Sb & ~Ctrl) : ((~MaxAB & Sa) | ((Ctrl ^ Sb) & (MaxAB | Sa)))) ;

	// Assign final result
	assign Z = {FSgn, RoundE[7:0], RoundM[22:0]} ;
	
	// Indicate exponent overflow
	assign EOF = RoundE[8];

/////////////////////////////////////////////////////////////////////////////////////////////////////////



	
	// Internal signals
	wire Overflow ;					// Overflow flag
	wire Underflow ;					// Underflow flag
	wire DivideByZero ;				// Divide-by-Zero flag (always 0 in Add/Sub)
	wire Invalid ;						// Invalid inputs or result
	wire Inexact ;						// Result is inexact because of rounding
	
	// Exception flags
	
	// Result is too big to be represented
	assign Overflow = EOF | InputExc[1] | InputExc[0] ;
	
	// Result is too small to be represented
	assign Underflow = NegE & (R | S);
	
	// Infinite result computed exactly from finite operands
	assign DivideByZero = &(Z[30:23]) & ~|(Z[30:23]) & ~InputExc[1] & ~InputExc[0];
	
	// Invalid inputs or operation
	assign Invalid = |(InputExc[4:2]) ;
	
	// Inexact answer due to rounding, overflow or underflow
	assign Inexact = (R | S) | Overflow | Underflow;
	
	// Put pieces together to form final result
	assign P = Z ;
	
	// Collect exception flags	
	assign Flags = {Overflow, Underflow, DivideByZero, Invalid, Inexact} ; 	
	
endmodule
`endif

