module xor_module (input clk, input reset, input i1, input i2, output reg o);

always@(posedge clk) begin 
o <= i1^i2; 
end 

endmodule
