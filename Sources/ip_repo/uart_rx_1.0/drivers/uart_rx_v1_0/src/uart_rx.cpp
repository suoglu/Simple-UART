/*-----------------------------------------------*
 *  Title       : UART Rx Driver                 *
 *  Project     : Simple UART                    *
 *-----------------------------------------------*
 *  File        : uart_tx.cpp                    *
 *  Author      : Yigit Suoglu                   *
 *  License     : EUPL-1.2                       *
 *  Last Edit   : 30/11/2021                     *
 *-----------------------------------------------*
 *  Description : SW driver for UART transmitter *
 *-----------------------------------------------*/
#include "uart_rx.h"

#ifdef XPAR_UART_RX_S_AXI_BASEADDR
  uart_rx::uart_rx():
    rx(reinterpret_cast<unsigned long*>(XPAR_UART_RX_S_AXI_BASEADDR)),
    config(reinterpret_cast<unsigned long*>(XPAR_UART_RX_S_AXI_BASEADDR+4u)),
    status(reinterpret_cast<unsigned long*>(XPAR_UART_RX_S_AXI_BASEADDR+8u)),
    rx_waiting(reinterpret_cast<unsigned long*>(XPAR_UART_RX_S_AXI_BASEADDR+12u)){
  }
#elif defined(XPAR_UART_RX_0_S_AXI_BASEADDR)
  uart_rx::uart_rx():
    rx(reinterpret_cast<unsigned long*>(XPAR_UART_RX_0_S_AXI_BASEADDR)),
    config(reinterpret_cast<unsigned long*>(XPAR_UART_RX_0_S_AXI_BASEADDR+4u)),
    status(reinterpret_cast<unsigned long*>(XPAR_UART_RX_0_S_AXI_BASEADDR+8u)),
    rx_waiting(reinterpret_cast<unsigned long*>(XPAR_UART_RX_0_S_AXI_BASEADDR+12u)){
  }
#endif

uart_rx::uart_rx(unsigned long base_address):
  rx(reinterpret_cast<unsigned long*>(base_address)),
  config(reinterpret_cast<unsigned long*>(base_address+4u)),
  status(reinterpret_cast<unsigned long*>(base_address+8u)),
  rx_waiting(reinterpret_cast<unsigned long*>(base_address+12u)){
}

uart_rx::uart_rx(unsigned long base_address, unsigned long offset_status, unsigned long offset_config, unsigned long offset_rx_buff, unsigned long offset_rx_count):
  rx(reinterpret_cast<unsigned long*>(base_address+offset_rx_buff)),
  config(reinterpret_cast<unsigned long*>(base_address+offset_config)),
  status(reinterpret_cast<unsigned long*>(base_address+offset_status)),
  rx_waiting(reinterpret_cast<unsigned long*>(base_address+offset_rx_count)){
}

unsigned char uart_rx::receive(){
  return static_cast<unsigned char>(*rx);
}

unsigned char uart_rx::receive(rx_error &error){
  unsigned long buff = *rx & 0x3FFul;
  error = static_cast<rx_error>((buff >> 8) & 0x3ul);
  return static_cast<unsigned char>(buff);
}

unsigned char uart_rx::receive(bool &frame_error, bool &crc_error){
  unsigned long buff = *rx & 0x3FFul;
  frame_error = ((buff & (FRAME_ERR << 8)) != 0ul);
  crc_error = ((buff & (CRC_ERR << 8)) != 0ul);
  return static_cast<unsigned char>(buff);
}

unsigned long uart_rx::waitingInBuffer(){
  return *rx_waiting;
}

unsigned long uart_rx::getStatus(){
  return *status;
}

unsigned long uart_rx::getConfig(){
  return *config;
}

uart_rx::rx_error uart_rx::getErrors(){
  return static_cast<rx_error>((getStatus() >> 2) & 0x7ul);
}

bool uart_rx::hasErrorBuffer(){
  return (((getStatus() >> 5) & 0x1ul) == 0x1ul);
}

void uart_rx::setConfig(unsigned long conf){
  *config = conf;
}

bool uart_rx::isFull(){
  return (((getStatus() >> 1) & 0x1ul) == 0x1ul);
}

bool uart_rx::isEmpty(){
  return ((getStatus() & 0x1ul) == 0x1ul);
}

void uart_rx::interrupt_enable(bool enable){
  unsigned long conf = getConfig();
  if(enable){
    setConfig(conf | 0x1ul);
  }else{
    setConfig(conf & ~0x1ul);
  }
}

void uart_rx::errorBuffer_enable(bool enable){
  unsigned long conf = getConfig();
  if(enable){
    setConfig(conf | 0x800ul);
  }else{
    setConfig(conf & ~0x800ul);
  }
}

void uart_rx::clearBuffer(){
  setConfig(getConfig() | 0x400ul);
}

void uart_rx::parityEnable(bool enable){
  unsigned long conf = getConfig();
  if(enable){
    setConfig(conf | 0x8ul);
  }else{
    setConfig(conf & ~0x8ul);
  }
}

void uart_rx::parityEnable(parity par, bool enable){
  unsigned long conf = getConfig();
  if(enable){
    conf|=0x8ul;
  }else{
    conf&=~0x8ul;
  }
  setConfig((conf & ~0x30ul) | static_cast<unsigned long>(par << 4));
}

void uart_rx::parityChange(parity par){
  setConfig((getConfig() & ~0x30ul) | static_cast<unsigned long>(par << 4));
}

void uart_rx::dataBitChange(databits bit_size){
  setConfig((getConfig() & ~0x4ul) | static_cast<unsigned long>(bit_size << 2));
}

void uart_rx::stopBitChange(stopbits bit_size){
  setConfig((getConfig() & ~0x2ul) | static_cast<unsigned long>(bit_size << 1));
}

void uart_rx::bitsChange(databits dbit_size, stopbits sbit_size){
  setConfig((getConfig() & ~0x6ul) | static_cast<unsigned long>(sbit_size << 1) | static_cast<unsigned long>(dbit_size << 2));
}

void uart_rx::setBaudRate(unsigned char bRate){
  setConfig((getConfig() & ~0x3C0ul) | static_cast<unsigned long>(bRate << 6));
}

void uart_rx::setBaudRate(bool fastMainClk, unsigned char divRatio){
  divRatio&=0x7ul; //Clear MSB, it is not valid for divRatio 
  if (fastMainClk){
    divRatio+=0x8ul;
  }
  setBaudRate(divRatio);
}

void uart_rx::setBaudRate(baud_rate bRate){
  setBaudRate(static_cast<unsigned char>(bRate));
}

uart_rx::baud_rate uart_rx::getBaudRate(){
  return static_cast<baud_rate>((getConfig() >> 6) & 0xFul);
}
