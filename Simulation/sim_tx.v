/* ------------------------------------------------ *
 * Title       : UART Tx Simulation                 *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : sim_tx.v                           *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 12/10/2021                         *
 * ------------------------------------------------ *
 * Description : Simulation for Transmitter module  *
 * ------------------------------------------------ */

`timescale 1ns / 1ps
//`include "Sources/uart.v"

module testbenchtx();
  reg clk, rst, data_size, parity_en, stop_bit_size, send;
  wire tx, ready, uartClock, uartEn,uartClock_rx,uartEn_rx, err_crc, err_frame , new_data;
  reg [1:0] parity_mode;
  reg [7:0] data;
  wire [7:0] data_rx;

  always #5 clk <= ~clk;

   //0: 76,8kHz (13us); 1: 460,8kHz (2,17us)
  //parity_mode: 11: odd; 10: even, 01: mark(1), 00: space(0)
  uart_tx uut(clk, rst, tx, uartClock, uartEn, data_size, parity_en, parity_mode, stop_bit_size, data, ready, send);
  uart_rx helper(clk, rst, tx, uartClock_rx, uartEn_rx, data_size, parity_en, parity_mode, stop_bit_size, data_rx, err_crc, err_frame, , new_data);

  uart_clk_gen clkGenUART_rx(clk,rst,uartEn_rx,uartClock_rx,1'b1, 3'd0);

  uart_clk_gen clkGenUART (clk,rst,uartEn,uartClock,1'b1, 3'd0);

/*      initial //Tracked signals & Total sim time
       begin
         $dumpfile("Simulation/tx.vcd");
         $dumpvars(0, clk);
         $dumpvars(1, rst);
         $dumpvars(2, ready);
         $dumpvars(3, send);
         $dumpvars(4, data_size);
         $dumpvars(5, parity_en);
         $dumpvars(6, parity_mode);
         $dumpvars(7, stop_bit_size);
         $dumpvars(8, data);
         $dumpvars(9, tx);
         $dumpvars(10, uartClock);
         #250000
         $finish;
       end */

    initial //initilizations and reset
        begin
            clk <= 0;
            rst <= 0;
            send <= 0;
            #3
            rst <= 1;
            #10
            rst <= 0;
        end
    initial //test cases
        begin
            data_size <= 1;
            parity_en <= 1;
            parity_mode  <= 2'd3;
            stop_bit_size <= 0;
            data <= 8'hAA;
            #1052
            send <= 1;
            #20
            send <= 0;
            #30000
            data <= 8'h55;
            send <= 1;
            #30000
            $finish;
        end
endmodule
