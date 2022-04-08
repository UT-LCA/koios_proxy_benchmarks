module adder_tree_2stage_4bit (clk,reset,inp00,inp01,inp10,inp11,sum_out); 

input clk; 
input reset; 
input [3:0] inp00; 
input [3:0] inp01;
input [3:0] inp10; 
input [3:0] inp11;
output reg [7:0] sum_out;

reg [4:0] S_0_0; 
reg [4:0] S_0_1; 

always@(posedge clk) begin 

S_0_0 <= inp00 + inp01; 
S_0_1 <= inp10 + inp11; 

end

always@(posedge clk) begin 

  if (reset == 1'b1) begin 
    sum_out <= 8'd0; 
  end
  else begin 
    sum_out <= S_0_0 + S_0_1; 
  end

end 

endmodule
