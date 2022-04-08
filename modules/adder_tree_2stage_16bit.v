module adder_tree_2stage_16bit (clk,reset,inp00,inp01,inp10,inp11,sum_out); 

input clk; 
input reset; 
input [15:0] inp00; 
input [15:0] inp01;
input [15:0] inp10; 
input [15:0] inp11;
output reg [31:0] sum_out;

reg [16:0] S_0_0; 
reg [16:0] S_0_1; 

always@(posedge clk) begin 

S_0_0 <= inp00 + inp01; 
S_0_1 <= inp10 + inp11; 

end

always@(posedge clk) begin 

  if (reset == 1'b1) begin 
    sum_out <= 32'd0; 
  end
  else begin 
    sum_out <= S_0_0 + S_0_1; 
  end

end 

endmodule
