1. **FCS Overview**:

   - The Frame Check Sequence is a 4-octet (32-bit) Cyclic Redundancy Check (CRC).
   - It detects corrupted data within an Ethernet frame.

2. **Computation Basis**:

   - FCS is calculated based on protected MAC frame fields: source and destination addresses, length/type field, MAC client data, and padding.

3. **CRC-32 Algorithm**:

   - Left shifting CRC-32: Polynomial = `0x4C11DB7`, Initial CRC = `0xFFFFFFFF`, Post complemented, Verify value = `0x38FB2284`.
   - Data is transmitted least significant bit first, but FCS is transmitted most significant bit first.

4. **Alternative CRC-32 Algorithm**:

   - Right shifting CRC-32: Polynomial = `0xEDB88320`, Initial CRC = `0xFFFFFFFF`, Post complemented, Verify value = `0x2144DF1C`.
   - Results in a bit-reversed FCS, with data and CRC both transmitted least significant bit first.

5. **Receiver Processing**:

   - Receiver calculates a new FCS as data is received and compares it with the received FCS.
   - Alternatively, a CRC is calculated on received data and FCS, resulting in a fixed non-zero verify value (`0x2144DF1C`).

6. **Hardware Implementation**:
   - Logically right shifting CRC may use a left shifting Linear Feedback Shift Register.
   - The residue for a right shifting implementation would be the complement of `0x2144DF1C` = `0xDEBB20E3`.
   - For a left shifting implementation, the complement of `0x38FB2284` = `0xC704DD7B`.

This format focuses on the key aspects of FCS in Ethernet frames, suitable for a high-level presentation.
