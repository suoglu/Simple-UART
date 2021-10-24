/*-----------------------------------------------*
 *  Title       : UART Tx Driver                 *
 *  Project     : Simple UART                    *
 *-----------------------------------------------*
 *  File        : uart_tx.cpp                    *
 *  Author      : Yigit Suoglu                   *
 *  License     : EUPL-1.2                       *
 *  Last Edit   : 24/10/2021                     *
 *-----------------------------------------------*
 *  Description : SW driver for UART transmitter *
 *-----------------------------------------------*/
#include "uart_tx.h"

uart_tx::uart_tx():
  tx(reinterpret_cast<unsigned long*>(XPAR_UART_TX_0_S_AXI_BASEADDR)),
  config(reinterpret_cast<unsigned long*>(XPAR_UART_TX_0_S_AXI_BASEADDR+4u)),
  status(reinterpret_cast<unsigned long*>(XPAR_UART_TX_0_S_AXI_BASEADDR+8u)),
  tx_waiting(reinterpret_cast<unsigned long*>(XPAR_UART_TX_0_S_AXI_BASEADDR+12u)){
}

uart_tx::uart_tx(unsigned long base_address):
  tx(reinterpret_cast<unsigned long*>(base_address)),
  config(reinterpret_cast<unsigned long*>(base_address+4u)),
  status(reinterpret_cast<unsigned long*>(base_address+8u)),
  tx_waiting(reinterpret_cast<unsigned long*>(base_address+12u)){
}

void uart_tx::send(unsigned char data){
  *tx = static_cast<unsigned long>(data);
}

unsigned long uart_tx::waitingInBuffer(){
  return *tx_waiting;
}

unsigned long uart_tx::getStatus(){
  return *status;
}

unsigned long uart_tx::getConfig(){
  return *config;
}

void uart_tx::setConfig(unsigned long conf){
  *config = conf;
}

bool uart_tx::isFull(){
  return (getStatus() & 0x2ul) == 0x2ul;
}

bool uart_tx::isEmpty(){
  return (getStatus() & 0x1ul) == 0x1ul;
}

void uart_tx::interrupt_enable(bool enable){
  if(enable){
    *config |= 0x1ul;
  }else{
    *config &= 0xFFFFFFFEul;
  }
}

void uart_tx::clearBuffer(){
  *config |= 0x400ul;
}

void uart_tx::blockingTx(bool enable){
  if(enable){
    *config |= 0x800ul;
  }else{
    *config &= 0xFFFFF7FFul;
  }
}

void uart_tx::parityEnable(bool enable){
  if(enable){
    *config |= 0x8ul;
  }else{
    *config &= 0xFFFFFFF7ul;
  }
}

void uart_tx::parityEnable(parity par, bool enable){
  unsigned long config_hold;
  if(enable){
    config_hold = *config | 0x8ul;
  }else{
    config_hold = *config & 0xFFFFFFF7ul;
  }
  *config = (config_hold & 0xFFFFFFCFul) | (static_cast<unsigned long>(par)<<4);
}

void uart_tx::parityChange(parity par){
  *config = (*config & 0xFFFFFFCFul) | (static_cast<unsigned long>(par)<<4);
}

void uart_tx::dataBitChange(databits bit_size){
  *config = (*config & 0xFFFFFFFBul) | (static_cast<unsigned long>(bit_size)<<2);
}

void uart_tx::stopBitChange(stopbits bit_size){
  *config = (*config & 0xFFFFFFFDul) | (static_cast<unsigned long>(bit_size)<<1);
}

void uart_tx::bitsChange(databits dbit_size, stopbits sbit_size){
  *config = (*config & 0xFFFFFFF9ul) | (static_cast<unsigned long>(sbit_size)<<1) | (static_cast<unsigned long>(dbit_size)<<2);
}

void uart_tx::setBaudRate(unsigned char bRate){
  *config = (*config & 0xFFFFFC3Ful) | (bRate << 6);
}

void uart_tx::setBaudRate(baud_rate bRate){
  setBaudRate(static_cast<unsigned char>(bRate));
}

void uart_tx::setBaudRate(bool fastMainClk, unsigned char divRatio){
  unsigned char bRate = divRatio & 0x7;
  if(fastMainClk){
    bRate |= 0x4u;
  }
  setBaudRate(bRate);
}

baud_rate uart_tx::getBaudRate(){
  unsigned char bRate = static_cast<unsigned char>((*config >> 6) & 0xFu);
  return static_cast<baud_rate>(bRate);
}
