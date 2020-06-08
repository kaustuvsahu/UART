`timescale 1ns / 1ps
module UART_Receiver
  #(parameter Clk_per_bit=32)
  (input Master_Clk,
   input Serial_Data,
   output Rx_DataValid,
   output [7:0] Rx_Byte
  );
  parameter idle_state=3'b000;
  parameter start_bit_state=3'b001;
  parameter data_bit_state=3'b010;
  parameter stop_bit_state=3'b011;
  parameter resync_state=3'b100;
  reg rx_bit=1'b1;
  reg rx_bit_copy=1'b1;
  reg [7:0] Clk_Counter=0;
  reg temp_Rx_DataValid=0;
  reg [2:0] Current_State=0;
  reg [2:0] index=0;
  reg [7:0] temp_rx_data=0;
  always @(posedge Master_Clk)
    begin
      rx_bit_copy<=Serial_Data;
      rx_bit<=rx_bit_copy;
    end
  always @(posedge Master_Clk)
    begin
      case (Current_State)
        idle_state:
          begin
            temp_Rx_DataValid<=1'b0;
            Clk_Counter<=0;
            index<=0;
            if(rx_bit==1'b0)
              Current_State<=start_bit_state;
            else
              Current_State<=idle_state;
          end
        start_bit_state:
          begin
            if(Clk_Counter== ((Clk_per_bit-1)/2))
              begin
                if(rx_bit==1'b0)
                  begin
                    Clk_Counter<=0;
                    Current_State<=data_bit_state;
                  end
                else
                  Current_State<=idle_state;
              end
            else
              begin
                Clk_Counter<=Clk_Counter+1;
                Current_State<=start_bit_state;
              end
          end
        data_bit_state:
          begin
            if(Clk_Counter<Clk_per_bit-1)
              begin
                Clk_Counter<=Clk_Counter+1;
                Current_State<=data_bit_state;
              end
            else
              begin
                Clk_Counter<=0;
                temp_rx_data[index]<=rx_bit;
                if(index<7)
                  begin
                    index<=index+1;
                    Current_State<=data_bit_state;
                  end
                else
                  begin
                    index<=0;
                    Current_State<=stop_bit_state;
                  end
              end
          end
        stop_bit_state:
          begin
            if(Clk_Counter<Clk_per_bit-1)
              begin
                Clk_Counter<=Clk_Counter+1;
                Current_State<=stop_bit_state;
              end
            else
              begin
                Clk_Counter<=0;
                temp_Rx_DataValid<=1'b1;
                Current_State<=resync_state;
              end
          end			 
        resync_state:
          begin
            Current_State<=idle_state;
            Clk_Counter<=0;
            temp_Rx_DataValid<=1'b0;
          end
        default:
          Current_State<=idle_state;

      endcase
    end
assign Rx_Byte = temp_rx_data;
assign Rx_DataValid = temp_Rx_DataValid;
endmodule
