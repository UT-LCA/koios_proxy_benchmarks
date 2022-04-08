module adder_tree_2stage_8bit (clk,reset,inp00,inp01,inp10,inp11,sum_out); 

input clk; 
input reset; 
input [7:0] inp00; 
input [7:0] inp01;
input [7:0] inp10; 
input [7:0] inp11;
output reg [15:0] sum_out;

reg [8:0] S_0_0; 
reg [8:0] S_0_1; 

always@(posedge clk) begin 

S_0_0 <= inp00 + inp01; 
S_0_1 <= inp10 + inp11; 

end

always@(posedge clk) begin 

  if (reset == 1'b1) begin 
    sum_out <= 16'd0; 
  end
  else begin 
    sum_out <= S_0_0 + S_0_1; 
  end

end 

endmodule
