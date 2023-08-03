`timescale 1 ns / 1 ps
/* ------------------------------------------------ *
 * Title       : UART Transreceiver IP              *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : uart_v1_0.v                        *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 30/11/2021                         *
 * Licence     : CERN-OHL-W                         *
 * ------------------------------------------------ *
 * Description : UART Transreceiver IP with         *
 *               AXI-lite interface                 *
 * ------------------------------------------------ *
 * Revisions                                        *
 *     v1      : Inital version                     *
 * ------------------------------------------------ */

  module uart_v1_0 #
  (
    //Customization Parameters
    parameter Tx_BUFFER_SIZE = 8,
    parameter Rx_BUFFER_SIZE = 8,
    parameter ERROR_BUFFER = 1,
    parameter AXI_CLOCK_PERIOD = 10,

    //Default UART Configurations
    parameter DEFAULT_DATA_SIZE = 1,
    parameter DEFAULT_STOP_BIT = 0,
    parameter DEFAULT_PARTY_EN = 0,
    parameter DEFAULT_PARTY = 0,
    parameter DEFAULT_BASECLK = 1,
    parameter DEFAULT_DIVRATIO = 2,

    //Register Map
    parameter OFFSET_RX_BUFF = 0,
    parameter OFFSET_TX_BUFF = 4,
    parameter OFFSET_CONFIG = 8,
    parameter OFFSET_STATUS = 12,
    parameter OFFSET_RX_COUNT = 16,
    parameter OFFSET_TX_COUNT = 20,

    // Parameters of Axi Slave Bus Interface S_AXI
    parameter C_S_AXI_DATA_WIDTH  = 32,
    parameter C_S_AXI_ADDR_WIDTH  = 5
  )
  (
    input rx,
    output tx,
    output interrupt,

    // Ports of Axi Slave Bus
    input s_axi_aclk,
    input s_axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input [2:0] s_axi_awprot,
    input  s_axi_awvalid,
    output s_axi_awready,
    input [C_S_AXI_DATA_WIDTH-1:0]     s_axi_wdata,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  s_axi_wvalid,
    output s_axi_wready,
    output [1:0] s_axi_bresp,
    output s_axi_bvalid,
    input  s_axi_bready,
    input [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input [2:0] s_axi_arprot,
    input  s_axi_arvalid,
    output s_axi_arready,
    output [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output s_axi_rvalid,
    input  s_axi_rready
  );
    integer i;
    localparam OxDEC0DEE3 = 3737181923; // this is also used by interconnect when the address doesn't exist
    localparam RES_OKAY = 2'b00,
               RES_ERR  = 2'b10; //Slave error
    //Module connections
    wire clk_uart_rx, clk_uart_tx, uart_enable_rx, uart_enable_tx, error_parity, error_frame, ready_tx, ready_rx, newData;
    wire rx_buffer_full, rx_buffer_empty, tx_buffer_full, tx_buffer_empty;
    wire [7:0] data_rx, data_tx;
    wire [7+(ERROR_BUFFER*2):0] rx_fifo_out;
    wire [Rx_BUFFER_SIZE:0] Rx_awaiting;
    wire [Tx_BUFFER_SIZE:0] Tx_awaiting;
    reg ready_tx_d;
    always@(posedge s_axi_aclk) begin
      ready_tx_d <= ready_tx;
    end
    wire done_tx = ~ready_tx_d & ready_tx;

    reg blockingTx; //Config to block axi when buffer full

    wire send = ~tx_buffer_empty;

    //Addresses
    wire [C_S_AXI_ADDR_WIDTH-1:0] write_address = s_axi_awaddr;
    wire [C_S_AXI_ADDR_WIDTH-1:0]  read_address = s_axi_araddr;


    //Internal Control signals
    wire read_addr_hs = s_axi_arvalid & s_axi_arready; //Handshake condition
    wire config_free = ((write_address != OFFSET_CONFIG) | (ready_tx & ready_rx));
    wire rx_buffer_free =  ((read_address != OFFSET_RX_BUFF) & ~newData);
    wire tx_buffer_free = ((write_address != OFFSET_TX_BUFF) | (~(blockingTx & tx_buffer_full) & ~done_tx));
    wire write = s_axi_awvalid & s_axi_wvalid & config_free & tx_buffer_free;
    wire  read = read_addr_hs & rx_buffer_free;
    wire  read_addr_valid =  (read_address == OFFSET_STATUS)  |  
                             (read_address == OFFSET_CONFIG)  |  
         (~rx_buffer_empty & (read_address == OFFSET_RX_BUFF))| 
                             (read_address == OFFSET_RX_COUNT)|  
                             (read_address == OFFSET_TX_COUNT);
    wire write_addr_valid = (write_address == OFFSET_TX_BUFF) | 
                            (write_address == OFFSET_CONFIG);
    wire [C_S_AXI_DATA_WIDTH-1:0] data_to_write = s_axi_wdata; //renaming


    //Configurations
    reg data_size, parity_en, stop_bit_size, baseClock_freq, interrupt_en, clear_txfifo, clear_rxfifo, errBuff_en, interruptTx_en, interruptRx_en;
    reg [1:0] parity_mode;
    reg [2:0] divRatio;
    /*
     *     _Bits_       _Reg_
     *      [15]      interruptTx_en
     *      [14]      interruptRx_en
     *      [13]      errBuff_en
     *      [12]       Blocking Tx
     *      [11]      clear_rxfifo (self clearing)
     *      [10]      clear_txfifo (self clearing)
     *      [9]       baseClock_freq
     *     [8:6]       divRatio
     *     [5:4]      parity_mode
     *      [3]       parity_en
     *      [2]       data_size
     *      [1]       stop_bit_size
     *      [0]       interrupt_en
     */
    wire [C_S_AXI_DATA_WIDTH-1:0] config_reg = {
                                                interruptTx_en, //15
                                                interruptRx_en, //14
                                                errBuff_en, //13
                                                blockingTx, //12
                                                clear_rxfifo, //11
                                                clear_txfifo, //10
                                                baseClock_freq, //9
                                                divRatio, //8-6
                                                parity_mode, //5-4
                                                parity_en, //3
                                                data_size, //2
                                                stop_bit_size, //1
                                                interrupt_en}; //0
    wire update_config = (write_address == OFFSET_CONFIG) & write;
    always@(posedge s_axi_aclk) begin
      if(~s_axi_aresetn) begin
        errBuff_en <= 1;
        blockingTx <= 0;
        clear_rxfifo <= 0;
        clear_txfifo <= 0;
        divRatio <= DEFAULT_DIVRATIO;
        baseClock_freq <= DEFAULT_BASECLK;
        parity_mode <= DEFAULT_PARTY;
        parity_en <= DEFAULT_PARTY_EN;
        data_size <= DEFAULT_DATA_SIZE;
        stop_bit_size <= DEFAULT_STOP_BIT;
        interrupt_en <= 0;
        interruptRx_en <= 1;
        interruptTx_en <= 1;
      end else begin
        {interruptTx_en,interruptRx_en,errBuff_en,blockingTx,clear_rxfifo,clear_txfifo,baseClock_freq,divRatio,parity_mode,parity_en,data_size,stop_bit_size,interrupt_en} 
          <= (update_config) ? data_to_write : 
        {interruptTx_en,interruptRx_en,errBuff_en,blockingTx,1'b0,1'b0,baseClock_freq,divRatio,parity_mode,parity_en,data_size,stop_bit_size,interrupt_en};
      end
    end


    //Interrupt signal
    assign interrupt = interrupt_en & ((~rx_buffer_empty & interruptRx_en)|(tx_buffer_empty & interruptTx_en));


    /*
     *     _Bits_       _Reg_
     *      [7]       Error Buffer implemented
     *      [6]       Overrun/Data Lost
     *      [5]       Parity Error
     *      [4]       Frame Error
     *      [3]       Tx Buffer Full
     *      [2]       Rx Buffer Full
     *      [1]       Tx Buffer Empty
     *      [0]       Rx Buffer Empty
     */
    //Status reg
    reg gotFrameError, gotCRCError, gotOverrun;
    wire hasErrBuff = ERROR_BUFFER;
    wire read_stat = (read_address == OFFSET_STATUS) & read;
    wire [31:0] status_reg = {hasErrBuff, //7
                              gotOverrun, //6
                              gotCRCError, //5
                              gotFrameError, //4
                              tx_buffer_full, //3
                              rx_buffer_full, //2
                              tx_buffer_empty, //1
                              rx_buffer_empty}; //0
    always@(posedge s_axi_aclk) begin
      if(~s_axi_aresetn) begin
        gotOverrun <= 0;
        gotCRCError <= 0;
        gotFrameError <= 0;
      end else begin
        gotOverrun <= (read_stat) ? 0 : (gotOverrun | (rx_buffer_full & newData));
        gotCRCError <= (read_stat) ? 0 : (gotCRCError | (error_parity & newData));
        gotFrameError <= (read_stat) ? 0 : (gotFrameError | (error_frame & newData));
      end
    end


    //Tx Buffer
    wire Tx_buffer_addressed = (write_address == OFFSET_TX_BUFF);
    wire write_buffer = Tx_buffer_addressed & write;
    fifo #(.DATA_WIDTH(8), .FIFO_LENGTH_SIZE(Tx_BUFFER_SIZE)) 
        tx_buffer(.clk(s_axi_aclk), 
                  .rst(~s_axi_aresetn|clear_txfifo),
                  .fifo_empty(tx_buffer_empty),
                  .fifo_full(tx_buffer_full),
                  .data_i(data_to_write[7:0]),
                  .push(write_buffer),
                  .awaiting_count(Tx_awaiting),
                  .data_o(data_tx),
                  .drop(done_tx));
    
    //Rx Buffer
    wire [1:0] errors = {error_parity, error_frame};
    wire [7+(ERROR_BUFFER*2):0] fifo_in = (ERROR_BUFFER == 0) ? data_rx :
                                     {errors & {2{errBuff_en}}, data_rx};
    wire next_data = (read_address == OFFSET_RX_BUFF) & read_addr_hs;
    fifo #(.DATA_WIDTH(8+(ERROR_BUFFER*2)), 
           .FIFO_LENGTH_SIZE(Rx_BUFFER_SIZE)) 
        rx_buffer(.clk(s_axi_aclk), 
                  .rst(~s_axi_aresetn|clear_rxfifo),
                  .fifo_empty(rx_buffer_empty),
                  .fifo_full(rx_buffer_full),
                  .data_i(fifo_in),
                  .push(newData),
                  .awaiting_count(Rx_awaiting),
                  .data_o(rx_fifo_out),
                  .drop(next_data));


    //Uart Tx
    uart_tx transmitter(.clk(s_axi_aclk),
                        .rst(~s_axi_aresetn|clear_txfifo),
                        .tx(tx),
                        .clk_uart(clk_uart_tx),
                        .uart_enable(uart_enable_tx),
                        .data_size(data_size), //0: 7bit; 1: 8bit
                        .parity_en(parity_en),
                        .parity_mode(parity_mode), //11: odd; 10: even, 01: mark(1), 00: space(0)
                        .stop_bit_size(stop_bit_size), //0: 1bit; 1: 2bit
                        .data(data_tx),
                        .ready(ready_tx),
                        .send(send));
    uart_clk_gen #(AXI_CLOCK_PERIOD) 
               clock_gen_tx(.clk(s_axi_aclk),
                            .rst(~s_axi_aresetn),
                            .en(uart_enable_tx),
                            .clk_uart(clk_uart_tx),
                            .baseClock_freq(baseClock_freq), //0: 76,8kHz (13us) 1: 460,8kHz (2,17us)
                            .divRatio(divRatio)); //Higher the value lower the freq
    
    //Uart Rx
    uart_rx receiver(.clk(s_axi_aclk),
                     .rst(~s_axi_aresetn|clear_rxfifo),
                     .rx(rx),
                     .clk_uart(clk_uart_rx),
                     .uart_enable(uart_enable_rx),
                     .data_size(data_size), //0: 7bit; 1: 8bit
                     .parity_en(parity_en),
                     .parity_mode(parity_mode), //11: odd; 10: even, 01: mark(1), 00: space(0)
                     .stop_bit_size(stop_bit_size), //0: 1bit; 1: 2bit
                     .data(data_rx),
                     .error_parity(error_parity),
                     .error_frame(error_frame),
                     .ready(ready_rx),
                     .newData(newData));

    uart_clk_gen #(AXI_CLOCK_PERIOD) 
               clock_gen_rx(.clk(s_axi_aclk),
                            .rst(~s_axi_aresetn),
                            .en(uart_enable_rx),
                            .clk_uart(clk_uart_rx),
                            .baseClock_freq(baseClock_freq), //0: 76,8kHz (13us) 1: 460,8kHz (2,17us)
                            .divRatio(divRatio)); //Higher the value lower the freq


    //AXI Signals
    //Write response
    reg s_axi_bvalid_hold, s_axi_bresp_MSB_hold;
    assign s_axi_bvalid = write | s_axi_bvalid_hold;
    assign s_axi_bresp = (s_axi_bvalid_hold) ? {s_axi_bresp_MSB_hold, 1'b0} :
        (~write_addr_valid | (Tx_buffer_addressed & tx_buffer_full)) ? RES_ERR : 
                                                                    RES_OKAY;
    always@(posedge s_axi_aclk) begin
      if(~s_axi_aresetn) begin
        s_axi_bvalid_hold <= 0;
      end else case(s_axi_bvalid_hold)
        1'b0: s_axi_bvalid_hold <= ~s_axi_bready & s_axi_bvalid;
        1'b1: s_axi_bvalid_hold <= ~s_axi_bready;
      endcase
      if(~s_axi_bvalid_hold) begin
        s_axi_bresp_MSB_hold <= s_axi_bresp[1];
      end
    end

    //Write Channel handshake (Data & Addr)
    wire  write_ch_ready = config_free & tx_buffer_free & ~(s_axi_awvalid ^ s_axi_wvalid) & ~s_axi_bvalid_hold;
    assign s_axi_awready = write_ch_ready;
    assign s_axi_wready  = write_ch_ready;

    //Read Channel handshake (Addr & data)
    reg s_axi_rvalid_hold; //This will hold read data channel stable until master accepts tx
    assign s_axi_rvalid = s_axi_arvalid | s_axi_rvalid_hold;
    assign s_axi_arready = ~s_axi_rvalid | s_axi_rready;
    always@(posedge s_axi_aclk) begin
      if(~s_axi_aresetn) begin
        s_axi_rvalid_hold <= 0;
      end else case(s_axi_rvalid_hold)
        1'b0: s_axi_rvalid_hold <= ~s_axi_rready & s_axi_rvalid;
        1'b1: s_axi_rvalid_hold <= ~s_axi_rready;
      endcase
    end

    //Read response
    reg s_axi_rresp_MSB_hold;
    always@(posedge s_axi_aclk) begin
      if(~s_axi_rvalid_hold) begin
       s_axi_rresp_MSB_hold <= s_axi_rresp[1];
      end
    end
    assign s_axi_rresp = (s_axi_rvalid_hold) ? {s_axi_rresp_MSB_hold, 1'b0} :
                           (read_addr_valid) ? RES_OKAY : RES_ERR;
    
    //Read data
    reg [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata_hold;
    reg [C_S_AXI_DATA_WIDTH-1:0] readReg;
    always@(posedge s_axi_aclk) begin
      if(~s_axi_rvalid_hold) begin
        s_axi_rdata_hold <= s_axi_rdata;
      end
    end
    assign s_axi_rdata = (s_axi_rvalid_hold) ? s_axi_rdata_hold : readReg;
    always@* begin
      case(read_address)
        OFFSET_STATUS:   readReg = status_reg;
        OFFSET_CONFIG:   readReg = config_reg;
        OFFSET_TX_COUNT: readReg = Tx_awaiting;
        OFFSET_RX_COUNT: readReg = Rx_awaiting;
        OFFSET_RX_BUFF:  readReg = rx_fifo_out;
        default: readReg = OxDEC0DEE3;
      endcase
    end
  endmodule
