module adder_tree_1stage_8bit(clk,reset,inp00,inp01,sum_out); 

input clk; 
input reset; 
input [7:0] inp00; 
input [7:0] inp01;
output reg [15:0] sum_out; 

always@(posedge clk) begin 

  if (reset == 1'b1) begin 
    sum_out <= 16'd0; 
  end
  else begin 
    sum_out <= inp00 + inp01; 
  end

end 

endmodule
