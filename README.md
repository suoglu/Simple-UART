# UART

## Contents of Readme

1. About
2. Universal Asynchronous Receiver-Transmitter (Brief information)
3. Standalone
   1. Modules
   2. IOs of Modules
   3. Bit rates
   4. Utilization
   5. Simulation
   6. Test
4. Status Information

[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/suoglu/uart)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/suoglu/Simple-UART)

---

## About

Set of simple modules to communicate via UART.

## Universal Asynchronous Receiver-Transmitter

From [Wikipedia](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter): A universal asynchronous receiver-transmitter (UART) is a computer hardware device for asynchronous serial communication in which the data format and transmission speeds are configurable. It sends data bits one by one, from the least significant to the most significant, framed by start and stop bits so that precise timing is handled by the communication channel.

## Standalone Modules

UART communication modules are included in [uart.v](Sources/uart.v). UART clock generation modules are included in [uart_clock.v](Sources/uart_clock.v).

Data always send LSB first.

**`uart_tx`**

* UART transmitter module
* Supports 7 and 8 bit transactions
* Supports even, odd, mark, space parities as well as no parity

**`uart_rx`**

* UART Receiver module
* Supports 7 and 8 bit transactions
* Supports even, odd, mark, space parities as well as no parity

**`uart_transceiver`**

* `uart_tx` and `uart_rx` bundled together, sharing same configurations
* Can transmit and receive simultaneously

**`uart_clk_gen`**

* Generates clock signal for UART transaction.
* Generated frequencies corresponds to some of the common bit rates.
* Works with various clock frequencies, controlled by input parameter.

**`uart_clk_gen_hs`**

* Generates higher frequency clock signal for UART transaction.
* Generated frequencies depends on input clock frequency, and does not corresponds to the common bit rates.

**`uart_clk_en`**

* Generates clock signal from an external clock input.

**Important:** Transactions configurations should be kept constant during transaction. Changing data during transaction does not effect the data currently being transmitted.

## IOs of Standalone Modules

### `uart_transceiver` Ports

|   Port   | Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
|  `clk`   |   I   | 1 | System Clock |
|  `rst`   |   I   | 1 | System Reset |
| `tx` | O | 1 | Transmit line |
| `rx` | I | 1 | Receive line |
| `clk_uart_tx` | I | 1 | UART Transmitter Clock |
| `clk_uart_rx` | I | 1 | UART Receiver Clock |
| `uart_enable_tx` | O | 1 | Enable UART Transmitter Clock |
| `uart_enable_rx` | O | 1 | Enable UART Receiver Clock |
| `data_size` |I | 1 | Configure Data size; 7 or 8 bit |
| `parity_en` | I | 1 | Enable parity |
| `parity_mode` | I | 2 | Configure parity value |
| `stop_bit_size` | I | 1 | Configure Stop bit length; 1 or 2 bit |
| `data_i` | I | 8 | Transmit data |
| `data_o` | O | 8 | Receive data |
| `valid` | O | 1 | Parity check result, only when enabled (`parity_en`) |
| `newData` | O | 1 | One cycle high pulse to show new data is available |
| `ready_tx` | O | 1 | Transmitter is ready |
| `ready_rx` | I | 1 | Receiver is ready |
| `send` | I | 1 | Start transaction |

I: Input O: Output

### `uart_tx` Ports

|   Port   | Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
|  `clk`   |   I   | 1 | System Clock |
|  `rst`   |   I   | 1 | System Reset |
| `tx` | O | 1 | Transmit line |
| `clk_uart` | I | 1 | UART Transmitter Clock |
| `uart_enable` | O | 1 | Enable UART Transmitter Clock |
| `data_size` |I | 1 | Configure Data size; 7 or 8 bit |
| `parity_en` | I | 1 | Enable parity |
| `parity_mode` | I | 2 | Configure parity value |
| `stop_bit_size` | I | 1 | Configure Stop bit length; 1 or 2 bit |
| `data` | I | 8 | Transmit data |
| `ready` | O | 1 | Transmitter is ready |
| `send` | I | 1 | Start transaction |

I: Input O: Output

### `uart_rx` Ports

|   Port   | Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
|  `clk`   |   I   | 1 | System Clock |
|  `rst`   |   I   | 1 | System Reset |
| `rx` | I | 1 | Receive line |
| `clk_uart_` | I | 1 | UART Receiver Clock |
| `uart_enable` | O | 1 | Enable UART Receiver Clock |
| `data_size` |I | 1 | Configure Data size; 7 or 8 bit |
| `parity_en` | I | 1 | Enable parity |
| `parity_mode` | I | 2 | Configure parity value |
| `stop_bit_size` | I | 1 | Configure Stop bit length; 1 or 2 bit |
| `data` | O | 8 | Receive data |
| `valid` | O | 1 | Parity check result, only when enabled (`parity_en`) |
| `ready` | I | 1 | Receiver is ready
| `newData` | O | 1 | One cycle high pulse to show new data is available |

I: Input O: Output

### `uart_clk_gen` Ports

|   Port   | Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
|  `clk`   |   I   | 1 | System Clock |
|  `rst`   |   I   | 1 | System Reset |
| `en` | I | 1 | Enable clock generator |
| `clk_uart_` | O | 1 | UART Clock |
| `baseClock_freq` | I | 1 | Configure base clock; 76,8kHz (13us) or 460,8kHz (2,17us) |
| `divRatio` | I | 3 | Division ratio for UART clock |

I: Input O: Output

`CLOCK_PERIOD` parameter should be set to clock period in ns for correct UART clock generation. Default value is 10 ns, corresponds to 100 MHz.

### `uart_clk_gen_hs` Ports

