/* ------------------------------------------------ *
 * Title       : UART test board                    *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : test.v                             *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 16/12/2020                         *
 * ------------------------------------------------ *
 * Description : Test module for UART interface     *
 * ------------------------------------------------ */

//`include "Sources/uart.v"
//`include "Test/ssd_util.v"
//`include "Test/btn_debouncer.v"

module board(
  input clk,
  input rst, //btnC
  input btnR, //send
  input btnU, //stop bit
  input btnD, //Tx len
  output [6:0] seg,
  output [3:0] an,
  output valid, //Led 15
  input [2:0] divRatio, //11:9
  input [1:0] parity_mode, //sw 14:13
  input parity_en, //sw 15
  input rx, //USB-RS232 & JB3
  //output rx_mirror, //JB3
  output tx, //USB-RS232 & JB2
  output ready_tx, //Led 13
  output ready_rx, //Led 14
  output uartClock_tx, //JB8
  output uartClock_rx, //JB9
  output newData, //JB1
  output reg stop_bit_size, //Led 0
  output reg data_size, //Led 1
  input baseClock_freq, //sw 12
  input [7:0] sw);
  
  wire send, ch_stopBit, ch_txL;
  wire [7:0] data_i, data_o;

  assign data_i = sw;
  assign rx_mirror = rx;

  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          stop_bit_size <= 1'b0;
        end
      else
        begin
          stop_bit_size <= ch_stopBit ^ stop_bit_size;
        end
    end
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          data_size <= 1'b0;
        end
      else
        begin
          data_size <= ch_txL ^ data_size;
        end
    end

  debouncer btnDeb_send(clk, rst, btnR, send);
  debouncer btnDeb_sb(clk, rst, btnU, ch_stopBit);
  debouncer btnDeb_len(clk, rst, btnD, ch_txL);
  ssdController4 ssdCntr(clk, rst, 4'b1111, data_o[7:4], data_o[3:0], data_i[7:4], data_i[3:0], seg, an);

  //0: 76,8kHz (13us); 1: 460,8kHz (2,17us)
  //11: odd; 10: even, 01: mark(1), 00: space(0)
  uart_tx TxUART(clk, rst, baseClock_freq, divRatio, data_size,  parity_en, parity_mode, stop_bit_size, data_i, ready_tx, send, tx, uartClock_tx);
  uart_rx RxUART(clk, rst, baseClock_freq, divRatio, data_size,  parity_en, parity_mode, data_o, valid, ready_rx, newData, rx, uartClock_rx);
endmodule