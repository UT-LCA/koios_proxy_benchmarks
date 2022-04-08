module tpu_top#(
	parameter ARRAY_SIZE = 8,
	parameter SRAM_DATA_WIDTH = 32,
	parameter DATA_WIDTH = 8,
	parameter OUTPUT_DATA_WIDTH = 16
)
(
	input clk,
	input srstn,
	input tpu_start,

	//input data for (data, weight) from eight SRAM
	input [SRAM_DATA_WIDTH-1:0] sram_rdata_w0,
	input [SRAM_DATA_WIDTH-1:0] sram_rdata_w1,
	
	input [SRAM_DATA_WIDTH-1:0] sram_rdata_d0,
	input [SRAM_DATA_WIDTH-1:0] sram_rdata_d1,

	//output addr for (data, weight) from eight SRAM
	output [9:0] sram_raddr_w0,
	output [9:0] sram_raddr_w1,

	output [9:0] sram_raddr_d0,
	output [9:0] sram_raddr_d1,
	
	//write to three SRAN for comparison
	output sram_write_enable_a0,
	output [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_a,
	output [5:0] sram_waddr_a,

	output sram_write_enable_b0,
	output [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_b,
	output [5:0] sram_waddr_b,

	output sram_write_enable_c0,
	output [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_c,
	output [5:0] sram_waddr_c,
	
	output tpu_done
);
localparam ORI_WIDTH = DATA_WIDTH+DATA_WIDTH+5;

//----addr_sel parameter----
wire [6:0] addr_serial_num;

//----quantized parameter----
wire signed [ARRAY_SIZE*ORI_WIDTH-1:0] ori_data;
wire signed [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] quantized_data;

//-----systolic parameter----
wire alu_start;
wire [8:0] cycle_num;
wire [5:0] matrix_index;

//----ststolic_controll parameter---
wire sram_write_enable;
wire [1:0] data_set;

//----write_out parameter----
// nothing XD



//----addr_sel module----
addr_sel addr_sel 
(
	//input
	.clk(clk),
	.addr_serial_num(addr_serial_num),	

	//output
	.sram_raddr_w0(sram_raddr_w0),
	.sram_raddr_w1(sram_raddr_w1),

	.sram_raddr_d0(sram_raddr_d0),
	.sram_raddr_d1(sram_raddr_d1)
);

//----quantize module----
quantize #(
	.ARRAY_SIZE(ARRAY_SIZE),
	.SRAM_DATA_WIDTH(SRAM_DATA_WIDTH),
	.DATA_WIDTH(DATA_WIDTH),
	.OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
) quantize
(
	//input
	.ori_data(ori_data),

	//output
	.quantized_data(quantized_data)	
);

//----systolic module----
systolic #(
	.ARRAY_SIZE(ARRAY_SIZE),
	.SRAM_DATA_WIDTH(SRAM_DATA_WIDTH),
	.DATA_WIDTH(DATA_WIDTH)
) systolic
(
	//input
	.clk(clk),
	.srstn(srstn),
	.alu_start(alu_start),
	.cycle_num(cycle_num),

	.sram_rdata_w0(sram_rdata_w0),
	.sram_rdata_w1(sram_rdata_w1),
		
	.sram_rdata_d0(sram_rdata_d0),
	.sram_rdata_d1(sram_rdata_d1),

	.matrix_index(matrix_index),
	
	//output
	.mul_outcome(ori_data)
);

//----systolic_controller module----
systolic_controll  #(
	.ARRAY_SIZE(ARRAY_SIZE)
) systolic_controll
(
	//input
	.clk(clk),
	.srstn(srstn),
	.tpu_start(tpu_start),

	//output
	.sram_write_enable(sram_write_enable),
	.addr_serial_num(addr_serial_num),
	.alu_start(alu_start),
	.cycle_num(cycle_num),
	.matrix_index(matrix_index),
	.data_set(data_set),
	.tpu_done(tpu_done)
);

