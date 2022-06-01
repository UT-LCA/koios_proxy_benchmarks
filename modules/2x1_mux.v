module mux_module (input clk, input reset, input i1, input i2, output reg o, input sel);

always@(posedge clk) begin 
if (reset ==1'b1) begin 
	o<= 1'b0; 
end

else begin
	if (sel == 1'b0) begin 
		o <= i1;
	end
	else begin
		o <= i2; 
	end 
end 

end

endmodule

