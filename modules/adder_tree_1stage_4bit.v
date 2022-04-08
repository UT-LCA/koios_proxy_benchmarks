module adder_tree_1stage_4bit(clk,reset,inp00,inp01,sum_out); 

input clk; 
input reset; 
input [3:0] inp00; 
input [3:0] inp01;
output reg [7:0] sum_out; 

always@(posedge clk) begin 

  if (reset == 1'b1) begin 
    sum_out <= 8'd0; 
  end
  else begin 
    sum_out <= inp00 + inp01; 
  end

end 

endmodule