//----write_out module----
write_out #(
	.ARRAY_SIZE(ARRAY_SIZE),
	.OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
) write_out
(
	//input
	.clk(clk), 
	.srstn(srstn),
	.sram_write_enable(sram_write_enable),
	.data_set(data_set),
	.matrix_index(matrix_index),
	.quantized_data(quantized_data),

	//output
	.sram_write_enable_a0(sram_write_enable_a0),
	.sram_wdata_a(sram_wdata_a),
	.sram_waddr_a(sram_waddr_a),

	.sram_write_enable_b0(sram_write_enable_b0),
	.sram_wdata_b(sram_wdata_b),
	.sram_waddr_b(sram_waddr_b),

	.sram_write_enable_c0(sram_write_enable_c0),
	.sram_wdata_c(sram_wdata_c),
	.sram_waddr_c(sram_waddr_c)
);

endmodule


//----for systolic array, we have 32x32 output, 32x32 weight buffer, 32x32
//data buffer

module systolic#(
	parameter ARRAY_SIZE = 8,
	parameter SRAM_DATA_WIDTH = 32,
	parameter DATA_WIDTH = 8
)
(
	input clk,
	input srstn,
	input alu_start,												//enable signal, can start do mul and add plus shift
	input [8:0] cycle_num,
	//input pos_table [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1],

	input [SRAM_DATA_WIDTH-1:0] sram_rdata_w0,		//32 weight queue
	input [SRAM_DATA_WIDTH-1:0] sram_rdata_w1,

	input [SRAM_DATA_WIDTH-1:0] sram_rdata_d0,		//32 data queue
	input [SRAM_DATA_WIDTH-1:0] sram_rdata_d1,

	input [5:0] matrix_index,
	output reg signed [(ARRAY_SIZE*(DATA_WIDTH+DATA_WIDTH+5))-1:0] mul_outcome
);

localparam FIRST_OUT = ARRAY_SIZE+1;
localparam PARALLEL_START = ARRAY_SIZE+ARRAY_SIZE+1;
localparam OUTCOME_WIDTH = DATA_WIDTH+DATA_WIDTH+5;

reg signed [OUTCOME_WIDTH-1:0] matrix_mul_2D [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1]; 		
reg signed [OUTCOME_WIDTH-1:0] matrix_mul_2D_nx [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1]; 		
reg signed [DATA_WIDTH-1:0] data_queue [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1];
reg signed [DATA_WIDTH-1:0] weight_queue [0:ARRAY_SIZE-1] [0:ARRAY_SIZE-1];

reg signed [DATA_WIDTH+DATA_WIDTH-1:0] mul_result;

reg [5:0] upper_bound;
reg [5:0] lower_bound;

integer i,j;


//------data, weight------
always@(posedge clk) begin
	if(~srstn) begin
		for(i=0; i<ARRAY_SIZE; i=i+1) begin
			for(j=0; j<ARRAY_SIZE; j=j+1) begin
				weight_queue[i][j] <= 0;
				data_queue[i][j]   <= 0;
			end
		end
	end
	else begin
		if(alu_start) begin
			//weight shifting(a0)
			for(i=0; i<4; i=i+1) begin
				weight_queue[0][i] <= sram_rdata_w0[31-8*i-:8];
				weight_queue[0][i+4] <= sram_rdata_w1[31-8*i-:8];
			end
			
			for(i=1; i<ARRAY_SIZE; i=i+1) 
				for(j=0; j<ARRAY_SIZE; j=j+1) 
					weight_queue[i][j] <= weight_queue[i-1][j];
				
			//data shifting(b0)
			for(i=0; i<4; i=i+1) begin
				data_queue[i][0] <= sram_rdata_d0[31-8*i-:8];
				data_queue[i+4][0] <= sram_rdata_d1[31-8*i-:8];
			end
			
			for(i=0; i<ARRAY_SIZE; i=i+1) 
				for(j=1; j<ARRAY_SIZE; j=j+1) 
					data_queue[i][j] <= data_queue[i][j-1];
		end
	end
end

