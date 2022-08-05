`ifdef complex_dsp
module fp16_sop2_mult_dspchain (clk,reset,top_a,top_b,bot_a,bot_b,fp32_in,mode_sigs,chainin,chainout,result);
input clk; 
input reset;
input [10:0] mode_sigs; 
input [15:0] top_a,top_b,bot_a,bot_b;
input [31:0] chainin,fp32_in; 
output [31:0] chainout, result;

fp16_sop2_mult inst1(.clk(clk),.reset(reset),.top_a(top_a),.top_b(top_b),.bot_a(bot_a),.bot_b(bot_b),.fp32_in(fp32_in),.mode_sigs(mode_sigs),.chainin(chainin),.chainout(chainout),.result(result)); 

endmodule

`else
module fp16_sop2_mult_dspchain (clk,reset,top_a,top_b,bot_a,bot_b,fp32_in,mode_sigs,chainin,chainout,result);
input clk; 
input reset;
input [10:0] mode_sigs; 
input [15:0] top_a,top_b,bot_a,bot_b;
input [31:0] chainin,fp32_in; 
output [31:0] chainout, result; 

reg [15:0] top_a_reg,top_b_reg,bot_a_reg,bot_b_reg; 
reg [31:0] chainin_reg; 
wire [31:0] r1,r2,r3; 
always@(posedge clk) begin 
if(reset) begin 
top_a_reg<= 16'b0; 
top_b_reg<= 16'b0; 
bot_a_reg<= 16'b0; 
bot_b_reg<= 16'b0;
//result<=32'b0;
//chainout<=32'b0;
chainin_reg<=32'b0;   
end
else begin 
top_a_reg<=top_a; 
top_b_reg<=top_b; 
bot_a_reg<=bot_a;
bot_b_reg<=bot_b;
//chainout<=result;
chainin_reg<=chainin; 
end
end

wire [4:0] flags1,flags2,flags3,flags4; 

