/* ------------------------------------------------ *
 * Title       : UART Rx Simulation                 *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : sim_rx.v                           *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 12/10/2021                         *
 * ------------------------------------------------ *
 * Description : Simulation for Receiver module     *
 * ------------------------------------------------ */

`timescale 1ns / 1ps
// `include "Sources/uart.v"

module testbenchrx();
  reg clk, rst, data_size, parity_en, stop_bit_size;
  wire ready, uartClock, err_crc, err_frame, new_data,uartEn;
  reg rx;
  reg [1:0] parity_mode;
  wire [7:0] data;
  reg [8:0] send_buff;
  reg [7:0] send_data;
  reg parity;


  always #5 clk <= ~clk;

   //0: 76,8kHz (13us); 1: 460,8kHz (2,17us)
  //parity_mode: 11: odd; 10: even, 01: mark(1), 00: space(0)
  uart_rx uut(clk, rst, rx, uartClock, uartEn, data_size, parity_en, parity_mode, stop_bit_size, data, err_crc, err_frame, ready, new_data);

  uart_clk_gen clkGenUART(clk,rst,uartEn,uartClock,1'b1, 3'd0);

/*      initial //Tracked signals & Total sim time
       begin
         $dumpfile("Simulation/rx.vcd");
         $dumpvars(0, clk);
         $dumpvars(1, rst);
         $dumpvars(2, ready);
         $dumpvars(3, new_data);
         $dumpvars(4, data_size);
         $dumpvars(5, parity_en);
         $dumpvars(6, parity_mode);
         $dumpvars(7, valid);
         $dumpvars(8, data);
         $dumpvars(9, rx);
         $dumpvars(10, uartClock);
         $dumpvars(11, send_data);
         $dumpvars(12, parity);
         #26000
         $finish;
       end */
    initial begin
      $dumpfile("sim.vcd");
      $dumpvars(0, testbenchrx);
    end
    initial //initilizations and reset
        begin
            clk <= 0;
            rst <= 0;
            #3
            rst <= 1;
            #10
            rst <= 0;
        end
    initial //test cases
        begin
            rx = 1;
            data_size = 1;
            parity_en = 1;
            parity_mode  = 2'd1;
            stop_bit_size = 0;
            send_data = 8'h95;
            parity = 1;
            send_buff = {parity, send_data};
            #101
            rx = 0; //start
            #2160
            rx = send_buff[0]; //data 0
            #2160
            rx = send_buff[1]; //data 1
            #2160
            rx = send_buff[2]; //data 2
            #2160
            rx = send_buff[3]; //data 3
            #2160
            rx = send_buff[4]; //data 4
            #2160
            rx = send_buff[5]; //data 5
            #2160
            rx = send_buff[6]; //data 6
            if(data_size)
              begin
                #2160
                rx = send_buff[7]; //data 7
              end
            if(parity_en)
              begin
                #2160
                rx = send_buff[8]; //parity
              end
            #2160
            rx = 1;
            #10000
            rx = 0; //start
            #2160
            rx = send_buff[0]; //data 0
            #2160
            rx = send_buff[1]; //data 1
            #2160
            rx = send_buff[2]; //data 2
            #2160
            rx = send_buff[3]; //data 3
            #2160
            rx = send_buff[4]; //data 4
            #2160
            rx = send_buff[5]; //data 5
            #2160
            rx = send_buff[6]; //data 6
            if(data_size)
              begin
                #2160
                rx = send_buff[7]; //data 7
              end
            if(parity_en)
              begin
                #2160
                rx = ~send_buff[8]; //wrong parity
              end
            #2160
            rx = 1;
            #10000
            rx = 0; //start
            #2160
            rx = send_buff[0]; //data 0
            #2160
            rx = send_buff[1]; //data 1
            #2160
            rx = send_buff[2]; //data 2
            #2160
            rx = send_buff[3]; //data 3
            #2160
            rx = send_buff[4]; //data 4
            #2160
            rx = send_buff[5]; //data 5
            #2160
            rx = send_buff[6]; //data 6
            if(data_size)
              begin
                #2160
                rx = send_buff[7]; //data 7
              end
            if(parity_en)
              begin
                #2160
                rx = send_buff[8]; //parity
              end
            #2160
            rx = 0; //frame error
            #2160
            rx = 1;
            #10000
            $finish;
        end
endmodule