`timescale 1 ns / 1 ps
/* ------------------------------------------------ *
 * Title       : UART Receiver IP Testbench         *
 * Project     : Simple UART                        *
 * ------------------------------------------------ *
 * File        : tb.v                               *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 20/11/2021                         *
 * ------------------------------------------------ *
 * Description : UART Receiver IP testbench         *
 * ------------------------------------------------ */


module tb();
  localparam C_S_AXI_ADDR_WIDTH = 4,
             C_S_AXI_DATA_WIDTH = 32,
             OFFSET_TX_BUFF = 0,
             OFFSET_CONFIG = 4,
             OFFSET_STATUS = 8;
  wire rx;
  wire interrupt;
  reg s_axi_aresetn;
  reg[C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr;
  reg[2:0] s_axi_awprot = 0;
  reg s_axi_awvalid;
  wire s_axi_awready;
  reg[C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata;
  reg[(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb = 0;
  reg s_axi_wvalid;
  wire s_axi_wready;
  wire[1:0] s_axi_bresp;
  wire s_axi_bvalid;
  reg s_axi_bready = 1;
  reg[C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr;
  reg[2:0] s_axi_arprot = 0;
  reg s_axi_arvalid;
  wire s_axi_arready;
  wire[C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata;
  wire[1:0] s_axi_rresp;
  wire s_axi_rvalid;
  reg s_axi_rready;
  
  reg[30*8:0] state = "setup";
  integer i;
  genvar g;
  
  //generate clock
  reg s_axi_aclk;
  always begin
      s_axi_aclk = 0;
      forever #5 s_axi_aclk = ~s_axi_aclk; //100MHz
  end

  uart_rx_v1_0 uut(
    .rx(rx),
    .interrupt(interrupt),
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready)
  );

  wire clk_uart, uart_enable, helper_ready;
  reg [7:0] helper_data;
  reg helper_send;

  uart_tx helper(
  .clk(s_axi_aclk),
  .rst(~s_axi_aresetn),
  .tx(rx),
  .clk_uart(clk_uart),
  .uart_enable(uart_enable),
  .data_size(uut.data_size), //0: 7bit; 1: 8bit
  .parity_en(uut.parity_en),
  .parity_mode(uut.parity_mode), //11: odd; 10: even, 01: mark(1), 00: space(0)
  .stop_bit_size(uut.stop_bit_size), //0: 1bit; 1: 2bit
  .data(helper_data),
  .ready(helper_ready),
  .send(helper_send));

  uart_clk_gen helper_clk(
    .clk(s_axi_aclk),
    .rst(~s_axi_aresetn),
    .en(uart_enable),
    .clk_uart(clk_uart),
    .baseClock_freq(uut.baseClock_freq), 
    .divRatio(uut.divRatio));

  initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0,tb);
    for (i=0; i<uut.rx_buffer.FIFO_LENGTH; i=i+1) begin
      $dumpvars((i+1),uut.rx_buffer.buffer[i]);
    end
  end

  initial begin
    for (i=0; i<uut.rx_buffer.FIFO_LENGTH; i=i+1) begin
      uut.rx_buffer.buffer[i] = 0;
    end
    s_axi_aresetn = 1;
    s_axi_awaddr = uut.OFFSET_CONFIG;
    s_axi_awvalid = 0;
    s_axi_wdata = 32'h0;
    s_axi_wvalid = 0;
    s_axi_araddr = uut.OFFSET_STATUS;
    s_axi_arvalid = 0;
    s_axi_rready = 1;
    helper_data = 8'h0;
    helper_send = 0;
    #1;
    s_axi_aresetn = 0;
    @(posedge s_axi_aclk); #1;
    s_axi_aresetn = 1;
    @(posedge s_axi_aclk); #1;
    state = "Receive data";
    for (i=0; i < 16; i=i+1) begin
      helper_data = i;
      helper_send = 1;
      while(helper_ready == 1) begin
        @(posedge s_axi_aclk); #1;
      end
      helper_send = 0;
      while(helper_ready == 0) begin
        @(posedge s_axi_aclk); #1;
      end
      @(posedge s_axi_aclk); #1;
    end
    repeat(2) @(posedge s_axi_aclk); #1;
    state = "Read status & counter";
    s_axi_araddr = uut.OFFSET_STATUS;
    s_axi_arvalid = 1;
    @(posedge s_axi_aclk); #1;
    s_axi_araddr = uut.OFFSET_RX_COUNT;
    @(posedge s_axi_aclk); #1;
    s_axi_arvalid = 0;
    repeat(2) @(posedge s_axi_aclk); #1;
    state = "Read Data";
    s_axi_araddr = uut.OFFSET_RX_BUFF;
    s_axi_arvalid = 1;
    repeat(5) @(posedge s_axi_aclk); #1;
    s_axi_arvalid = 0;
    repeat(2) @(posedge s_axi_aclk); #1;
    state = "Fill the buffer";
    for (i=0; i < 260; i=i+1) begin
      helper_data = i;
      helper_send = 1;
      while(helper_ready == 1) begin
        @(posedge s_axi_aclk); #1;
      end
      helper_send = 0;
      while(helper_ready == 0) begin
        @(posedge s_axi_aclk); #1;
      end
      @(posedge s_axi_aclk); #1;
    end
    repeat(2) @(posedge s_axi_aclk); #1;
    state = "Read status & counter";
    s_axi_araddr = uut.OFFSET_STATUS;
    s_axi_arvalid = 1;
    @(posedge s_axi_aclk); #1;
    s_axi_araddr = uut.OFFSET_RX_COUNT;
    @(posedge s_axi_aclk); #1;
    s_axi_arvalid = 0;
    repeat(2) @(posedge s_axi_aclk); #1;
    state = "Read Data";
    s_axi_araddr = uut.OFFSET_RX_BUFF;
    s_axi_arvalid = 1;
    while (uut.rx_buffer_empty == 0) begin
      @(posedge s_axi_aclk); #1;
    end
    s_axi_arvalid = 0;
    repeat(4) @(posedge s_axi_aclk); #1;
    $finish;
  end
endmodule