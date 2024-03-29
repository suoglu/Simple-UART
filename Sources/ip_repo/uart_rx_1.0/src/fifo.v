`timescale 1 ns / 1 ps
/* ----------------------------------------- *
 * Title       : FIFO Buffer                 *
 * Project     : Verilog Utility Modules     *
 * ----------------------------------------- *
 * File        : fifo.v                      *
 * Author      : Yigit Suoglu                *
 * Last Edit   : 24/10/2021                  *
 * Licence     : CERN-OHL-W                  *
 * ----------------------------------------- *
 * Description : A generic FIFO circular     *
 *               buffer                      *
 * ----------------------------------------- */

module fifo#(
  parameter DATA_WIDTH = 32, //Size of each data entry
  parameter FIFO_LENGTH_SIZE = 6 //Width of number of entries
  )(
  input clk,
  input rst,
  //Flags
  output fifo_empty,
  output fifo_full,
  output reg [FIFO_LENGTH_SIZE:0] awaiting_count, //Number of entires waiting in the buffer
  //Data in
  input [DATA_WIDTH-1:0] data_i,
  input push, //Add data_i to buffer, level sensitive
  //Data out
  output [DATA_WIDTH-1:0] data_o,
  input drop //Entry at data_o is read, should be set after data_o is read, level sensitive
  );
  localparam FIFO_LENGTH = 2 ** FIFO_LENGTH_SIZE;
  reg [DATA_WIDTH-1:0] buffer[FIFO_LENGTH-1:0];

  //Pointers for circular buffer
  reg  [FIFO_LENGTH_SIZE-1:0]  read_ptr;
  wire [FIFO_LENGTH_SIZE-1:0] write_ptr = read_ptr + awaiting_count[FIFO_LENGTH_SIZE-1:0];

  always@(posedge clk) begin
    if(rst) begin
      read_ptr <= 0;
    end else begin
      read_ptr <= (~fifo_empty & drop) ? read_ptr + 1 : read_ptr;
    end
  end

  always@(posedge clk) begin
    if(rst) begin
      awaiting_count <= 0;
    end else begin
      if(~fifo_full & ~drop & push) begin
        awaiting_count <= awaiting_count + 1;
      end else if(~fifo_empty & drop & ~push) begin
        awaiting_count <= awaiting_count - 1;
      end
    end
  end


  //fifo flags
  assign fifo_empty = (awaiting_count == 0);
  assign fifo_full  =  awaiting_count[FIFO_LENGTH_SIZE];
  

  //Handle data pins
  assign data_o = buffer[read_ptr];
  always@(posedge clk) begin
    if(~fifo_full & push) begin
      buffer[write_ptr] <= data_i;
    end
  end
endmodule
