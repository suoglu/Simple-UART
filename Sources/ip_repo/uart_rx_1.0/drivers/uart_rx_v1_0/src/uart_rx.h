/*-----------------------------------------------*
 *  Title       : UART Rx Driver                 *
 *  Project     : Simple UART                    *
 *-----------------------------------------------*
 *  File        : uart_rx.h                      *
 *  Author      : Yigit Suoglu                   *
 *  License     : EUPL-1.2                       *
 *  Last Edit   : 20/11/2021                     *
 *-----------------------------------------------*
 *  Description : SW driver for UART Receiver    *
 *-----------------------------------------------*/
#ifndef UART_RX_H
#define UART_RX_H

#include "xparameters.h"

class uart_rx{
  private:
    unsigned long* rx;
    volatile unsigned long* config;
    volatile unsigned long* status;
    volatile unsigned long* rx_waiting;
  public:
    #if defined(XPAR_UART_RX_0_S_AXI_BASEADDR) or defined(XPAR_UART_RX_S_AXI_BASEADDR)
      uart_rx();
    #endif
    uart_rx(unsigned long base_address);

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

    enum rx_error : unsigned char {
        NO_ERROR,
        FRAME_ERR,
        CRC_ERR,
        FRAME_CRC_ERR,
        OVERRUN_ERR,
        OVERRUN_FRAME_ERR,
        OVERRUN_CRC_ERR,
        OVERRUN_CRC_FRAME_ERR
    };

    unsigned char receive();
    unsigned char receive(rx_error & error);
    unsigned char receive(bool & frame_error, bool & crc_error);
    unsigned long waitingInBuffer();
    unsigned long getStatus();
    unsigned long getConfig();
    rx_error getErrors();
    bool hasErrorBuffer();
    void setConfig(unsigned long conf);
    bool isFull();
    bool isEmpty();
    void interrupt_enable(bool enable = true);
    void errorBuffer_enable(bool enable = true);
    void clearBuffer();
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
#endif // UART_RX_H
