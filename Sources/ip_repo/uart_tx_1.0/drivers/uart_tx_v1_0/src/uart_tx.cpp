/*-----------------------------------------------*
 *  Title       : UART Tx Driver                 *
 *  Project     : Simple UART                    *
 *-----------------------------------------------*
 *  File        : uart_tx.cpp                    *
 *  Author      : Yigit Suoglu                   *
 *  License     : EUPL-1.2                       *
 *  Last Edit   : 21/10/2021                     *
 *-----------------------------------------------*
 *  Description : SW driver for UART transmitter *
 *-----------------------------------------------*/
#include "uart_tx.h"

uart_tx::uart_tx():
tx(reinterpret_cast<unsigned long*>(XPAR_UART_TX_0_S_AXI_BASEADDR)),
config(reinterpret_cast<unsigned long*>(XPAR_UART_TX_0_S_AXI_BASEADDR+4)),
status(reinterpret_cast<unsigned long*>(XPAR_UART_TX_0_S_AXI_BASEADDR+8)),
tx_waiting(reinterpret_cast<unsigned long*>(XPAR_UART_TX_0_S_AXI_BASEADDR+12)){
}

uart_tx::uart_tx(unsigned long base_address):
tx(reinterpret_cast<unsigned long*>(base_address)),
config(reinterpret_cast<unsigned long*>(base_address+4)),
status(reinterpret_cast<unsigned long*>(base_address+8)),
tx_waiting(reinterpret_cast<unsigned long*>(base_address+12)){
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
  return (getStatus() & 0x2) == 0x2;
}

bool uart_tx::isEmpty(){
  return (getStatus() & 0x1) == 0x1;
}

void uart_tx::interrupt_enable(bool enable){
  if(enable){
    *config |= 0x1;
  }else{
    *config &= 0xFFFFFFFE;
  }
}

void uart_tx::clearBuffer(){
  *config |= 0x400;
}

void uart_tx::blockingTx(bool enable){
  if(enable){
    *config |= 0x800;
  }else{
    *config &= 0xFFFFF7FF;
  }
}

void uart_tx::parityEnable(bool enable){
  if(enable){
    *config |= 0x8;
  }else{
    *config &= 0xFFFFFFF7;
  }
}

void uart_tx::parityEnable(parity par, bool enable){
  unsigned long config_hold;
  if(enable){
    config_hold = *config | 0x8;
  }else{
    config_hold = *config & 0xFFFFFFF7;
  }
  *config = (config_hold & 0xFFFFFFCF) | (static_cast<unsigned long>(par)<<4);
}

void uart_tx::parityChange(parity par){
  *config = (*config & 0xFFFFFFCF) | (static_cast<unsigned long>(par)<<4);
}

void uart_tx::dataBitChange(databits bit_size){
  *config = (*config & 0xFFFFFFFB) | (static_cast<unsigned long>(bit_size)<<2);
}

void uart_tx::stopBitChange(stopbits bit_size){
  *config = (*config & 0xFFFFFFFD) | (static_cast<unsigned long>(bit_size)<<1);
}

void uart_tx::bitsChange(databits dbit_size, stopbits sbit_size){
  *config = (*config & 0xFFFFFFF9) | (static_cast<unsigned long>(sbit_size)<<1) | (static_cast<unsigned long>(dbit_size)<<2);
}