//-------multiplication unit------------
always@(posedge clk) begin
	if(~srstn) begin
		for(i=0; i<ARRAY_SIZE; i=i+1) 
			for(j=0; j<ARRAY_SIZE; j=j+1)  
				matrix_mul_2D[i][j] <= 0;
	end
	else begin
		for(i=0; i<ARRAY_SIZE; i=i+1) 
			for(j=0; j<ARRAY_SIZE; j=j+1) 
				matrix_mul_2D[i][j] <= matrix_mul_2D_nx[i][j];
	end
end

always@(*) begin
	if(alu_start) begin			//based on the mul_row_num, decode how many row operations need to do
		for(i=0; i<ARRAY_SIZE; i=i+1) begin
			for(j=0; j<ARRAY_SIZE; j=j+1) begin
				//multiplication and adding
				if( (cycle_num>=FIRST_OUT && (i+j)==(cycle_num-FIRST_OUT)%16) || (cycle_num >=PARALLEL_START && (i+j)==(cycle_num-PARALLEL_START)%16) ) begin
					mul_result = weight_queue[i][j] * data_queue[i][j];
					matrix_mul_2D_nx[i][j] =  { {5{mul_result[15]}} , mul_result };
				end
				else if( cycle_num>=1 && i+j<=(cycle_num-1) ) begin
					mul_result = weight_queue[i][j] * data_queue[i][j];
					matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j] + { {5{mul_result[15]}} , mul_result };
				end
				else begin
				 	mul_result = 0;	
					matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j];
				end
			end
		end
	end
	else begin
		mul_result = 0;
		for(i=0; i<ARRAY_SIZE; i=i+1) 
			for(j=0; j<ARRAY_SIZE; j=j+1) 
				matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j];
	end		
end

//------output data: mul_outcome(indexed by matrix_index)------
always@(*) begin	
	if(matrix_index < ARRAY_SIZE) begin
		upper_bound = matrix_index;
		lower_bound = matrix_index + ARRAY_SIZE;
	end
	else begin
		upper_bound = matrix_index - ARRAY_SIZE;
		lower_bound = matrix_index;
	end


	//initialization
	for(i=0; i<ARRAY_SIZE*OUTCOME_WIDTH; i=i+1)
		mul_outcome[i] = 0;

	//fetch data
	for(i=0; i<ARRAY_SIZE; i=i+1) begin
		for(j=0; j<ARRAY_SIZE-i; j=j+1) begin
			if(i+j == upper_bound)
				mul_outcome[i*OUTCOME_WIDTH+:OUTCOME_WIDTH] = matrix_mul_2D[i][j];
		end
	end

	for(i=1; i<ARRAY_SIZE; i=i+1) begin
		for(j=ARRAY_SIZE-i; j<ARRAY_SIZE; j=j+1) begin
			if(i+j == lower_bound)
				mul_outcome[i*OUTCOME_WIDTH+:OUTCOME_WIDTH] = matrix_mul_2D[i][j];
		end
	end

end

endmodule

//-----controller for systolic array----

module systolic_controll#(
	parameter ARRAY_SIZE = 8
)
(
	input clk,
	input srstn,
	input tpu_start,																//total enable signal
	
	output reg sram_write_enable,

	//addr_sel
	output reg [6:0] addr_serial_num,

	//systolic array
	output reg alu_start,																//shift & multiplcation start
	output reg [8:0] cycle_num,													//for systolic.v
	output reg [5:0] matrix_index,													//index for write-out SRAM data
	output reg [1:0] data_set,

	output reg tpu_done														//done signal
);

localparam IDLE = 3'd0, LOAD_DATA = 3'd1, WAIT1 = 3'd2, ROLLING = 3'd3;

//----general variable----
reg [2:0] state;
reg [2:0] state_nx;

reg [1:0] data_set_nx;

reg tpu_done_nx;

//----addr_sel----
reg [6:0] addr_serial_num_nx;

//----systolic array----
reg [8:0] cycle_num_nx;
reg [5:0] matrix_index_nx;

