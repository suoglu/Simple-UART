/*-----------------------------------------------*
 *  Title       : UART Driver                    *
 *  Project     : Simple UART                    *
 *-----------------------------------------------*
 *  File        : uart.cpp                       *
 *  Author      : Yigit Suoglu                   *
 *  License     : EUPL-1.2                       *
 *  Last Edit   : 30/11/2021                     *
 *-----------------------------------------------*
 *  Description : SW driver for UART transmitter *
 *-----------------------------------------------*/
#include "uart.h"

#ifdef XPAR_UART_S_AXI_BASEADDR
  uart::uart():
    rx(reinterpret_cast<unsigned long*>(XPAR_UART_S_AXI_BASEADDR)),
    tx(reinterpret_cast<unsigned long*>(XPAR_UART_S_AXI_BASEADDR+4u)),
    config(reinterpret_cast<unsigned long*>(XPAR_UART_S_AXI_BASEADDR+8u)),
    status(reinterpret_cast<unsigned long*>(XPAR_UART_S_AXI_BASEADDR+12u)),
    rx_waiting(reinterpret_cast<unsigned long*>(XPAR_UART_S_AXI_BASEADDR+16u)),
    tx_waiting(reinterpret_cast<unsigned long*>(XPAR_UART_S_AXI_BASEADDR+20u)){
  }
#elif defined(XPAR_UART_0_S_AXI_BASEADDR)
  uart::uart():
    rx(reinterpret_cast<unsigned long*>(XPAR_UART_0_S_AXI_BASEADDR)),
    tx(reinterpret_cast<unsigned long*>(XPAR_UART_0_S_AXI_BASEADDR+4u)),
    config(reinterpret_cast<unsigned long*>(XPAR_UART_0_S_AXI_BASEADDR+8u)),
    status(reinterpret_cast<unsigned long*>(XPAR_UART_0_S_AXI_BASEADDR+12u)),
    rx_waiting(reinterpret_cast<unsigned long*>(XPAR_UART_0_S_AXI_BASEADDR+16u)),
    tx_waiting(reinterpret_cast<unsigned long*>(XPAR_UART_0_S_AXI_BASEADDR+20u)){
  }
#endif

uart::uart(unsigned long base_address):
  rx(reinterpret_cast<unsigned long*>(base_address)),
  tx(reinterpret_cast<unsigned long*>(base_address+4u)),
  config(reinterpret_cast<unsigned long*>(base_address+8u)),
  status(reinterpret_cast<unsigned long*>(base_address+12u)),
  rx_waiting(reinterpret_cast<unsigned long*>(base_address+16u)),
  tx_waiting(reinterpret_cast<unsigned long*>(base_address+20u)){
}

uart::uart(unsigned long base_address, unsigned long offset_status, unsigned long offset_config, unsigned long offset_rx_buff, unsigned long offset_rx_count, unsigned long offset_tx_buff, unsigned long offset_tx_count):
  rx(reinterpret_cast<unsigned long*>(base_address+offset_rx_buff)),
  tx(reinterpret_cast<unsigned long*>(base_address+offset_tx_buff)),
  config(reinterpret_cast<unsigned long*>(base_address+offset_config)),
  status(reinterpret_cast<unsigned long*>(base_address+offset_status)),
  rx_waiting(reinterpret_cast<unsigned long*>(base_address+offset_rx_count)),
  tx_waiting(reinterpret_cast<unsigned long*>(base_address+offset_tx_count)){
}

void uart::send(unsigned char data){
  *tx = static_cast<unsigned long>(data);
}

unsigned char uart::receive(){
  return static_cast<unsigned char>(*rx);
}

unsigned char uart::receive(rx_error &error){
  unsigned long buff = *rx & 0x3FFul;
  error = static_cast<rx_error>((buff >> 8) & 0x3ul);
  return static_cast<unsigned char>(buff);
}

unsigned char uart::receive(bool &frame_error, bool &crc_error){
  unsigned long buff = *rx & 0x3FFul;
  frame_error = ((buff & (FRAME_ERR << 8)) != 0ul);
  crc_error = ((buff & (CRC_ERR << 8)) != 0ul);
  return static_cast<unsigned char>(buff);
}

unsigned long uart::waitingInBuffer(buffer_type fifo){
  switch(fifo) {
  case buffer_type::receiver:
    return *rx_waiting;
  case buffer_type::transmitter:
    return *tx_waiting;
  case buffer_type::both:
    return *rx_waiting + *tx_waiting;
  default:
    return 0xDEC0DEE3;
  }
}

