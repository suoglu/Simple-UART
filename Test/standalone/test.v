`timescale 1ns / 1ps
/* ------------------------------------------------ *
 * Title       : UART tester board                  *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : test.v                             *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 23/05/2021                         *
 * ------------------------------------------------ *
 * Description : Test module for UART interface     *
 * ------------------------------------------------ */
 //! Add uart modules in block design or run tcl script

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
  // output valid, //Led 15
 // input [2:0] divRatio, //11:9
  // input [1:0] parity_mode, //sw 14:13
  // input parity_en, //sw 15
  // input rx, //USB-RS232 & JB3
  //output rx_mirror, //JB3
  // output tx, //USB-RS232 & JB2
  // output ready_tx, //Led 13
  // output ready_rx, //Led 14
  // output uartClock_tx, //JB8
  // output uartClock_rx, //JB9
  // output newData, //JB1
  output reg stop_bit_size, //Led 0
  output reg data_size, //Led 1
  // input baseClock_freq, //sw 12
  input [7:0] sw,
  output send,
  output [7:0] data_i,
  input [7:0] data_o);
  
  wire ch_stopBit, ch_txL;

  assign data_i = sw;

  always@(posedge clk or posedge rst) //stop_bit_size
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
  always@(posedge clk or posedge rst) //data_size
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
endmodule