module xor_module (input clk, input reset, input i1, input i2, output reg o);

always@(posedge clk) begin 
if (reset ==1'b1) begin 
o<= 1'b0; 
end
else begin
o <= i1^i2; 
end 
end
endmodule
