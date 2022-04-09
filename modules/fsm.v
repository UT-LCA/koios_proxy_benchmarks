module fsm(input clk, input reset, input i1, input i2, output reg o);
// mealy machine

reg [1:0] current_state; 
reg [1:0] next_state;

wire [1:0] inp; 
assign inp = {i2,i1}; 

always@(posedge clk) begin 
	if (reset == 1'b1) begin 
		current_state <= 1'b0; 
	end
	else begin 
		current_state <= next_state; 
	end
end

always@(posedge clk) begin 

	next_state = current_state; 

	case(current_state)
		2'b00:	begin 
							if(inp == 2'b00) begin 
								next_state <= 2'b00; 
								o <= 1'b0; 
							end
							if (inp == 2'b01) begin 
								next_state <= 2'b11;
								o <= 1'b1;
							end
							if(inp == 2'b10) begin
  							next_state <= 2'b01;
  							o <= 1'b0;
							end
							if(inp == 2'b11) begin
							  next_state <= 2'b10;
							  o <= 1'b0;
							end
					 	end 
		2'b01:	begin 
							if(inp == 2'b00) begin
							  next_state <= 2'b01;
							  o <= 1'b1;
							end
							if(inp == 2'b01) begin
							  next_state <= 2'b01;
							  o <= 1'b0;
							end
							if(inp == 2'b10) begin
							  next_state <= 2'b10;
							  o <= 1'b1;
							end
							if(inp == 2'b11) begin
							  next_state <= 2'b00;
							  o <= 1'b1;
							end
						end
		2'b10:	begin 
							if(inp == 2'b00) begin
							  next_state <= 2'b11;
							  o <= 1'b0;
							end
							if(inp == 2'b01) begin
							  next_state <= 2'b10;
							  o <= 1'b1;
							end
							if(inp == 2'b10) begin
							  next_state <= 2'b11;
							  o <= 1'b0;
							end
							if(inp == 2'b11) begin
							  next_state <= 2'b01;
							  o <= 1'b1;
							end
						end
		2'b11:	begin 
							if(inp == 2'b00) begin
  							next_state <= 2'b00;
							  o <= 1'b1;
							end
							if(inp == 2'b01) begin
							  next_state <= 2'b11;
							  o <= 1'b1;
							end
							if(inp == 2'b10) begin
							  next_state <= 2'b10;
							  o <= 1'b1;
							end
							if(inp == 2'b11) begin
							  next_state <= 2'b01;
							  o <= 1'b1;
							end
						end
//		defualt:	begin  
//								next_state <= 2'b00;
//								o <= 1'b0; 
//							end
	endcase
end 

endmodule 
