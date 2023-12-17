# Implementation

## The 5-Layer TCP/IP Model

The TCP/IP model is a conceptual framework used in network communications, describing how data should be formatted, addressed, transmitted, routed, and received at the destination. Originally developed by the Defense Advanced Research Projects Agency (DARPA), this model forms the basis of the Internet.

![TCP-IP stack](https://www.parthshandilya.com/static/000830ae038ab058c5ae0487027fd995/1bae2/TCP-IP-Layers.png)

1. PHYSICAL LAYER
2. DATA-LINK LAYER
3. NETWORK LAYER
4. TRANSPORT LAYER
5. APPLICATION LAYER

### Physical Layer

![Physical Layer](https://upload.wikimedia.org/wikipedia/commons/5/5f/10baseT_jack.png)

- Transmits raw bits over the physical medium
- Category 5 (Cat 5) or higher unshielded twisted pair (UTP) cables
- It follows the 10 Base T or IEEE 802.11 architecture.
- Specifies the speed of data transmission (Data rate)
- Ensures sender and receiver clocks are synchronized

#### 100BASE-TX

- 100BASE-TX is part of the IEEE 802.3u standard (Fast Ethernet)
- Designed to run over twisted pair cables
- Two twisted paris for transmission and reception
- Transmission rate of 100 megabits per second (Mbps) over half and full duplex modes

### Data Link Layer

- Packages data into frames for transmission (Encapsulation)
- Unique addresses to devices using MAC (48 bits)
- Ethernet and Wi-Fi Common technologies
- Data Link Protocols Includes Ethernet and Wi-Fi

#### Ethernet frame (802.3)

![802.3 Ethernet packet and frame structure](./Img/eth_frame.png)

The Ethernet header is a crucial part of network communications, containing several fields that facilitate the correct delivery and processing of data. Let's delve into each field of the Ethernet header.

##### 1. The Preamble Field

![Preamble and SFD representations as bits, decimal, bytes, and nibbles](./Img/prem_sfd.png)

- **Length**: 7 bytes.
- **Function**: Facilitates the identification of the beginning of an Ethernet frame.
- **Pattern**: Each byte alternates between 1 and 0, forming the pattern `10101010`.
- **Purpose**: Helps the receiving device synchronize with the incoming bit-stream.

##### 2. The SFD Field (Start Frame Delimiter)

- **Length**: 1 byte.
- **Pattern**: Similar to the preamble, but with the last bit as 1.
- **Purpose**: Signals the start of the destination MAC address in the frame.

##### 3. Destination MAC Address

![Preamble SFD Ethernet Type II Frame IFG](https://upload.wikimedia.org/wikipedia/commons/e/e4/Preamble_SFD_Ethernet_Type_II_Frame_IFG.svg)

- **Length**: 6 bytes.
- **Content**: MAC address of the destination device.
- **Format**: Written as a 12-digit hexadecimal number (e.g., `0000.0A12.1234`).
- **Purpose**: Helps the receiving device determine the intended recipient of the frame.

##### 4. Source MAC Address

- **Length**: 6 bytes.
- **Content**: MAC address of the source device.
- **Purpose**: Identifies the origin of the frame.

##### 5. Type Field

- **Length**: 2 bytes.
- **Function**: Indicates the protocol used in the upper (network) layer.
- **Examples**:
  - IPv4: `0x800`
  - IPv6: `0x86dd`

##### 6. Data and Pad Field

- **Size Limit**: 46 bytes (minimum) to 1500 bytes (maximum).
- **Content**: Encapsulated data from the upper layer.
- **Padding**: Added if data is less than the minimum requirement.

##### 7. FCS (Frame Check Sequence)

![CRC HW](./Img/CRC.png)

- **Length**: 4 bytes.
- **Function**: Ensures data integrity using CRC (Cyclic Redundancy Check).
- **Process**: Compares CRC results to detect errors in the frame.

  **CRC-32 Hardware**:

  - Logically right shifting CRC may use a left shifting Linear Feedback Shift Register.
  - The residue for a right shifting implementation would be the complement of `0x2144DF1C` = `0xDEBB20E3`.
  - For a left shifting implementation, the complement of `0x38FB2284` = `0xC704DD7B`.

## Architecture

![Alt text](./Imgae/ModulePDMFFT.png)

### Reset Generator

#### Debounce Switch

<!-- Mention about the debounce switch -->

#### Clock Wiz IP

<!-- Mention about the IP -->

### Packet gen

<!-- Gagana -->

#### Header Package

<!-- Gagana -->

#### State machine

<!-- Gagana -->

![State Machine](./Img/fsm_packet_gen.png)

- IDLE
- PREAMBLE
- SFD (Start Frame Delimiter)
- HEADERE
- DATA
- FCS (Frame Check Sequence)
- WAIT

#### CRC Generator

<!-- Gagana -->
