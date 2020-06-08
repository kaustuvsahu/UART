`timescale 1ns / 1ps
module uart_tb;
  parameter CLOCK_PERIOD_NS = 1000;
  parameter CLKS_PER_BIT    = 104;//(Clock Frequency/Baud Rate)
  
	// Inputs
	reg Master_Clk=0;
	reg tx_datavalid=0;
	reg [7:0] Tx_Byte=0;
    
	// Outputs
	wire Tx_Complete;
	wire [7:0] Rx_Byte;
   wire Tx_active;
   wire Rx_DataValid;
   wire Serial_Data;	
	
	UART_Receiver #(.Clk_per_bit(CLKS_PER_BIT)) UART_RX_INST (
		.Master_Clk(Master_Clk), 
		.Serial_Data(Serial_Data), 
		.Rx_DataValid(Rx_DataValid), 
		.Rx_Byte(Rx_Byte)
	);
	UART_Transmitter #(.Clk_per_bit(CLKS_PER_BIT)) UART_TX_INST
    (.MasterClk(Master_Clk),
     .tx_datavalid(tx_datavalid),
     .Byte_to_transmit(Tx_Byte),
     .tx_active(Tx_active),
     .Serial_Data(Serial_Data),
     .tx_complete(Tx_Complete)
     );
   always
    #(CLOCK_PERIOD_NS/2) Master_Clk <= !Master_Clk;
	initial begin
		// Initialize Inputs
		@(posedge Master_Clk)
      @(posedge Master_Clk)
      tx_datavalid <= 1'b1;
      Tx_Byte<= 8'hAB;
		@(posedge Master_Clk)
		tx_datavalid <= 1'b0;
		
      @(posedge Tx_Complete)
		if (Rx_Byte == 8'hAB)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
       
          
	end
      
endmodule

