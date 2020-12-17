# UART

## Contents of Readme

1. About
2. Modules
3. IOs of Modules
4. Bit rates
5. Universal Asynchronous Receiver-Rransmitter (Brief information)
6. Simulation
7. Test
8. Status Information

[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/suoglu/uart)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/suoglu/Simple-UART)

---

## About

Set of simple modules to communicate via UART.

## Modules

UART communication modules and two clock frequency generator modules are included in [uart.v](Sources/uart.v).

**`uart_tx`**

* UART transmitter module
* Supports 7 and 8 bit transactions
* Supports even, odd, mark, space parities as well as no parity

**`uart_rx`**

* UART Receiver module
* Supports 7 and 8 bit transactions
* Supports even, odd, mark, space parities as well as no parity

**`uart_dual`**

* `uart_tx` and `uart_rx` bundled together, sharing same configurations
* Can transmit and receive simultaneously

**`baudRGen`**

* Generates clock signel for UART transaction.
* Genarated frequencies corresponds to some of the common bit rates.
* Works with various clock frequencies, controlled by input parameter.

**`baudRGen_HS`**

* Generates higher frequency clock signel for UART transaction.
* Genarated frequencies depends on input clock frequency, and does not corresponds to the common bit rates.

**Important:** Transactions configurations should be kept constant during transaction. Changing data during transaction does not effect the data currently being transmitted.

## IOs of Modules

|   Port   | Module | Type | Width |  Description |
| :------: | :----: | :----: | :----: |  ------    |
|  `clk`   | T/R/C  |   I   | 1 | System Clock |
|  `rst`   | T/R/C  |   I   | 1 | System Reset |
| `baseClock_freq` | T/R/C | I | 1 | Configure base clock; 76,8kHz (13us) or 460,8kHz (2,17us) |
| `divRatio` | T/R/C  | I | 3 | Divison ratio for UART clock |
| `data_size` | T/R | I | 1 | Configure Data size; 7 or 8 bit |
| `parity_en` | T/R | I | 1 | Enable parity |
| `parity_mode` | T/R | I | 2 | Configure parity value |
| `stop_bit_size` | T | I | 1 | Configure Stop bit length; 1 or 2 bit |
| `data` | T/R | I/O | 8 | Transmisson data |
| `ready` | T/R | O | 1 | Modules are ready new operation |
| `send` | T | I | 1 | Start transaction |
| `tx` | T | O | 1 | Transmit line |
| `rx` | R | I | 1 | Receive line |
| `uartClock` | T/R/C | O | 1 | UART clock, can be used for debug or sync |
| `valid` | R | O | 1 | Parity check result, only when enabled (`parity_en`) |
| `newData` | R | O | 1 | One cycle high pulse to show new data is available |
| `en` | C| I | 1 | Enable clock generator |

T: Transmitter  R: Receiver C: Clock generators I: Input  O: Output

`inCLK_PERIOD_ns` parameter should be set to clock period in ns for correct UART clock generation. Default value is 10 ns, corresponds to 100 MHz.

## Bit rates

Rates of transmitted bits is controlled with `uartClock`. `uartClock` kept high when IDLE. Data is read at positive edges and shifted at negative edges. UART modules works with `baudRGen` by default, but `baudRGen_HS` can also be used if requested.

**`baudRGen`:**

`baudRGen` generates `uartClock` by dividing a base clock. Freqency of base clock controlled by `baseClock_freq`.

---

*`baseClock_freq` = 0; 13 µs (76.92 kHz)*

| `divRatio` | Output Frequency | Output Period |
| :-----: | :-----: | :-----: |
| 0 | 76.92 kHz | 13 µs |
| 1 | 38.46 kHz | 26 µs |
| 2 | 19.23 kHz | 52 µs |
| 3 | 9.61 kHz | 104 µs |
| 4 | 4.81 kHz | 208 µs |
| 5 | 2.4 kHz | 416 µs |
| 6 | 1.2 kHz | 832 µs |
| 7 | 600.1 Hz | 1.664 ms |

---

*`baseClock_freq` = 1; 2.16 µs (462.96 kHz):*
| `divRatio` | Output Frequency | Output Period |
| :-----: | :-----: | :-----: |
| 0 | 462.96 kHz | 2.16 µs |
| 1 | 231.48 kHz | 4.32 µs |
| 2 | 115.74 kHz | 8.64 µs |
| 3 | 57.87 kHz | 17.28 µs |
| 4 | 28.94 kHz | 34.56 µs |
| 5 | 14.47 kHz | 69.12 µs |
| 6 | 7.23 kHz | 138.24 µs |
| 7 | 3.62 kHz | 276.48 µs |

---

**`baudRGen_HS`:**

`baudRGen_HS` generates `uartClock` by dividing system clock. Following table provides output frequencies for 100 MHz system clock.

| `divRatio` | Output Frequency | Output Period |
| :-----: | :-----: | :-----: |
| 0 | 25 MHz | 40 ns |
| 1 | 12.5 MHz | 80 ns |
| 2 | 6.25 MHz | 160 ns |
| 3 | 3.125 MHz | 320 ns |

## Universal Asynchronous Receiver-Transmitter

From [Wikipedia](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter): A universal asynchronous receiver-transmitter (UART) is a computer hardware device for asynchronous serial communication in which the data format and transmission speeds are configurable. It sends data bits one by one, from the least significant to the most significant, framed by start and stop bits so that precise timing is handled by the communication channel.

## Simulation

Transmitter ([sim_tx.v](Simulation/sim_tx.v)) and receiver ([sim_rx.v](Simulation/sim_rx.v)) modules are simulated individually, as well as clock generators ([sim_baud.v](Simulation/sim_baud.v)) in corresponding files.

## Test

UART modules are tested on [Digilent Basys 3](https://reference.digilentinc.com/reference/programmable-logic/basys-3/reference-manual) with [test.v](Test/test.v). `Rx` and `Tx` signals connected to [Digilent Digital Discovery](https://reference.digilentinc.com/reference/instrumentation/digital-discovery/start) via JB pins. Received and send data connected to seven segment displays. For testing, UART Send & Receive mode of protocol analyzer is used. Modules only tested in 9600 and 115200 bit rates. Both 7 bit and 8 bit data sizes with all possible parity configurations tested.

## Status Information

**Last simulation:** 16 December 2020, with [Vivado Simulator](https://www.xilinx.com/products/design-tools/vivado/simulator.html).

**Last test:** **Last test:** 16 December 2020, on [Digilent Basys 3](https://reference.digilentinc.com/reference/programmable-logic/basys-3/reference-manual).