|   Port   | Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
|  `clk`   |   I   | 1 | System Clock |
|  `rst`   |   I   | 1 | System Reset |
| `en` | I | 1 | Enable clock generator |
| `clk_uart_` | O | 1 | UART Clock |
| `divRatio` | I | 3 | Division ratio for UART clock |

I: Input O: Output

### `uart_clk_en` Ports

|   Port   | Type | Width |  Description |
| :------: | :----: | :----: |  ------    |
|  `clk`   |   I   | 1 | System Clock |
|  `rst`   |   I   | 1 | System Reset |
| `ext_uart_clk` | I | 1 | External Clock Input |
| `en` | I | 1 | Enable clock generator |
| `clk_uart_` | O | 1 | UART Clock |

I: Input O: Output

## Bit rates

Rates of transmitted bits is controlled with `clk_uart`. `clk_uart` kept high when IDLE. Data is read at positive edges and shifted at negative edges. UART modules take `clk_uart` as input. Signal `uart_enable` is used to enable `clk_uart`. Included `uart_clk_gen` and `uart_clk_gen_hs` modules can be used to generate `clk_uart`. Module `uart_clk_en` can be used with an external clock signal to generate `clk_uart`.

### `uart_clk_gen` bit rates

`uart_clk_gen` generates `clk_uart` by dividing a base clock. Frequency of base clock controlled by `baseClock_freq`.

---

*`baseClock_freq` = 0; 13 µs (76.92 kHz)*

| `divRatio` | Output Frequency | Output Period | Corresponding Common Baud Rate |
| :-----: | :-----: | :-----: | :-----: |
| 0 | 76.92 kHz | 13 µs | 76.8k |
| 1 | 38.46 kHz | 26 µs | 38.4k |
| 2 | 19.23 kHz | 52 µs | 19.2k |
| 3 | 9.61 kHz | 104 µs | 9.6k |
| 4 | 4.81 kHz | 208 µs | 4.8k |
| 5 | 2.4 kHz | 416 µs | 2.4k |
| 6 | 1.2 kHz | 832 µs | 1.2k |
| 7 | 600.1 Hz | 1.664 ms | 600 |

---

*`baseClock_freq` = 1; 2.16 µs (462.96 kHz):*
| `divRatio` | Output Frequency | Output Period | Corresponding Common Baud Rate |
| :-----: | :-----: | :-----: | :-----: |
| 0 | 462.96 kHz | 2.16 µs | 460.8k |
| 1 | 231.48 kHz | 4.32 µs | 230.4k |
| 2 | 115.74 kHz | 8.64 µs | 115.2k |
| 3 | 57.87 kHz | 17.28 µs | 57.6k |
| 4 | 28.94 kHz | 34.56 µs | 28.8k |
| 5 | 14.47 kHz | 69.12 µs | 14.4k |
| 6 | 7.23 kHz | 138.24 µs | 7.2k |
| 7 | 3.62 kHz | 276.48 µs | ? |

---

### `uart_clk_gen_hs`  bit rates

`uart_clk_gen_hs` generates `clk_uart` by dividing system clock. Following table provides output frequencies for 100 MHz system clock.

| `divRatio` | Output Frequency | Output Period |
| :-----: | :-----: | :-----: |
| 0 | 25 MHz | 40 ns |
| 1 | 12.5 MHz | 80 ns |
| 2 | 6.25 MHz | 160 ns |
| 3 | 3.125 MHz | 320 ns |

## Standalone Utilization

**(Synthesized) Utilization of `uart_tx` on Artix-7:**

* Slice LUTs: 20 (as Logic)
* Slice Registers: 19 (as Flip Flop)

**(Synthesized) Utilization of `uart_rx` on Artix-7:**

* Slice LUTs: 12 (as Logic)
* Slice Registers: 28 (as Flip Flop)

**(Synthesized) Utilization of `uart_transceiver` on Artix-7:**

* Slice LUTs: 32 (as Logic)
* Slice Registers: 47 (as Flip Flop)

**(Synthesized) Utilization of `uart_clk_gen` on Artix-7:**

* Slice LUTs: 24 (as Logic)
* Slice Registers: 18 (as Flip Flop)

**(Synthesized) Utilization of `uart_clk_gen_hs` on Artix-7:**

* Slice LUTs: 7 (as Logic)
* Slice Registers: 5 (as Flip Flop)

**(Synthesized) Utilization of `uart_clk_en` on Artix-7:**

* Slice LUTs: 1 (as Logic)
* Slice Registers: 1 (as Flip Flop)

## Standalone Simulation

Transmitter ([sim_tx.v](Simulation/sim_tx.v)) and receiver ([sim_rx.v](Simulation/sim_rx.v)) modules are simulated individually, as well as clock generators ([sim_baud.v](Simulation/sim_baud.v)) in corresponding files.

## Standalone Test

UART modules are tested on [Digilent Basys 3](https://reference.digilentinc.com/reference/programmable-logic/basys-3/reference-manual) with [test.v](Test/standalone/test.v). [design_uart_bd.tcl](Test/design_uart_bd.tcl) can be use to generate test block design automatically. `Rx` and `Tx` signals connected to [Digilent Digital Discovery](https://reference.digilentinc.com/reference/instrumentation/digital-discovery/start) via JB pins. Received and send data connected to seven segment displays. For testing, UART Send & Receive mode of protocol analyzer is used. Modules only tested in 9600 and 115200 bit rates. Both 7 bit and 8 bit data sizes with all possible parity configurations tested.

## Status Information

### Standalone

**Last simulation:** 23 May 2021, with [Vivado Simulator](https://www.xilinx.com/products/design-tools/vivado/simulator.html).

**Last test:** 16 December 2020, on [Digilent Basys 3](https://reference.digilentinc.com/reference/programmable-logic/basys-3/reference-manual).
