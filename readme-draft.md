- **Module Name**: `pdm_clk_gen`
- **Purpose**: To generate a clock signal for a PDM microphone.
- **Parameters**:
  - `INPUT_FREQ`: The frequency of the input clock signal.
  - `OUTPUT_FREQ`: The desired frequency of the output clock signal (2.5 MHz in this case).

### Inputs and Outputs

- **Inputs**:
  - `clk`: The input clock signal.
  - `rst`: A reset signal.
- **Outputs**:
  - `M_CLK`: The modified clock signal output.
  - `m_clk_rising`: A signal that indicates the rising edge of the modified clock.

### Internal Logic

1. **Clock Division**: The module divides the input clock frequency (`INPUT_FREQ`) to achieve the desired output frequency (`OUTPUT_FREQ`). This is done by the `CLK_DIVIDE` parameter which is the ratio of `INPUT_FREQ` to `OUTPUT_FREQ`.

2. **Counter Logic**:

   - A counter (`clk_counter`) is used to track the clock cycles.
   - The counter increments on every positive edge of the input clock (`clk`).
   - When the counter reaches half the value of `CLK_DIVIDE`, it resets to zero, and the output clock signal (`m_clk_i`) toggles its state.

3. **Output Clock Generation**:
   - `M_CLK` is assigned the value of `m_clk_i`. This is the output clock signal whose frequency is controlled by the division logic.
   - `m_clk_rising` is a signal that is high (`1`) only when `m_clk_i` transitions from low to high, indicating a rising edge. It's used as an enable signal in other logic.

### Comments and Additional Notes

- For frequencies less than 5 MHz, a different approach is used instead of a clock wizard, as the FPGA has dedicated clock routes designed for higher frequencies.
- `M_CLK` is used outside the FPGA, specifically for the PDM microphone IC, and not used internally within the FPGA.
