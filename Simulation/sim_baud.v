/* ------------------------------------------------ *
 * Title       : Clock generation Simulation        *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : sim_baud.v                         *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 23/05/2021                         *
 * ------------------------------------------------ *
 * Description : Simulation for Clock generator     *
 * ------------------------------------------------ */

`timescale 1ns / 1ps
`include "Sources/uart.v"

module testbenchclk();
  reg clk, rst, en;
  wire clk_slw;

  always #5 clk <= ~clk;

  uart_clk_gen_hs uut(clk, rst, en, clk_slw, 2'd3);

     initial //Tracked signals & Total sim time
       begin
         $dumpfile("Simulation/baud.vcd");
         $dumpvars(0, clk);
         $dumpvars(1, rst);
         $dumpvars(2, en);
         $dumpvars(3, clk_slw);
         #10000
         $finish;
       end

    initial //initilizations and reset
        begin
            clk <= 0;
            rst <= 0;
            en <= 0;
            #3
            rst <= 1;
            #10
            rst <= 0;
            #30
            en <= 1;
        end

endmodule