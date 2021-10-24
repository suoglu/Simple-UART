`timescale 1 ns / 1 ps
/* ------------------------------------------------ *
 * Title       : UART Transmitter IP                *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : uart_tx_v1_0.v                     *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 24/10/2021                         *
 * ------------------------------------------------ *
 * Description : UART Transmitter IP with AXI-lite  *
 *               interface                          *
 * ------------------------------------------------ *
 * Revisions                                        *
 *     v1      : Inital version (uart module: v1.6) *
 * ------------------------------------------------ */
  module uart_tx_v1_0 #
  ( 
    //Customization Parameters
    parameter BUFFER_SIZE = 8,
    parameter AXI_CLOCK_PERIOD = 10,

    //Default UART Configurations
    parameter DEFAULT_DATA_SIZE = 1,
    parameter DEFAULT_STOP_BIT = 0,
    parameter DEFAULT_PARTY_EN = 0,
    parameter DEFAULT_PARTY = 0,
    parameter DEFAULT_BASECLK = 1,
    parameter DEFAULT_DIVRATIO = 2,

    //Register Map
    parameter OFFSET_TX_BUFF = 0,
    parameter OFFSET_CONFIG = 4,
    parameter OFFSET_STATUS = 8,
    parameter OFFSET_TX_COUNT = 12,

    // Parameters of Axi Slave Bus Interface S_AXI
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
  )
  (
    output tx,
    output interrupt,

    // Ports of Axi Slave Bus
    input wire  s_axi_aclk,
    input wire  s_axi_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire [2:0] s_axi_awprot, //not implemented
    input wire  s_axi_awvalid,
    output wire  s_axi_awready,
    input wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,  //not implemented
    input wire  s_axi_wvalid,
    output wire  s_axi_wready,
    output wire [1:0] s_axi_bresp,
    output wire  s_axi_bvalid,
    input wire  s_axi_bready,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input wire [2:0] s_axi_arprot,  //not implemented
    input wire  s_axi_arvalid,
    output wire  s_axi_arready,
    output wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire  s_axi_rvalid,
    input wire  s_axi_rready
  );
    integer i;
    localparam RES_OKAY = 2'b00,
               RES_ERR  = 2'b10; //Slave error
    wire clk_uart, uart_enable, ready; //Module connections
    localparam FIFO_COUNTER_SIZE = BUFFER_SIZE;
    wire [FIFO_COUNTER_SIZE:0] Tx_awaiting;
    reg ready_d;
    always@(posedge s_axi_aclk) begin
      ready_d <= ready;
    end
    wire done_tx = ~ready_d & ready;

    reg blockingTx; //Config to block axi when buffer full
    wire tx_buffer_empty, tx_buffer_full; //Buffer stastus

    //Addresses
    localparam ADDRS_MASK = 5'h1F;
    wire [C_S_AXI_ADDR_WIDTH-1:0] write_address = s_axi_awaddr & ADDRS_MASK;
    wire [C_S_AXI_ADDR_WIDTH-1:0]  read_address = s_axi_araddr & ADDRS_MASK;


    //Internal Control signals
    wire config_free = ((write_address != OFFSET_CONFIG) | ready);
    wire buffer_free = ((write_address != OFFSET_TX_BUFF) | (~(blockingTx & tx_buffer_full) & ~done_tx));
    wire write = s_axi_awvalid & s_axi_wvalid & config_free & buffer_free;
    wire  read = s_axi_arvalid;
    wire  read_addr_valid =  (read_address == OFFSET_STATUS)  |  
                             (read_address == OFFSET_CONFIG)  |  
                             (read_address == OFFSET_TX_COUNT);
    wire write_addr_valid = (write_address == OFFSET_TX_BUFF) | 
                            (write_address == OFFSET_CONFIG);

    wire [C_S_AXI_DATA_WIDTH-1:0] data_to_write = s_axi_wdata; //renaming


    //Configurations
    reg data_size, parity_en, stop_bit_size, baseClock_freq, interrupt_en, clear_fifo;
    reg [1:0] parity_mode;
    reg [2:0] divRatio;
    /*
     *     _Bits_       _Reg_
     *      [11]       Blocking Tx
     *      [10]       clear_fifo (self clearing)
     *      [9]       baseClock_freq
     *     [8:6]       divRatio
     *     [5:4]      parity_mode
     *      [3]       parity_en
     *      [2]       data_size
     *      [1]       stop_bit_size
     *      [0]       interrupt_en
     */
    wire [C_S_AXI_DATA_WIDTH-1:0] config_reg = {
                                                blockingTx, //11
                                                clear_fifo, //10
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
        blockingTx <= 0;
        clear_fifo <= 0;
        divRatio <= DEFAULT_DIVRATIO;
        baseClock_freq <= DEFAULT_BASECLK;
        parity_mode <= DEFAULT_PARTY;
        parity_en <= DEFAULT_PARTY_EN;
        data_size <= DEFAULT_DATA_SIZE;
        stop_bit_size <= DEFAULT_STOP_BIT;
        interrupt_en <= 0;
      end else begin
        {blockingTx, clear_fifo,baseClock_freq,divRatio,parity_mode,parity_en,
        data_size,stop_bit_size,interrupt_en} <= (update_config) ? data_to_write : {blockingTx, 1'b0,baseClock_freq,divRatio,parity_mode,parity_en,
        data_size,stop_bit_size,interrupt_en};
      end
    end
    
    
    //Buffer
    wire [7:0] data;
    wire buffer_addressed = (write_address == OFFSET_TX_BUFF);
    wire write_buffer = buffer_addressed & write;
    fifo #(.DATA_WIDTH(8), .FIFO_LENGTH_SIZE(BUFFER_SIZE)) 
        tx_buffer(.clk(s_axi_aclk), 
                  .rst(~s_axi_aresetn|clear_fifo),
                  .fifo_empty(tx_buffer_empty),
                  .fifo_full(tx_buffer_full),
                  .data_i(data_to_write[7:0]),
                  .push(write_buffer),
                  .awaiting_count(Tx_awaiting),
                  .data_o(data),
                  .drop(done_tx));
    


    //Interrupt signal
    assign interrupt = interrupt_en & tx_buffer_empty;

    /*
     *     _Bits_       _Reg_
     *      [1]       Tx Buffer Full
     *      [0]       Tx Buffer Empty
     */
    //Status reg
    wire status_reg = {tx_buffer_full, //1
                       tx_buffer_empty}; //0


    wire send = ~tx_buffer_empty;


    uart_tx transmitter(.clk(s_axi_aclk),
                        .rst(~s_axi_aresetn|clear_fifo),
                        .tx(tx),
                        .clk_uart(clk_uart),
                        .uart_enable(uart_enable),
                        .data_size(data_size), //0: 7bit; 1: 8bit
                        .parity_en(parity_en),
                        .parity_mode(parity_mode), //11: odd; 10: even, 01: mark(1), 00: space(0)
                        .stop_bit_size(stop_bit_size), //0: 1bit; 1: 2bit
                        .data(data),
                        .ready(ready),
                        .send(send));
    uart_clk_gen #(AXI_CLOCK_PERIOD) 
                  clock_gen(.clk(s_axi_aclk),
                            .rst(~s_axi_aresetn),
                            .en(uart_enable),
                            .clk_uart(clk_uart),
                            .baseClock_freq(baseClock_freq), //0: 76,8kHz (13us) 1: 460,8kHz (2,17us)
                            .divRatio(divRatio)); //Higher the value lower the freq


    //AXI Signals
    //Write response
    reg s_axi_bvalid_hold, s_axi_bresp_MSB_hold;
    assign s_axi_bvalid = write | s_axi_bvalid_hold;
    assign s_axi_bresp = (s_axi_bvalid_hold) ? {s_axi_bresp_MSB_hold, 1'b0} :
        (~write_addr_valid | (buffer_addressed & tx_buffer_full)) ? RES_ERR : 
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
    wire  write_ch_ready = config_free & buffer_free & ~(s_axi_awvalid ^ s_axi_wvalid) & ~s_axi_bvalid_hold;
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
        default: readReg = 0;
      endcase
    end
  endmodule
