/* ------------------------------------------------ *
 * Title       : UART interface  v1.3               *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : uart.v                             *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 11/10/2021                         *
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
 * ------------------------------------------------ */

module uart_transceiver(
  input clk,
  input rst,
  //UART
  output tx,
  input rx,
  //Uart clock connection
  input clk_uart_tx,
  input clk_uart_rx,
  output uart_enable_tx,
  output uart_enable_rx,
  //Config signals 
  input data_size, //0: 7bit; 1: 8bit
  input parity_en,
  input [1:0] parity_mode, //11: odd; 10: even, 01: mark(1), 00: space(0)
  input stop_bit_size, //0: 1bit; 1: 2bit
  //Data interface
  input [7:0] data_i,
  output [7:0] data_o,
  output error_parity,
  output new_data,
  output ready_tx,
  output ready_rx,
  input send);
  
  uart_rx RxUART(.clk(clk), 
                 .rst(rst),  
                 .rx(rx),  
                 .clk_uart(clk_uart_rx),  
                 .uart_enable(uart_enable_rx),  
                 .data_size(data_size),  
                 .parity_en(parity_en),  
                 .parity_mode(parity_mode),  
                 .data(data_o),  
                 .error_parity(error_parity),  
                 .ready(ready_rx),  
                 .newData(new_data));

  uart_tx TxUART(.clk(clk),  
                 .rst(rst),  
                 .tx(tx),  
                 .clk_uart(clk_uart_tx),  
                 .uart_enable(uart_enable_tx),  
                 .data_size(data_size),  
                 .parity_en(parity_en),  
                 .parity_mode(parity_mode),  
                 .stop_bit_size(stop_bit_size),  
                 .data(data_i),  
                 .ready(ready_tx),  
                 .send(send));
endmodule//uart_dual

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
  wire in_Ready, in_Start, in_Data, in_Parity, in_End;
  reg en, parity_calc, in_End_d;
  wire countDONE;
  
  //Decode states
  assign in_Ready = (state == READY);
  assign in_Start = (state == START);
  assign in_Data = (state == DATA);
  assign in_Parity = (state == PARITY);
  assign in_End = (state == END);
  assign ready = in_Ready;


  assign countDONE = (in_End & (counter[0] == stop_bit_size)) | (in_Data & (counter == {2'b11, data_size}));
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
  //Data interface
  output reg [7:0] data,
  output reg error_parity,
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
  wire in_Ready, in_Start, in_Data, in_Parity, in_End;
  reg parity_calc, in_End_d, en;

  //Decode states
  assign in_Ready = (state == READY);
  assign in_Start = (state == START);
  assign in_Data = (state == DATA);
  assign in_Parity = (state == PARITY);
  assign in_End = (state == END);
  assign ready = in_Ready;

  assign newData = ~in_End & in_End_d; //New data add negedge of in_End
  assign countDONE = in_Data & (counter == {2'b11, data_size});
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
      END: state <= READY;
      default: state <= READY;
    endcase
  end

  //delay in_End
  always@(posedge clk) in_End_d <= in_End;

  //Store received data
  always@(posedge clk) begin
    data <= (~in_End_d & in_End) ? data_buff : data;
  end
  
  //Handle data_buff
  always@(posedge clk_uart) begin
    case(state)
      START: data_buff <= 8'd0;
      DATA: data_buff <= {rx, data_buff[7:1]};
      END: data_buff <= (data_size) ? data_buff : (data_buff >> 1);
      default: data_buff <= data_buff;
    endcase
  end
  
  //Parity check
  always@(posedge clk) begin
    if(rst) begin
      error_parity <= 1'b0;
    end else begin
      error_parity <= (in_Parity) ? (rx != parity_calc) : error_parity;
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