//----initialization----
always@(posedge clk) begin
	if(~srstn) begin
		state <= IDLE;
		data_set <= 0;
		cycle_num <= 0;
		matrix_index <= 0;
		addr_serial_num <= 0;
		tpu_done <= 0;
	end
	else begin
		state <= state_nx;
		data_set <= data_set_nx;
		cycle_num <= cycle_num_nx;
		matrix_index <= matrix_index_nx;
		addr_serial_num <= addr_serial_num_nx;
		tpu_done <= tpu_done_nx;
	end
end

//----state transition, tpu_done signal----
always@(*) begin
	case(state) 
		IDLE:	 begin
			if(tpu_start)
				state_nx = LOAD_DATA;
			else
				state_nx = IDLE;
			tpu_done_nx = 0;
		end

		LOAD_DATA: begin
			state_nx = WAIT1;
			tpu_done_nx = 0;
		end

		WAIT1: begin
			state_nx = ROLLING;
			tpu_done_nx = 0;
		end

		ROLLING: begin
			if(matrix_index==15 && data_set == 1) begin
				state_nx = IDLE;
				tpu_done_nx = 1;
			end
			else begin
				state_nx = ROLLING;
				tpu_done_nx = 0;
			end
		end

		default: begin
			state_nx = IDLE;
			tpu_done_nx = 0;
		end
	endcase
end

//-----addr_sel: addr_serial_num-----
always@(*) begin
	case(state)
		IDLE: begin
			if(tpu_start)
				addr_serial_num_nx = 0;
			else
				addr_serial_num_nx = addr_serial_num;
		end

		LOAD_DATA:
			addr_serial_num_nx = 1;

		WAIT1: 
			addr_serial_num_nx = 2;

		ROLLING: begin
			if(addr_serial_num == 127)
				addr_serial_num_nx = addr_serial_num;
			else
				addr_serial_num_nx = addr_serial_num + 1;
		end

		default:
			addr_serial_num_nx = 0;
	endcase
end

//------systolic: alu_start, cycle_num, matrix_index, data_set,
//sram_write_enable------
always@(*) begin
	case(state)
		IDLE: begin
			alu_start = 0;
			cycle_num_nx = 0;
			matrix_index_nx = 0;
			data_set_nx = 0;
			sram_write_enable = 0;
		end

		LOAD_DATA: begin
			alu_start = 0;
			cycle_num_nx = 0;
			matrix_index_nx = 0;
			data_set_nx = 0;
			sram_write_enable = 0;
		end

		WAIT1: begin
			alu_start = 0;
			cycle_num_nx = 0;
			matrix_index_nx = 0;
			data_set_nx = 0;
			sram_write_enable = 0;
		end

		ROLLING: begin
			alu_start = 1;
			cycle_num_nx = cycle_num + 1;
			if(cycle_num >= ARRAY_SIZE+1) begin
				if(matrix_index == 15) begin
					matrix_index_nx = 0;
					data_set_nx = data_set + 1;
				end
				else begin
					matrix_index_nx = matrix_index + 1;
					data_set_nx = data_set;
				end
				sram_write_enable = 1;
			end
			else begin
				matrix_index_nx = 0;
				data_set_nx = data_set;
				sram_write_enable = 0;
			end
		end

		default: begin
			alu_start = 0;
			cycle_num_nx = 0;
			matrix_index_nx = 0;
			data_set_nx = 0;
			sram_write_enable = 0;
		end
		
	endcase
end

endmodule

//-------do the address select for 32 queue, each queue size 32+32-1---


module addr_sel
(
	input clk,
	input [6:0] addr_serial_num,							//max = 126, setting all of the addr127 = 0
	
	//sel for w0~w7
	output reg [9:0] sram_raddr_w0,			//queue 0~3
	output reg [9:0] sram_raddr_w1,			//queue 4~7

	//sel for d0~d7
	output reg [9:0] sram_raddr_d0,
	output reg [9:0] sram_raddr_d1
);

wire [9:0] sram_raddr_w0_nx;			//queue 0~3
wire [9:0] sram_raddr_w1_nx;			//queue 4~7

//sel for d0~d7
wire [9:0] sram_raddr_d0_nx;
wire [9:0] sram_raddr_d1_nx;