FPMult_16_dspchain inst1(.clk(clk),.rst(reset),.a(top_a_reg),.b(top_b_reg),.flags(flags1),.result(r1)); 
FPMult_16_dspchain inst2(.clk(clk),.rst(reset),.a(bot_a_reg),.b(bot_b_reg),.flags(flags2),.result(r2));
FPAddSub_single_dspchain inst3(.clk(clk),.rst(reset),.a(r1),.b(r2),.flags(flags3),.operation(1'b1),.result(r3));
FPAddSub_single_dspchain inst4(.clk(clk),.rst(reset),.a(r3),.b(chainin),.flags(flags4),.operation(1'b1),.result(result));
assign chainout = result; 
endmodule
//`endif

//`timescale 1ns / 1ps


// IEEE Half Precision => 5 = 5, 10 = 10



//`define IEEE_COMPLIANCE 1


//////////////////////////////////////////////////////////////////////////////////
//
// Module Name:    FPMult
//
//////////////////////////////////////////////////////////////////////////////////

module FPMult_16_dspchain(
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
	input [16-1:0] a;						// Input A, a 32-bit floating point number
	input [16-1:0] b;						// Input B, a 32-bit floating point number
	
	// Output ports
	output [32-1:0] result ;					// Product, result of the operation, 32-bit FP number
	output [4:0] flags ;						// Flags indicating exceptions according to IEEE754
	
	// Internal signals
	wire [32-1:0] Z_int ;					// Product, result of the operation, 32-bit FP number
	wire [4:0] Flags_int ;						// Flags indicating exceptions according to IEEE754
	
	wire Sa ;							// A's sign
	wire Sb ;							// B's sign
	wire Sp ;							// Product sign
	wire [5-1:0] Ea ;					// A's 5
	wire [5-1:0] Eb ;					// B's 5
	wire [2*10+1:0] Mp ;					// Product 10
	wire [4:0] InputExc ;						// Exceptions in inputs
	wire [23-1:0] NormM ;					// Normalized 10
	wire [8:0] NormE ;					// Normalized 5
	wire [23:0] RoundM ;					// Normalized 10
	wire [8:0] RoundE ;					// Normalized 5
	wire [23:0] RoundMP ;					// Normalized 10
	wire [8:0] RoundEP ;					// Normalized 5
	wire GRS ;

	//reg [63:0] pipe_0;						// Pipeline register Input->Prep
	reg [2*16-1:0] pipe_0;					// Pipeline register Input->Prep

	//reg [92:0] pipe_1;						// Pipeline register Prep->Execute
	//reg [3*10+2*5+7:0] pipe_1;			// Pipeline register Prep->Execute
	reg [3*10+2*5+18:0] pipe_1;

	//reg [38:0] pipe_2;						// Pipeline register Execute->Normalize
	reg [23+8+7:0] pipe_2;				// Pipeline register Execute->Normalize

	//reg [72:0] pipe_3;						// Pipeline register Normalize->Round
	reg [2*23+2*8+10:0] pipe_3;			// Pipeline register Normalize->Round

	//reg [36:0] pipe_4;						// Pipeline register Round->Output
	reg [32+4:0] pipe_4;					// Pipeline register Round->Output
	
	assign result = pipe_4[32+4:5] ;
	assign flags = pipe_4[4:0] ;
	
	// Prepare the operands for alignment and check for exceptions
	FPMult_PrepModule_dspchain PrepModule(clk, rst, pipe_0[2*16-1:16], pipe_0[16-1:0], Sa, Sb, Ea[5-1:0], Eb[5-1:0], Mp[2*10+1:0], InputExc[4:0]) ;

	// Perform (unsigned) 10 multiplication
	FPMult_ExecuteModule_dspchain ExecuteModule(pipe_1[3*10+5*2+7:2*10+2*5+8], pipe_1[2*10+2*5+7:2*10+7], pipe_1[2*10+6:5], pipe_1[2*10+2*5+6:2*10+5+7], pipe_1[2*10+5+6:2*10+7], pipe_1[2*10+2*5+8], pipe_1[2*10+2*5+7], Sp, NormE[8:0], NormM[23-1:0], GRS) ;

	// Round result and if necessary, perform a second (post-rounding) normalization step
	FPMult_NormalizeModule_dspchain NormalizeModule(pipe_2[23-1:0], pipe_2[23+8:23], RoundE[8:0], RoundEP[8:0], RoundM[23:0], RoundMP[23:0]) ;		

	// Round result and if necessary, perform a second (post-rounding) normalization step
	//FPMult_RoundModule RoundModule(pipe_3[47:24], pipe_3[23:0], pipe_3[65:57], pipe_3[56:48], pipe_3[66], pipe_3[67], pipe_3[72:68], Z_int[31:0], Flags_int[4:0]) ;		
	FPMult_RoundModule_dspchain RoundModule(pipe_3[2*23+1:23+1], pipe_3[23:0], pipe_3[2*8+2*23+3:2*23+8+3], pipe_3[2*23+8+2:2*23+2], pipe_3[2*23+2*8+4], pipe_3[2*23+2*8+5], pipe_3[2*23+2*8+10:2*23+2*8+6], Z_int[32-1:0], Flags_int[4:0]) ;		


//adding always@ (*) instead of posedge clock to make design combinational
	always @ (*) begin	
		if(rst) begin
			pipe_0 = 0;
			pipe_1 = 0;
			pipe_2 = 0; 
			pipe_3 = 0;
			pipe_4 = 0;
		end 
		else begin		
			/* PIPE 0
				[2*16-1:16] A
				[16-1:0] B
			*/
                       pipe_0 = {a, b} ;


			/* PIPE 1
				[2*5+3*10 + 18: 2*5+2*10 + 18] //pipe_0[16+10-1:16] , 10 of A
				[2*5+2*10 + 17 :2*5+2*10 + 9] // pipe_0[8:0]
				[2*5+2*10 + 8] Sa
				[2*5+2*10 + 7] Sb
				[2*5+2*10 + 6:5+2*10+7] Ea
				[5 +2*10+6:2*10+7] Eb
				[2*10+1+5:5] Mp
				[4:0] InputExc
			*/
			//pipe_1 <= {pipe_0[16+10-1:16], pipe_0[10_MUL_SPLIT_LSB-1:0], Sa, Sb, Ea[5-1:0], Eb[5-1:0], Mp[2*10-1:0], InputExc[4:0]} ;
			pipe_1 = {pipe_0[16+10-1:16], pipe_0[8:0], Sa, Sb, Ea[5-1:0], Eb[5-1:0], Mp[2*10+1:0], InputExc[4:0]} ;
			
			/* PIPE 2
				[8 + 23 + 7:8 + 23 + 3] InputExc
				[8 + 23 + 2] GRS
				[8 + 23 + 1] Sp
				[8 + 23:23] NormE
				[23-1:0] NormM
			*/
			pipe_2 = {pipe_1[4:0], GRS, Sp, NormE[8:0], NormM[23-1:0]} ;
			/* PIPE 3
				[2*8+2*23+10:2*8+2*23+6] InputExc
				[2*8+2*23+5] GRS
				[2*8+2*23+4] Sp	
				[2*8+2*23+3:8+2*23+3] RoundE
				[8+2*23+2:2*23+2] RoundEP
				[2*23+1:23+1] RoundM
				[23:0] RoundMP
			*/
			pipe_3 = {pipe_2[8 + 23 + 7:8 + 23 + 1], RoundE[8:0], RoundEP[8:0], RoundM[23:0], RoundMP[23:0]} ;
			/* PIPE 4
				[16+4:5] Z
				[4:0] Flags
			*/				
			pipe_4 = {Z_int[32-1:0], Flags_int[4:0]} ;
		end
	end
		
endmodule



module FPMult_PrepModule_dspchain (
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
	input [16-1:0] a ;								// Input A, a 32-bit floating point number
	input [16-1:0] b ;								// Input B, a 32-bit floating point number
	
	// Output ports
	output Sa ;										// A's sign
	output Sb ;										// B's sign
	output [5-1:0] Ea ;								// A's 5
	output [5-1:0] Eb ;								// B's 5
	output [2*10+1:0] Mp ;							// 10 product
	output [4:0] InputExc ;						// Input numbers are exceptions
	
	// Internal signals							// If signal is high...
	wire ANaN ;										// A is a signalling NaN
	wire BNaN ;										// B is a signalling NaN
	wire AInf ;										// A is infinity
	wire BInf ;										// B is infinity
    wire [10-1:0] Ma;
    wire [10-1:0] Mb;
	
	assign ANaN = &(a[16-2:10]) &  |(a[16-2:10]) ;			// All one 5 and not all zero 10 - NaN
	assign BNaN = &(b[16-2:10]) &  |(b[10-1:0]);			// All one 5 and not all zero 10 - NaN
	assign AInf = &(a[16-2:10]) & ~|(a[16-2:10]) ;		// All one 5 and all zero 10 - Infinity
	assign BInf = &(b[16-2:10]) & ~|(b[16-2:10]) ;		// All one 5 and all zero 10 - Infinity
	
	// Check for any exceptions and put all flags into exception vector
	assign InputExc = {(ANaN | BNaN | AInf | BInf), ANaN, BNaN, AInf, BInf} ;
	//assign InputExc = {(ANaN | ANaN | BNaN |BNaN), ANaN, ANaN, BNaN,BNaN} ;
	
	// Take input numbers apart
	assign Sa = a[16-1] ;							// A's sign
	assign Sb = b[16-1] ;							// B's sign
	assign Ea = a[16-2:10];						// Store A's 5 in Ea, unless A is an exception
	assign Eb = b[16-2:10];						// Store B's 5 in Eb, unless B is an exception	
//    assign Ma = a[10_MSB:10_LSB];
  //  assign Mb = b[10_MSB:10_LSB];
	

	// Actual 10 multiplication occurs here
	//assign Mp = ({4'b0001, a[10-1:0]}*{4'b0001, b[10-1:9]}) ;
	assign Mp = ({1'b1,a[10-1:0]}*{1'b1, b[10-1:0]}) ;

	
    //We multiply part of the 10 here
    //Full 10 of A
    //Bits 10_MUL_SPLIT_MSB:10_MUL_SPLIT_LSB of B
   // wire [`ACTUAL_10-1:0] inp_A;
   // wire [`ACTUAL_10-1:0] inp_B;
   // assign inp_A = {1'b1, Ma};
   // assign inp_B = {{(10-(10_MUL_SPLIT_MSB-10_MUL_SPLIT_LSB+1)){1'b0}}, 1'b1, Mb[10_MUL_SPLIT_MSB:10_MUL_SPLIT_LSB]};
   // DW02_mult #(`ACTUAL_10,`ACTUAL_10) u_mult(.A(inp_A), .B(inp_B), .TC(1'b0), .PRODUCT(Mp));
endmodule


module FPMult_ExecuteModule_dspchain(
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
	input [10-1:0] a ;
	input [2*5:0] b ;
	input [2*10+1:0] MpC ;
	input [5-1:0] Ea ;						// A's 5
	input [5-1:0] Eb ;						// B's 5
	input Sa ;								// A's sign
	input Sb ;								// B's sign
	
	// Output ports
	output Sp ;								// Product sign
	output [8:0] NormE ;													// Normalized 5
	output [23-1:0] NormM ;												// Normalized 10
	output GRS ;
	
	wire [2*10+1:0] Mp ;
	
	assign Sp = (Sa ^ Sb) ;												// Equal signs give a positive product
	
   // wire [`ACTUAL_10-1:0] inp_a;
   // wire [`ACTUAL_10-1:0] inp_b;
   // assign inp_a = {1'b1, a};
   // assign inp_b = {{(10-10_MUL_SPLIT_LSB){1'b0}}, 1'b0, b};
   // DW02_mult #(`ACTUAL_10,`ACTUAL_10) u_mult(.A(inp_a), .B(inp_b), .TC(1'b0), .PRODUCT(Mp_temp));
   // DW01_add #(2*`ACTUAL_10) u_add(.A(Mp_temp), .B(MpC<<10_MUL_SPLIT_LSB), .CI(1'b0), .SUM(Mp), .CO());

	//assign Mp = (MpC<<(2*5+1)) + ({4'b0001, a[10-1:0]}*{1'b0, b[2*5:0]}) ;
	assign Mp = MpC;


	assign NormM = (Mp[2*10+1] ? Mp[2*10:0] : Mp[2*10-1:0]); 	// Check for overflow
	assign NormE = (Ea + Eb + Mp[2*10+1]);								// If so, increment 5
	
	assign GRS = ((Mp[10]&(Mp[10+1]))|(|Mp[10-1:0])) ;
	
endmodule

module FPMult_NormalizeModule_dspchain(
		NormM,
		NormE,
		RoundE,
		RoundEP,
		RoundM,
		RoundMP
    );

	// Input Ports
	input [23-1:0] NormM ;									// Normalized 10
	input [8:0] NormE ;									// Normalized 5

	// Output Ports
	output [8:0] RoundE ;
	output [8:0] RoundEP ;
	output [23:0] RoundM ;
	output [23:0] RoundMP ; 
	
// 5 = 5 
// 5 -1 = 4
// NEED to subtract 2^4 -1 = 15

wire [8-1 : 0] bias;

assign bias =  ((1<< (8 -1)) -1);

	assign RoundE = NormE - 9'd15 - 9'd15 + 9'd127 ;
	assign RoundEP = NormE - 9'd15 - 9'd15 + 9'd127 ;
	assign RoundM = NormM ;
	assign RoundMP = NormM ;

endmodule

module FPMult_RoundModule_dspchain(
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
	input [23:0] RoundM ;									// Normalized 10
	input [23:0] RoundMP ;									// Normalized 5
	input [8:0] RoundE ;									// Normalized 10 + 1
	input [8:0] RoundEP ;									// Normalized 5 + 1
	input Sp ;												// Product sign
	input GRS ;
	input [4:0] InputExc ;
	
	// Output Ports
	output [32-1:0] Z ;										// Final product
	output [4:0] Flags ;
	
	// Internal Signals
	wire [8:0] FinalE ;									// Rounded 5
	wire [23:0] FinalM;
	wire [23:0] PreShiftM;
	
	assign PreShiftM = GRS ? RoundMP : RoundM ;	// Round up if R and (G or S)
	
	// Post rounding normalization (potential one bit shift> use shifted 10 if there is overflow)
	assign FinalM = (PreShiftM[23] ? {1'b0, PreShiftM[23:1]} : PreShiftM[23:0]) ;
	assign FinalE = (PreShiftM[23] ? RoundEP : RoundE) ; // Increment 5 if a shift was done
	
	
	assign Z = {Sp, FinalE[8-1:0], FinalM[21-1:0], 2'b0} ;   // Putting the pieces together
	assign Flags = InputExc[4:0];

endmodule


module FPAddSub_single_dspchain(
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

FPAddSub_a_dspchain M1(a,b,operation,Opout,Sa,Sb,MaxAB,CExp,Shift,Mmax,InputExc,Mmin_3);

FpAddSub_b_dspchain M2(pipe_1[51:29],pipe_1[23:0],pipe_1[67],pipe_1[66],pipe_1[65],pipe_1[68],SumS_5,Shift_1,PSgn,Opr);

FPAddSub_c_dspchain M3(pipe_2[54:22],pipe_2[21:17],pipe_2[16:9],NormM,NormE,ZeroSum,NegE,R,S,FG);

FPAddSub_d_dspchain M4(pipe_3[13],pipe_3[22:14],pipe_3[45:23],pipe_3[11],pipe_3[10],pipe_3[9],pipe_3[8],pipe_3[7],pipe_3[6],pipe_3[5],pipe_3[12],pipe_3[4:0],result,flags );


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
module FPAddSub_a_dspchain(
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

module FpAddSub_b_dspchain(
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

module FPAddSub_c_dspchain(
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

module FPAddSub_d_dspchain(
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


