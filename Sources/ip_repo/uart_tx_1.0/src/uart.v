/* ------------------------------------------------ *
 * Title       : UART interface  v1.4               *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : uart.v                             *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 12/10/2021                         *
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
 * ------------------------------------------------ */

module uart_tx(
  input clk,
  input rst,
  //UART transmit
  output reg tx,
  //Uart clock connection
  input clk_uart,
  output uart_enable,
  //Config signals
  input data_size, //0: 7bit; 1: 8bit
  input parity_en,
  input [1:0] parity_mode, //11: odd; 10: even, 01: mark(1), 00: space(0)
  input stop_bit_size, //0: 1bit; 1: 2bit
  //Data interface
  input [7:0] data,
  output ready,
  input send);
  localparam READY = 3'b000,
             START = 3'b001,
              DATA = 3'b011,
            PARITY = 3'b110,
               END = 3'b100;
  reg [2:0] counter;
  reg [2:0] state;
  reg [7:0] data_buff;
  reg en, parity_calc, in_End_d;

  //Decode states
  wire in_Ready = (state == READY);
  wire in_Start = (state == START);
  wire in_Data = (state == DATA);
  wire in_Parity = (state == PARITY);
  wire in_End = (state == END);
  assign ready = in_Ready;


  wire countDONE = (in_End & (counter[0] == stop_bit_size)) | (in_Data & (counter == {2'b11, data_size}));
  assign uart_enable = en & (~in_End_d | in_End);

  //Internal enable signal
  always@(posedge clk) begin
    if(rst) begin
      en <= 1'd0;
    end else case(en)
      1'b0: en <= send;
      1'b1: en <= ~in_End_d | in_End; //only high on negative edge
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

  //handle data_buff
  always@(negedge clk_uart) begin
    case(state)
      START: data_buff <= data;
      DATA: data_buff <= (data_buff >> 1);
      default: data_buff <= data_buff;
    endcase
  end

  //tx routing
  always@* begin
    case(state)
      START: tx = 1'b0;
      DATA: tx = data_buff[0];
      PARITY: tx = parity_calc;
      default: tx = 1'b1;
    endcase
  end

  //Parity calc
  always@(posedge clk_uart) begin
    if(in_Start) begin //reset
      parity_calc <= parity_mode[0];
    end else begin
      parity_calc <= (in_Data) ? (parity_calc ^ (tx & parity_mode[1])) : parity_calc;
    end
  end
endmodule//uart_tx