always@(posedge clk) begin				//fit in output flip-flop
	sram_raddr_w0 <= sram_raddr_w0_nx;
	sram_raddr_w1 <= sram_raddr_w1_nx;

	sram_raddr_d0 <= sram_raddr_d0_nx;
	sram_raddr_d1 <= sram_raddr_d1_nx;
end

assign sram_raddr_w0_nx = (addr_serial_num<=98)? { {3{1'd0}} , addr_serial_num} : 127;
assign sram_raddr_w1_nx = (addr_serial_num>=4 && addr_serial_num<=102)? { {3{1'd0}} , addr_serial_num-7'd4} : 127;

assign sram_raddr_d0_nx = (addr_serial_num<=98)? { {3{1'd0}} , addr_serial_num} : 127;
assign sram_raddr_d1_nx = (addr_serial_num>=4 && addr_serial_num<=102)? { {3{1'd0}} , addr_serial_num-7'd4} : 127;


endmodule

//-------ori data is from systolic array, output to quantized data-------

module quantize#(
	parameter ARRAY_SIZE = 8,
	parameter SRAM_DATA_WIDTH = 32,
	parameter DATA_WIDTH = 8,
	parameter OUTPUT_DATA_WIDTH = 16
)
(
	input signed [ARRAY_SIZE*(DATA_WIDTH+DATA_WIDTH+5)-1:0] ori_data,
	output reg signed [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] quantized_data
);

localparam max_val = 32767,min_val = -32768;
localparam ORI_WIDTH = DATA_WIDTH+DATA_WIDTH+5;

reg signed [ORI_WIDTH-1:0] ori_shifted_data;

integer i;

//quantize the data from 32 bit(16: integer, 8: precision) to 16 bit(8: integer, 8: precision)
always@* begin
	for(i=0; i<ARRAY_SIZE; i=i+1) begin
		ori_shifted_data = ori_data[i*ORI_WIDTH +: ORI_WIDTH];
		if(ori_shifted_data >= max_val) quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = max_val;
		else if(ori_shifted_data <= min_val) quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = min_val;
		else quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = ori_shifted_data[OUTPUT_DATA_WIDTH-1:0];
	end
end

endmodule

//-----this module is for weiting data out------

module write_out#(
	parameter ARRAY_SIZE = 8,
	parameter OUTPUT_DATA_WIDTH = 16
)
(
	input clk,
	input srstn,
	input sram_write_enable,

	input [1:0] data_set,
	input [5:0] matrix_index,

	input signed [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] quantized_data,

	output reg sram_write_enable_a0,
	output reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_a,
 	output reg [5:0] sram_waddr_a,

	output reg sram_write_enable_b0,
	output reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_b,
 	output reg [5:0] sram_waddr_b,

	output reg sram_write_enable_c0,
	output reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_c,
 	output reg [5:0] sram_waddr_c
);

integer i;
localparam MAX_INDEX = ARRAY_SIZE - 1;

//output flip-flop
reg sram_write_enable_a0_nx;
reg sram_write_enable_b0_nx;
reg sram_write_enable_c0_nx;

reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_a_nx;
reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_b_nx;
reg [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_c_nx;

reg [5:0] sram_waddr_a_nx;
reg [5:0] sram_waddr_b_nx;
reg [5:0] sram_waddr_c_nx;

//---sequential logic-----
always@(posedge clk) begin
	if(~srstn) begin
		sram_write_enable_a0 <= 1;
		sram_write_enable_b0 <= 1;
		sram_write_enable_c0 <= 1;

		sram_wdata_a <= 0;
		sram_wdata_b <= 0;
		sram_wdata_c <= 0;

		sram_waddr_a <= 0;
		sram_waddr_b <= 0;
		sram_waddr_c <= 0;
	end
	else begin
		sram_write_enable_a0 <= sram_write_enable_a0_nx;
		sram_write_enable_b0 <= sram_write_enable_b0_nx;
		sram_write_enable_c0 <= sram_write_enable_c0_nx;

		sram_wdata_a <= sram_wdata_a_nx;
		sram_wdata_b <= sram_wdata_b_nx;
		sram_wdata_c <= sram_wdata_c_nx;

		sram_waddr_a <= sram_waddr_a_nx;
		sram_waddr_b <= sram_waddr_b_nx;
		sram_waddr_c <= sram_waddr_c_nx;
	end
end


//for a0, write_enable_X0 = 0 means write
always@(*) begin
	if(sram_write_enable) begin
		case(data_set)
			0: begin
				if(matrix_index < ARRAY_SIZE) begin
					sram_write_enable_a0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i<=matrix_index)
							sram_wdata_a_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_a_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_a_nx = matrix_index;
				end
				else begin							//mix type
					sram_write_enable_a0_nx = 0;
				 	for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i < 15-matrix_index)
							sram_wdata_a_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[(i+1+(matrix_index-ARRAY_SIZE))*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_a_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_a_nx = matrix_index;
				end
			end

			default: begin
				sram_write_enable_a0_nx = 1;
				for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
					sram_wdata_a_nx[i] = 0;
				sram_waddr_a_nx = 0;
			end
		endcase
	end
	else begin
		sram_write_enable_a0_nx = 1;
		for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
			sram_wdata_a_nx[i] = 0;
		sram_waddr_a_nx = 0;
	end
end

//for b0, write_enable_X0 = 0 means write
always@(*) begin
	if(sram_write_enable) begin
		case(data_set)
			0: begin
				if(matrix_index < ARRAY_SIZE) begin			//all occupied by a
					sram_write_enable_b0_nx = 1;
					for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
						sram_wdata_b_nx[i] = 0;
					sram_waddr_b_nx = 0;
				end
				else begin														//mix type
					sram_write_enable_b0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i <= matrix_index-ARRAY_SIZE)
							sram_wdata_b_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_b_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_b_nx = matrix_index - ARRAY_SIZE;
				end
			end

			1: begin
				if(matrix_index < ARRAY_SIZE) begin
					sram_write_enable_b0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i < ARRAY_SIZE-matrix_index-1)
							sram_wdata_b_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[(i+1+matrix_index)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_b_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_b_nx = matrix_index + ARRAY_SIZE;
				end
				else begin
					sram_write_enable_b0_nx = 1;
					for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
						sram_wdata_b_nx[i] = 0;
					sram_waddr_b_nx = 0;
				end
			end

			default: begin
				sram_write_enable_b0_nx = 1;
				for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
					sram_wdata_b_nx[i] = 0;
				sram_waddr_b_nx = 0;
			end
		endcase
	end
	else begin
		sram_write_enable_b0_nx = 1;
		for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
			sram_wdata_b_nx[i] = 0;
		sram_waddr_b_nx = 0;
	end
end

//for c0, write_enable_X0 = 0 means write
always@(*) begin
	if(sram_write_enable) begin
		case(data_set)
			1: begin
				if(matrix_index < ARRAY_SIZE) begin			//all occupied by a
					sram_write_enable_c0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i<=matrix_index)
							sram_wdata_c_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_c_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_c_nx = matrix_index;
				end
				else begin														//mix type
					sram_write_enable_c0_nx = 0;
					for(i=0; i<ARRAY_SIZE; i=i+1) begin
						if(i < 15-matrix_index)
							sram_wdata_c_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = quantized_data[(i+1+(matrix_index-ARRAY_SIZE))*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
						else
							sram_wdata_c_nx[(MAX_INDEX-i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = 0;
					end
					sram_waddr_c_nx = matrix_index;
				end
			end

			default: begin
				sram_write_enable_c0_nx = 1;
				for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
					sram_wdata_c_nx[i] = 0;
				sram_waddr_c_nx = 0;
			end
		endcase
	end
	else begin
		sram_write_enable_c0_nx = 1;
		for(i=0; i<ARRAY_SIZE*OUTPUT_DATA_WIDTH; i=i+1)
			sram_wdata_c_nx[i] = 0;
		sram_waddr_c_nx = 0;
	end
end

endmodule


