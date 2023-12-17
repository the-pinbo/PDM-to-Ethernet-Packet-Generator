# Nexys 4 DDR PDM-MIC ETHERNET FRAME GENERATOR

## Overview

This project involves the Nexys4DDR, which processes data from a built-in microphone using Pulse Density Modulation (PDM). It features digital filtering for decimation and resolution enhancement, audio data reverberation, Fast Fourier Transform (FFT) computation over the ethernet interface using 100 base T standard.

### Peripherals Used

- PDM microphone
- 10/100 Ethernet PHY

### Features

- **Audio Processing:** 16-bit resolution, 48KSPS sampling rate.
- **FFT Analysis:** FFT computation with 512 bins, visualizing the first 80 FFT bins on VGA and 30 bins on an LED strip.
- **LED Visualization:** WS2812 LED string displays the first 30 FFT bins.

## Prerequisites

### Hardware

- Nexys 4 DDR FPGA board
- Micro-USB cable
- Ethernet cable

### Software

- [Vivado Design Suite 2021.1+](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2022-1.html) _(Procedure may vary with other versions)_
- [Python (latest version)](https://www.python.org/downloads/)
- [Wireshark](https://www.wireshark.org/download.html)

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/the-pinbo/ddfpga-project.git
   ```

2. **Generate the Project**

   - Open Vivado.
   - Click `Run Tcl Script` in the tools window.
   - Navigate to `ddfpga-project/project` and select `efsm.tcl`.
   - Upgrade IPs if necessary via `Reports > Report IP Status`.
   - **Note:** Change MAC address before generating the bitstream.

3. **Viewing MAC Address**

   - **Linux:** Use `ifconfig -a` in terminal.
   - **Windows:** Use `ipconfig /all` in Command Prompt.

4. **Build the Project**

   - Use `Generate Bitstream` in Vivado.
   - Run Synthesis and Implementation steps.

5. **Program the Board**

   - Connect the FPGA board.
   - Use `Auto-Connect` in hardware manager.
   - Load the program with `program device`.

6. **Capture Packets**

   - Connect Ethernet from FPGA to computer.
   - Use Wireshark for packet analysis.
   - Save packets as `.pcap` for processing.

7. **Signal Processing with Python**

   - Set up a virtual environment and install dependencies.
   - Run `wireshark_analysis.ipynb` or `receive_wav.py` (Linux only).

8. **Play Back Audio**
   - Enjoy the processed voice through the microphone.

For detailed implementation, see [Implementation Details](report.md).
