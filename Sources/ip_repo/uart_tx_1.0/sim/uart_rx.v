`timescale 1ns / 1ps
/* ------------------------------------------------ *
 * Title       : UART interface  v1.4               *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : uart.v                             *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 17/10/2021                         *
 * ------------------------------------------------ *
 * Description : UART communication modules         *
 * ------------------------------------------------ *
 * Revisions                                        *
 *     v1      : Inital version                     *
 *     v1.1    : Redeclerations of clk_uart in      *
 *               Tx and Rx modules removed          *
 *     v1.2    : Move UART generation into outside  *
 *               of UART modules                    *
 *     v1.3    : More compact coding style          *
 *     v1.4    : Detect Frame error                 *
 *     v1.4.1  : Bugfix: Fixed data out for 7 bit   *
 * ------------------------------------------------ */

module uart_rx(
  input clk,
  input rst,
  //UART receive
  input rx,
  //Uart clock connection
  input clk_uart,
  output uart_enable,
  //Config signals
  input data_size, //0: 7bit; 1: 8bit
  input parity_en,
  input [1:0] parity_mode, //11: odd; 10: even, 01: mark(1), 00: space(0)
  input stop_bit_size, //0: 1bit; 1: 2bit
  //Data interface
  output reg [7:0] data,
  output reg error_parity,
  output reg error_frame,
  output ready,
  output newData);
  localparam READY = 3'b000,
             START = 3'b001,
              DATA = 3'b011,
            PARITY = 3'b110,
               END = 3'b100;
  reg [2:0] counter; 
  reg [2:0] state;
  reg [7:0] data_buff;
  reg parity_calc, in_End_d, en;

  //Decode states
  wire in_Ready = (state == READY);
  wire in_Start = (state == START);
  wire in_Data = (state == DATA);
  wire in_Parity = (state == PARITY);
  wire in_End = (state == END);
  assign ready = in_Ready;

  assign newData = ~in_End & in_End_d; //New data add negedge of in_End
  wire countDONE = (in_End & (counter[0] == stop_bit_size)) | (in_Data & (counter == {2'b11, data_size}));
  assign uart_enable = en & (~in_End_d | in_End);

  //internal enable
  always@(posedge clk or posedge rst) begin
    if(rst) begin
      en <= 1'b0;
    end else case(en)
      1'b0: en <= (rx) ? en : 1'b1;
      1'b1: en <= ~in_End_d | in_End;
    endcase
  end

  //Counter
  always@(negedge clk_uart or posedge rst) begin
    if(rst) begin
      counter <= 3'd0;
    end else case(state)
      DATA: counter <= (countDONE) ? 3'd0 : (counter + 3'd1);
      END: counter <= (countDONE) ? 3'd0 : (counter + 3'd1);
      default: counter <= 3'd0;
    endcase
  end

  //State transactions
  always@(negedge clk_uart or posedge rst) begin
    if(rst) begin
      state <= READY;
    end else case(state)
      READY: state <= (en) ? START : state;
      START: state <= DATA;
      DATA: state <= (countDONE) ? ((parity_en) ? PARITY : END) : state;
      PARITY: state <= END;
      END: state <= (countDONE) ? READY : state;
      default: state <= READY;
    endcase
  end

  //delay in_End
  always@(posedge clk) in_End_d <= in_End;

  //Store received data
  always@(posedge clk) begin
    data <= (~in_End_d & in_End) ? 
                    ((data_size) ? data_buff : 
                     {1'b0, data_buff[7:1]}) : 
                                         data;
  end

  //Handle data_buff
  always@(posedge clk_uart) begin
    case(state)
      START: data_buff <= 8'd0;
      DATA: data_buff <= {rx, data_buff[7:1]};
      default: data_buff <= data_buff;
    endcase
  end

  //Frame error
  always@(posedge clk_uart) begin
    if(rst | in_Start) begin
      error_frame <= 1'b0;
    end else begin
      error_frame <= (in_End) ? ~rx | error_frame : error_frame;
    end
  end

  //Parity check
  always@(posedge clk_uart) begin
    if(rst | in_Start) begin
      error_parity <= 1'b0;
    end else begin
      error_parity <= (in_Parity) ? (rx != parity_calc) | error_parity : error_parity;
    end
  end

  //Parity calc
  always@(posedge clk_uart) begin
    if(in_Start) begin //reset
      parity_calc <= parity_mode[0];
    end else begin
      parity_calc <= (in_Data) ? (parity_calc ^ (rx & parity_mode[1])) : parity_calc;
    end
  end
endmodule//uart_tx
