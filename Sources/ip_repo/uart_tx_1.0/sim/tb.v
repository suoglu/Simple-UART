`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2021 11:11:12 AM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb(

  );
  localparam C_S_AXI_ADDR_WIDTH = 32,
             C_S_AXI_DATA_WIDTH = 32,
             OFFSET_TX_BUFF = 0,
             OFFSET_CONFIG = 4,
             OFFSET_STATUS = 8;
  wire tx;
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
  
  //generate clock
  reg s_axi_aclk;
  always begin
      s_axi_aclk = 0;
      forever #5 s_axi_aclk = ~s_axi_aclk; //100MHz
  end

  uart_tx_v1_0 uut(
    .tx(tx),
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
  integer i;
  wire uartClock_rx, uartEn_rx, err_crc, err_frame, new_data;
  wire [7:0] data_rx;
  reg helper_stop;
  always begin
    helper_stop = uut.stop_bit_size;
    forever begin
      @(posedge s_axi_aclk); #5;
      helper_stop = uut.stop_bit_size;
    end
  end
 
  uart_rx helper(.clk(s_axi_aclk),
                 .rst(~s_axi_aresetn),
                 .rx(tx), 
                 .clk_uart(uartClock_rx), 
                 .uart_enable(uartEn_rx), 
                 .data_size(uut.data_size), 
                 .parity_en(uut.parity_en), 
                 .parity_mode(uut.parity_mode), 
                 .stop_bit_size(helper_stop), 
                 .data(data_rx), 
                 .error_parity(err_crc), 
                 .error_frame(err_frame),
                 .ready(),
                 .newData(new_data));

  uart_clk_gen clkGenUART_rx(.clk(s_axi_aclk),
                             .rst(~s_axi_aresetn),
                             .en(uartEn_rx),
                             .clk_uart(uartClock_rx),
                             .baseClock_freq(uut.baseClock_freq), 
                             .divRatio(uut.divRatio));

  
  initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0,tb);
  end

  initial begin
    s_axi_aresetn = 1;
    s_axi_awaddr = OFFSET_TX_BUFF;
    s_axi_awvalid = 0;
    s_axi_wdata = 32'hAA;
    s_axi_wvalid = 0;
    s_axi_araddr = OFFSET_STATUS;
    s_axi_arvalid = 0;
    s_axi_rready = 1;
    #1;
    s_axi_aresetn = 0;
    @(posedge s_axi_aclk); #1;
    s_axi_aresetn = 1;
    @(posedge s_axi_aclk); #1;
    state = "Send one";
    s_axi_awvalid = 1;
    s_axi_wvalid = 1;
    @(posedge s_axi_aclk); #1;
    fork
      begin
        while(s_axi_awready == 0) begin
          @(posedge s_axi_aclk); #1;
        end
        s_axi_awvalid = 0;
      end
      begin
        while(s_axi_wready == 0) begin
          @(posedge s_axi_aclk); #1;
        end
        s_axi_wvalid = 0;
      end
    join
    @(posedge s_axi_aclk); #1;
    s_axi_arvalid = 1;
    @(negedge new_data); #1;
    repeat(2) @(posedge s_axi_aclk); #1;
    state = "Fill buffer";
    s_axi_wvalid = 1;
    s_axi_awvalid = 1;
    for (i = 0; i < 68; i=i+1) begin
      s_axi_wdata = i;
      @(posedge s_axi_aclk); #1;
    end
    s_axi_wvalid = 0;
    s_axi_awvalid = 0;
    repeat(20) @(negedge new_data); #1;
    s_axi_wvalid = 1;
    s_axi_awvalid = 1;
    s_axi_wdata = 69;
    @(posedge s_axi_aclk); #1;
    s_axi_wvalid = 0;
    s_axi_awvalid = 0;
    s_axi_arvalid = 1;
    while((s_axi_rdata&32'h1) != 32'h1) begin
      @(posedge s_axi_aclk); #1;
    end
    s_axi_arvalid = 0;
    repeat(4) @(posedge s_axi_aclk); #1;
    state = "Ch configs";
    s_axi_awaddr = OFFSET_CONFIG;
    s_axi_wdata = 32'h84D;
    s_axi_wvalid = 1;
    s_axi_awvalid = 1;
    @(posedge s_axi_aclk); #1;
    s_axi_awaddr = OFFSET_TX_BUFF;
    for (i = 0; i < 68; i=i+1) begin
      s_axi_wdata = i + 32'b1000_0000;
      @(posedge s_axi_aclk); #1;
      while(s_axi_wready == 0) begin
        @(posedge s_axi_aclk); #1;
      end
    end
    s_axi_wvalid = 0;
    s_axi_awvalid = 0;
    s_axi_arvalid = 1;
    while((s_axi_rdata&32'h1) != 32'h1) begin
      @(posedge s_axi_aclk); #1;
    end
    s_axi_arvalid = 0;
    repeat(2) @(posedge s_axi_aclk); #1;
    state = "Ch configs in Tx";
    s_axi_wvalid = 1;
    s_axi_awvalid = 1;
    s_axi_wdata = 32'hba;
    @(posedge s_axi_aclk); #1;
    s_axi_wdata = 32'hce;
    @(posedge s_axi_aclk); #1;
    s_axi_wvalid = 0;
    s_axi_awvalid = 0;
    repeat(10) @(posedge s_axi_aclk); #1
    ;s_axi_wvalid = 1;
    s_axi_awvalid = 1;
    s_axi_wdata = 32'h3;
    s_axi_awaddr = OFFSET_CONFIG;
    @(posedge s_axi_aclk); #1;
    fork
      begin
        while(s_axi_awready == 0) begin
          @(posedge s_axi_aclk); #1;
        end
        @(posedge s_axi_aclk); #1;
        s_axi_awvalid = 0;
      end
      begin
        while(s_axi_wready == 0) begin
          @(posedge s_axi_aclk); #1;
        end
        @(posedge s_axi_aclk); #1;
        s_axi_wvalid = 0;
      end
    join
    s_axi_wvalid = 0;
    s_axi_awvalid = 0;
    @(posedge interrupt);
    repeat(2) @(posedge s_axi_aclk); #1;
    state = "Clear Buffer";
    s_axi_wvalid = 1;
    s_axi_awvalid = 1;
    s_axi_awaddr = OFFSET_TX_BUFF;
    s_axi_wdata = 32'h55;
    @(posedge s_axi_aclk); #1;
    s_axi_wdata = 32'h66;
    @(posedge s_axi_aclk); #1;
    s_axi_wdata = 32'h77;
    @(posedge s_axi_aclk); #1;
    s_axi_awaddr = OFFSET_CONFIG;
    s_axi_wdata = 32'h403;
    @(posedge s_axi_aclk); #1;
    fork
      begin
        while(s_axi_awready == 0) begin
          @(posedge s_axi_aclk); #1;
        end
        @(posedge s_axi_aclk); #1;
        s_axi_awvalid = 0;
      end
      begin
        while(s_axi_wready == 0) begin
          @(posedge s_axi_aclk); #1;
        end
        @(posedge s_axi_aclk); #1;
        s_axi_wvalid = 0;
      end
    join
    @(posedge interrupt);
    //@(posedge new_data);
    repeat(4) @(posedge s_axi_aclk); #1;
    $finish;
  end
  
endmodule
