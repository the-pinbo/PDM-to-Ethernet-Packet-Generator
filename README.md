# ddfpga-project

## Nexys 4 DDR PDM-MIC ETHERNET FRAME GENERATOR

`vivado-2022.1` : download

## Features Used

|                                   | Not Used | Used |
| --------------------------------- | :------: | :--: |
| 16 user switches                  |    X     |      |
| 16 user LEDs                      |    X     |      |
| Two tri-color LEDs                |    X     |      |
| 5 User Push Buttons               |    X     |      |
| Two 4-digit 7-segment displays    |    X     |      |
| 4 Pmod ports                      |    X     |      |
| Pmod for XADC signals             |    X     |      |
| 12-bit VGA output                 |    X     |      |
| USB-UART Bridge                   |    X     |      |
| Serial Flash for Application Data |    X     |      |
| USB HID Host With Mouse           |    X     |      |
| USB HID Host With Keyboard        |    X     |      |
| Micro SD card connector           |    X     |      |
| PWM audio output                  |    X     |      |
| PDM microphone                    |          |  X   |
| 3-axis accelerometer              |    X     |      |
| 128MiB DDR2                       |    X     |      |
| Temperature sensor                |    X     |      |
| 10/100 Ethernet PHY               |          |  X   |

## Description

The Nexys4DDR gets PDM data from the built-in microphone, then digitally filters data for decimation and resolution (16 bit, 48KSPS). Then reverberates the audio data and outputs it to the built-in Audio Out, stores a frame of 1024 samples and shows it on a VGA display (640×480, 60Hz). then the demo computes the Fast Fournier Transform (FFT) of the stored data (512 bins x 46.875 Hz = 0…24KHz). The demo shows the first 80 FFT bins on the VGA display (80 bins x 46.875 Hz = 0…3.75KHz) and displays the first 30 FFT bins on an WS2812 LED string (30 bins x 46.875 Hz = 0…1.4KHz),

## Prerequisites

### Hardware

- Nexys 4 DDR FPGA board
- Micro-USB cable
- A 30 led strip of WS2812 LEDs (Not required for VGA operation)
- Monitor with a VGA cable (Not required for WS2812 operation)

### Software

- [Vivado Design Suite 2021.X](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2022-1.html)
  _Newer/older versions can be used, but the procedure may vary slightly_
- Latest version of [Python](https://www.python.org/downloads/)
- [Wireshark](https://www.wireshark.org/download.html)

## Setup

1. **Clone repo**

   ```bash
   git clone https://github.com/the-pinbo/ddfpga-project.git
   ```

2. **Generate the Project**

   Open Vivado and find the tools window in the top and click on `Run Tcl Script`

   ![Run Tcl Script](./Img/run-tcl-script-1.png)

   Navigate to the directory `ddfpga-project` and navigate to the `project` directory and click on `efsm.tcl` file to create the project

   ![Run Tcl Script](./Img/run-tcl-script-2.png)

   The tcl script will create a new project with the source files, constraints, and any supplementary files included.

   The IP's used in the current project might have undergone changes or upgradation, navigate to `Reports > Report IP Status` and upgrade the IP's if required.
   ![Report IP Status](./Img/Report-IP-Status.png)
   Note: sometimes if the IP's have undergone drastic revisions, manual intervention might be required.

   **NOTE** the following project has the MAC address of the receiver hard corded, so its is necessary to change the MAC address before generating the bit-stream.

## Viewing the MAC Address on Linux

To view the MAC address on a Linux system, follow these steps:

1.  Open a terminal.
2.  Type the following command and press Enter:

```bash
ifconfig -a
```

Look for the eth0 interface or similar for Ethernet, and find the HWaddr or ether field which will display the MAC address.

## Viewing the MAC Address on Windows

Open Command Prompt.
Type the following command and press Enter:

```cmd
ipconfig /all
```

3. **Build the Project**

   Click Generate Bitstream on the left hand menu towards the bottom. Vivado will run through both Run Synthesis and Run Implementation before it generates the bitstream automatically.

   Note: If you want, you can click each step by itself in the order of Run Synthesis, Run Implementation and then Generate Bitstream.

   ![Generate-Bitstream.png](.Img\Generate-Bitstream.png)

4. **Program the board**
   Once you have generated your bit file, Connect your FPGA board and Click on the hardware manager and connect to your board by choosing the Auto-Connect option.
   ![hw-manager-auto-conn](./Img/hw-manager-auto-conn.png)

   Once the divide has been connected load the program by clicking on program device.
   ![prog-dev](./Img/prog-dev.png)

5. **Caputre the packets on the host**
   Connect the enthernet cable from the FPGA mac port to your computers MAC port.
   Open WireShark to capture and analyse the packets
   Click on your primary ethernet interface to view the packets
   Analyze the packets in the wireshark utility.
   Caputre the packets and save the packets as a `.pcap` file for further processing and expeloration

6. **Signal processing on python**
   Now we will have to deframement the packets and do some signal processing in order to generate the Audio file.

   ### Create a virtual env

   **Linux**

```cmd
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Windows**

```bash
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

Run `python\wireshark_analysis.ipynb` to analyze and generate the audio in a `.wav` format.

**Alternatively**
_Works only on linux_

Change the ethernet interface and set the respective destination mac address on `python\receive_wav.py` and run this file to directly generate the wav file without using wireshark.
This uses RAW-SOCKETS which requires sudo access.

7. **Enjoy your voice through the mic**
   Play back the audio generated and enjoy your voice thorugh the pdm Microphone, happy learning.

Click on this to view the implementation details Implementation details