unsigned long uart::getStatus(){
  return *status;
}

unsigned long uart::getConfig(){
  return *config;
}

uart::rx_error uart::getErrors(){
  return static_cast<rx_error>((getStatus() >> 4) & 0x7ul);
}

bool uart::hasErrorBuffer(){
  return ((getStatus() & 0x80ul) == 0x80ul);
}

void uart::setConfig(unsigned long conf){
  *config = conf;
}

bool uart::isFull(buffer_type fifo){
  switch(fifo) {
  case buffer_type::receiver:
    return ((getStatus() & 0x4ul) == 0x4ul);
  case buffer_type::transmitter:
    return ((getStatus() & 0x8ul) == 0x8ul);
  case buffer_type::both:
    return ((getStatus() & 0xCul) == 0xCul);
  default:
    return false;
  }
}

bool uart::isEmpty(buffer_type fifo){
  switch(fifo) {
  case buffer_type::receiver:
    return ((getStatus() & 0x1ul) == 0x1ul);
  case buffer_type::transmitter:
    return ((getStatus() & 0x2ul) == 0x2ul);
  case buffer_type::both:
    return ((getStatus() & 0x3ul) == 0x3ul);
  default:
    return false;
  }
}

void uart::interrupt_enable(bool enable){
  unsigned long conf = getConfig();
  if(enable){
    setConfig(conf | 0x1ul);
  }else{
    setConfig(conf & ~0x1ul);
  }
}

void uart::interrupt_enable(buffer_type buff, bool enable){
  unsigned long conf = (getConfig() & 0x3FFFul) | (static_cast<unsigned long>(buff) << 14);
  if(enable){
    setConfig(conf | 0x1ul);
  }else{
    setConfig(conf & ~0x1ul);
  }
}

void uart::interrupt_ch_mode(uart::buffer_type buff){
  setConfig((getConfig() & 0x3FFFul) | (static_cast<unsigned long>(buff) << 14));
}

void uart::errorBuffer_enable(bool enable){
  unsigned long conf = getConfig();
  if(enable){
    setConfig(conf | 0x2000ul);
  }else{
    setConfig(conf & ~0x2000ul);
  }
}

void uart::clearBuffer(buffer_type fifo){
  switch(fifo) {
  case buffer_type::receiver:
    setConfig(getConfig() | 0x800ul);
    break;
  case buffer_type::transmitter:
    setConfig(getConfig() | 0x400ul);
    break;
  case buffer_type::both:
    setConfig(getConfig() | 0xC00ul);
    break;
  }
}

void uart::blockingTx(bool enable){
  if(enable){
    *config |= 0x1000ul;
  }else{
    *config &= 0xFFFFEFFFul;
  }
}

void uart::parityEnable(bool enable){
  unsigned long conf = getConfig();
  if(enable){
    setConfig(conf | 0x8ul);
  }else{
    setConfig(conf & ~0x8ul);
  }
}

void uart::parityEnable(parity par, bool enable){
  unsigned long conf = getConfig();
  if(enable){
    conf|=0x8ul;
  }else{
    conf&=~0x8ul;
  }
  setConfig((conf & ~0x30ul) | static_cast<unsigned long>(par << 4));
}

void uart::parityChange(parity par){
  setConfig((getConfig() & ~0x30ul) | static_cast<unsigned long>(par << 4));
}

void uart::dataBitChange(databits bit_size){
  setConfig((getConfig() & ~0x4ul) | static_cast<unsigned long>(bit_size << 2));
}

void uart::stopBitChange(stopbits bit_size){
  setConfig((getConfig() & ~0x2ul) | static_cast<unsigned long>(bit_size << 1));
}

void uart::bitsChange(databits dbit_size, stopbits sbit_size){
  setConfig((getConfig() & ~0x6ul) | static_cast<unsigned long>(sbit_size << 1) | static_cast<unsigned long>(dbit_size << 2));
}

void uart::setBaudRate(unsigned char bRate){
  setConfig((getConfig() & ~0x3C0ul) | static_cast<unsigned long>(bRate << 6));
}

void uart::setBaudRate(bool fastMainClk, unsigned char divRatio){
  divRatio&=0x7ul; //Clear MSB, it is not valid for divRatio 
  if (fastMainClk){
    divRatio+=0x8ul;
  }
  setBaudRate(divRatio);
}

void uart::setBaudRate(baud_rate bRate){
  setBaudRate(static_cast<unsigned char>(bRate));
}

uart::baud_rate uart::getBaudRate(){
  return static_cast<baud_rate>((getConfig() >> 6) & 0xFul);
}
