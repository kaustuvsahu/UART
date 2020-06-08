`timescale 1ns / 1ps
module UART_Transmitter
#(parameter Clk_per_bit=32)
(
input MasterClk,
input tx_datavalid,
input [7:0] Byte_to_transmit,
output tx_active,
output reg Serial_Data,
output tx_complete
    );
parameter idle_state=3'b000;
parameter start_state=3'b001;
parameter tx_data_state=3'b010;
parameter stop_state=3'b011;
parameter resync_state=3'b100;
reg temp_tx_active=0;
reg [7:0] tx_data=0;
reg [2:0] current_state=0;
reg temp_tx_complete=0;
reg [7:0] Clk_Counter=0;
reg [2:0] index=0;
always @(posedge MasterClk)
begin
	case(current_state)
		idle_state:
			begin	
				temp_tx_active<=0;
				Serial_Data<=1'b1;
				Clk_Counter<=0;
				temp_tx_complete<=0;
				index<=0;
				if(tx_datavalid==1'b1)
					begin
						temp_tx_active<=1'b1;
						current_state<=start_state;
						tx_data<=Byte_to_transmit;
					end
				else
					current_state<=idle_state;
			end
		start_state:
			begin
				Serial_Data<=1'b0;
					if(Clk_Counter<Clk_per_bit-1)
						begin
							Clk_Counter<=Clk_Counter+1;
							current_state<=start_state;
						end
					else
						begin
							Clk_Counter<=0;
							current_state<=tx_data_state;
						end
			end
		tx_data_state:
			begin
				Serial_Data<=tx_data[index];
				if(Clk_Counter<Clk_per_bit-1)
					begin
							Clk_Counter<=Clk_Counter+1;
							current_state<=tx_data_state;
					end
				else
					begin
						Clk_Counter<=0;
						if(index<7)
							begin
								index<=index+1;
								current_state<=tx_data_state;
							end
						else
							begin
								index<=0;
								current_state<=stop_state;
							end
					end
			end
		stop_state:
			begin
				Serial_Data<=1'b1;
				if(Clk_Counter<Clk_per_bit-1)
						begin
							Clk_Counter<=Clk_Counter+1;
							current_state<=stop_state;
						end
				else
					begin
						temp_tx_complete<=1'b1;
						Clk_Counter<=0;
						temp_tx_active<=1'b0;
						current_state<=resync_state;
					end
			end
		resync_state:
			begin	
				temp_tx_complete<=1'b1;
				current_state<=idle_state;
			end
		default:
			current_state<=idle_state;
	endcase
end
assign tx_active=temp_tx_active;
assign tx_complete=temp_tx_complete;
endmodule
