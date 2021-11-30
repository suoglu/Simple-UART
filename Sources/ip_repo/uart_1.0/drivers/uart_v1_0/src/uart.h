/*-----------------------------------------------*
 *  Title       : UART Driver                    *
 *  Project     : Simple UART                    *
 *-----------------------------------------------*
 *  File        : uart.h                         *
 *  Author      : Yigit Suoglu                   *
 *  License     : EUPL-1.2                       *
 *  Last Edit   : 30/11/2021                     *
 *-----------------------------------------------*
 *  Description : SW driver for UART             *
 *-----------------------------------------------*/

#ifndef UART_H
#define UART_H

#include "xparameters.h"

class uart{
  private:
    unsigned long* rx;
    unsigned long* tx;
    volatile unsigned long* config;
    volatile unsigned long* status;
    volatile unsigned long* rx_waiting;
    volatile unsigned long* tx_waiting;
  public:
    #if defined(XPAR_UART_0_S_AXI_BASEADDR) or defined(XPAR_UART_S_AXI_BASEADDR)
      uart();
    #endif
    uart(unsigned long base_address);
    uart(unsigned long base_address, unsigned long offset_status, unsigned long offset_config, unsigned long offset_rx_buff, unsigned long offset_rx_count, unsigned long offset_tx_buff, unsigned long offset_tx_count);

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

    enum buffer_type : unsigned char {
      receiver,
      transmitter,
      both
    };

    void send(unsigned char data);
    unsigned char receive();
    unsigned char receive(rx_error & error);
    unsigned char receive(bool & frame_error, bool & crc_error);
    unsigned long waitingInBuffer(buffer_type fifo);
    unsigned long getStatus();
    unsigned long getConfig();
    rx_error getErrors();
    bool hasErrorBuffer();
    void setConfig(unsigned long conf);
    bool isFull(buffer_type fifo);
    bool isEmpty(buffer_type fifo);
    void interrupt_enable(bool enable = true);
    void interrupt_enable(buffer_type buff, bool enable = true);
    void interrupt_ch_mode(buffer_type buff);
    void errorBuffer_enable(bool enable = true);
    void clearBuffer(buffer_type fifo);
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

#endif // UART_H
