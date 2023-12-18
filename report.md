# National Institute of Technology Karnataka Surathkal

<p align="center">
  <img src="./report/NITK_Emblem.png" alt="model" style="width:150px;"/>
  <h2>
</p>

## EC806: Digital system design using FPGAs

## **PDM-Mic Ethernet Frame Generator**

## **Members**

- Inbasekaran Perumal : inba2002.p\@gmail.com
- KA Gaganashree : XXXXX\@gmail.com
- Pranav Koundinya : pranavmkoundinya\@gmail.com

## **_Course Instructor_**

- Prof. Sumam David S

## Abstract

## Introduction

## Motivation

## Literature review

## Implementation

8. **Module Definition**:

   ```verilog
   module ethernet_top(
   ```

   - Declares a module named `ethernet_top`.

9. **Port Definitions**:

   ```verilog
   input CLK,
   input RST_N,
   ...
   input ETH_INTN
   );
   ```

   - Declares the module's input, output, and bidirectional (inout) ports.
   - `CLK`: Clock input.
   - `RST_N`: Active-low reset input.
   - `ETH_MDC`, `ETH_MDIO`, etc.: Ethernet-related pins. These pins typically connect to an Ethernet PHY.

10. **Internal Signals**:

    ```
    wire rst;
    ```

    - `rst`: Derived reset signal.

11. **Reset Generation**:

    ```
    rst_gen rst_gen_i(
        .clk_in(CLK),
        .rst_in(~RST_N),
        .rst_out(rst)
    );
    ```

    - Instantiates a module `rst_gen` which seems to generate a derived reset signal `rst` using the input `RST_N` and `CLK`.

12. **Ethernet Clock and Reset Signals**:

    ```
    wire eth_clk;
    wire eth_rst;
    ```

    - Declares the Ethernet-specific clock and reset signals.

13. **Streaming Data Variables**:

```
wire [7:0] s_axis_tdata;
wire       s_axis_tvalid;
wire       s_axis_tready;
wire       s_axis_tlast;
```

- Streaming protocol signals for data transfer. Typically used in AXI Stream-like interfaces.

11. **Ethernet Boot Mode Configuration**:

```
assign ETH_CRSDV  = (eth_rst) ? 1 : 1'bz;
assign ETH_RXD[0] = (eth_rst) ? 1 : 1'bz;
assign ETH_RXD[1] = (eth_rst) ? 1 : 1'bz;
```

- Assigns pull-up values for the Ethernet boot mode configuration when in reset.

12. **MDIO Interface**:

```
assign ETH_MDC = 0;
```

- Disables the MDIO (Management Data Input/Output) interface by keeping the `ETH_MDC` signal low.

13. **Ethernet Reset Generation**:

```
eth_rst_gen eth_rst_gen_i(
   ...
);
```

- Instantiates an Ethernet reset generation module that likely provides the clock and reset signals specific to the Ethernet operation.

14. **Packet Timer Configuration**:

```
reg  packet_enable;
reg [63:0] packet_timer;
localparam packet_max = 5000;
```

- Configures a timer (`packet_timer`) that triggers the generation of Ethernet packets when the timer value reaches a maximum (`packet_max`).

11. **Packet Data and Size Configurations**:

```
parameter PACKET_PAYLOAD_WORDS = 64;
parameter WORD_BYTES = 4;
reg [WORD_BYTES*8-1:0] packet_data;
```

- Defines the size and data for the Ethernet packets. The packet consists of a number of payload words (`PACKET_PAYLOAD_WORDS`), and each word has a size (`WORD_BYTES`).

12. **Packet Timer Increment Logic**:

```
always @(posedge eth_clk) begin
   ...
end
```

- On every rising edge of the Ethernet clock, this block updates the `packet_timer`, checks the timer value against the max, and possibly triggers packet generation.

13. **Packet Valid and Last Signal Generation**:

```
assign s_axis_tvalid = packet_timer < PACKET_PAYLOAD_WORDS ? 1 : 0;
assign s_axis_tlast = packet_timer == PACKET_PAYLOAD_WORDS-1;
```

- Sets the `s_axis_tvalid` signal when the timer is within the payload length and sets the `s_axis_tlast` signal when the timer reaches the last word.

14. **Packet Generation Instance**:

```
packet_gen
  #(
    .PACKET_PAYLOAD_WORDS(PACKET_PAYLOAD_WORDS),
    .WORD_BYTES(WORD_BYTES),
    .DEST_MAC(48'H3C_7C_3F_1A_EA_02)
    ) packet_gen_i
  (
   ...
   );
```

- Instantiates a module named `packet_gen` that seems to generate the actual Ethernet packets.
- The parameters passed include payload word size, word byte size, and a destination MAC address.

15. **End of Module**:

```
endmodule

```

```

```

## Results

## Conclusion

## References
