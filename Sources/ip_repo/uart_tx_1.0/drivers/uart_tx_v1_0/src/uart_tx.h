/*-----------------------------------------------*
 *  Title       : UART Tx Driver                 *
 *  Project     : Simple UART                    *
 *-----------------------------------------------*
 *  File        : uart_tx.h                      *
 *  Author      : Yigit Suoglu                   *
 *  License     : EUPL-1.2                       *
 *  Last Edit   : 24/10/2021                     *
 *-----------------------------------------------*
 *  Description : SW driver for UART transmitter *
 *-----------------------------------------------*/
#ifndef UART_TX_H
#define UART_TX_H

#include "xparameters.h"

enum baud_rate : unsigned short {
  com76k8, //0
  com38k4, //1
  com19k2, //2
  com9k6, //3
  com4k8, //4
  com2k4, //5
  com1k2, //6
  com600, //7
  com460k8, //8
  com230k4, //9
  com115k2, //10
  com57k6, //11
  com28k8, //12
  com14k4, //13
  com7k2, //14
  com3k6
};

enum parity : unsigned char {
  space,
  mark,
  even,
  odd
};

enum databits : unsigned char {
  bit7,
  bit8
};

enum stopbits : unsigned char {
  bit1,
  bit2
};

class uart_tx{
private:
  unsigned long* tx;
  volatile unsigned long* config;
  volatile unsigned long* status;
  volatile unsigned long* tx_waiting;
public:
  uart_tx();
  uart_tx(unsigned long base_address);
  void send(unsigned char data);
  unsigned long waitingInBuffer();
  unsigned long getStatus();
  unsigned long getConfig();
  void setConfig(unsigned long conf);
  bool isFull();
  bool isEmpty();
  void interrupt_enable(bool enable = true);
  void clearBuffer();
  void blockingTx(bool enable = true);
  void parityEnable(bool enable = true);
  void parityEnable(parity par, bool enable = true);
  void parityChange(parity par);
  void dataBitChange(databits bit_size);
  void stopBitChange(stopbits bit_size);
  void bitsChange(databits dbit_size, stopbits sbit_size);
  void setBaudRate(unsigned char bRate);
  void setBaudRate(bool fastMainClk, unsigned char divRatio);
  void setBaudRate(baud_rate bRate);
  baud_rate getBaudRate();
};

#endif // UART_TX_H
