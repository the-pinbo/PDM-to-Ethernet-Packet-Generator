`timescale 1ns/1ps
`default_nettype none

module package_gen
  #(
    parameter SOURCE_MAC = 48'he86a64e7e830,
    parameter DEST_MAC = 48'h080027fbdd65,
    parameter MII_WIDTH = 2,
    parameter PACKET_PAYLOAD_WORDS = 64,
    parameter WORD_BYTES = 4

    )
    (clk_i, rst_i, s_axis_tdata_i, s_axis_tvalid_i, s_axis_tlast_i, s_axis_tready_o, tx_en_o, txd_o);

    input clk_i;
    input rst_i;
    input [WORD_BYTES-1:0] s_axis_tdata_i;
    input s_axis_tvalid_i;
    input s_axis_tlast_i;
    output s_axis_tready_o;

    output reg tx_en_o;
    output reg [MII_WIDTH-1:0] txd_o;

    reg s_axis_tfirst;

// Ethernet header packet

    // reg [1:0][7:0] eth_type_length;
    // reg [5:0][7:0] mac_source;
    // reg [5:0][7:0] mac_dest;


    reg [2*8-1:0] eth_type_length;
    reg [6*8-1:0] mac_source;
    reg [6*8-1:0] mac_dest;

    always @(posedge clk_i) 
        begin 
            if (rst_i) s_axis_tfirst <= 1'b1;
        else begin
            if (s_axis_tvalid_i && s_axis_tready_o) begin
                if (s_axis_tlast_i) s_axis_tfirst <= 1'b1;
                else s_axis_tfirst <= 1'b0;
            end
        end
    end

    localparam PACKET_PAYLOAD_BYTES = PACKET_PAYLOAD_WORDS * WORD_BYTES;


// Number of bytes transferred at each stage
    localparam PREAMBLE_BYTES = 7;
    localparam SFD_BYTES = 1; // Start of Frame Delimiter
    localparam HEADER_BYTES = 14;
    localparam DATA_BYTES = PACKET_PAYLOAD_BYTES;
    localparam FCS_BYTES = 4; // Frame Check Sequence
    localparam WAIT_BYTES = 12;

// header and state buffer
    wire reg [HEADER_BYTES*8-1-1:0] header; //HEADER_DEFN
    reg [HEADER_BYTES*8-1:0] header_buffer;
    reg [WORD_BYTES*8-1:0] data_buffer;
    reg [PREAMBLE_BYTES*8-1:0] preamble_buffer;
    reg [SFD_BYTES*8-1:0] sfd_buffer;
    reg [FCS_BYTES*8-1:0] fcs;
    reg [FCS_BYTES*8-1:0] fcs_buffer;

// RMII interface is MII_WIDTH bits wide, so divide by MII_WIDTH to get the correct
// number of iterations per each stage

    localparam PREAMBLE_LENGTH = PREAMBLE_BYTES*8 / MII_WIDTH;
    localparam SFD_LENGTH = SFD_BYTES*8 / MII_WIDTH;
    localparam HEADER_LENGTH = HEADER_BYTES*8 / MII_WIDTH;
    localparam DATA_LENGTH = DATA_BYTES*8 / MII_WIDTH;
    localparam FCS_LENGTH = FCS_BYTES*8 / MII_WIDTH;
    localparam WAIT_LENGTH = WAIT_BYTES*8 / MII_WIDTH;


    localparam DATA_COUNTER_BITS = 5;

    reg [2:0] state_type;
    localparam IDLE = 3'b000, PREAMBLE = 3'b001, SFD = 3'b010, HEADER = 3'b011, DATA = 3'b100, FCS = 3'b101, WAIT = 3'b110;
    
    reg current_state;
    reg next_state;

    //data fifo
    reg                                fifo_full;
    reg                                fifo_empty;
    reg [11:0]                         fifo_count;
    reg [WORD_BYTES*8-1:0]             fifo_out;
    reg                                fifo_rd_en;
    wire                               fifo_wr_en;
    wire                              packet_start_valid;
    reg                                packet_valid;
    wire                               fifo_has_space;

    localparam FIFO_DEPTH = 2048;

    assign fifo_has_space = (fifo_count < FIFO_DEPTH-PACKET_PAYLOAD_BYTES ) ? 1 : 0;

// Packet start is only valid when
// First beat of axi stream and
// Axis Stream is valid and
// Axis Stream is ready and
// Space in FIFO
// This indicates that this packet has space to go into the fifo
// Otherwise, it is skipped

    assign packet_start_valid = s_axis_tvalid_i && s_axis_tready_o && s_axis_tfirst && fifo_has_space;

// create packet_valid flag
    always @(posedge clk_i) begin
        if (rst_i) begin
            packet_valid <= 1'b0;
        end
        else begin
            if (packet_start_valid) begin
                packet_valid <= 1'b1;
            end
            
            if (packet_valid && s_axis_tvalid_i && s_axis_tready_o && s_axis_tlast_i) begin
                packet_valid <= 1'b0;
            end
        end
    end

// only write a valid packet
    assign fifo_wr_en = s_axis_tvalid_i && s_axis_tready_o && (packet_start_valid || packet_valid);

// ready if fifo has space
    assign s_axis_tready_o = (fifo_has_space & s_axis_tfirst) | packet_valid;

    // Hardcoding get header module 
    assign header = {mac_dest, mac_source, eth_type_length};

    data_fifo data_fifo_i
      (
      .clk(clk_i),
      .srst(rst_i),
      .din(s_axis_tdata_i),
      .wr_en(fifo_wr_en),
      .rd_en(fifo_rd_en),
      .dout(fifo_out),
      .full(fifo_full),
      .empty(fifo_empty),
      .data_count(fifo_count)
      );

// count the time spent in each state
    reg [31:0] state_counter;

    always @(posedge clk_i) begin
        if (rst_i) begin
            state_counter <= 32'd0;
            current_state <= IDLE;
            next_state <= IDLE;
        end
        else begin
            if (current_state != next_state) begin
                state_counter <= 32'd0;
            end
            else begin
                state_counter <= state_counter + 32'd1;
            end
        end
    end


    // 3 process state machine
    always @(*) begin
        case (current_state)
            IDLE :
            begin
                if (fifo_count >= PACKET_PAYLOAD_WORDS) begin
                  next_state = PREAMBLE;
                end

                else begin
                  next_state = current_state;
                end
            end

            PREAMBLE :
            begin
                if (state_counter == PREAMBLE_LENGTH-1) begin
                  next_state = SFD;
                end

                else begin
                  next_state = current_state;
                end
            end

            SFD :
            begin
                if (state_counter == SFD_LENGTH-1) begin
                  next_state = HEADER;
                end

                else begin
                  next_state = current_state;
                end
            end

            HEADER :
            begin
                if (state_counter == HEADER_LENGTH-1) begin
                  next_state = DATA;
                end

                else begin
                  next_state = current_state;
                end
            end

            DATA :
            begin
                if (state_counter == DATA_LENGTH-1) begin
                  next_state = FCS;
                end

                else begin
                  next_state = current_state;
                end
            end

            FCS :
            begin
                if (state_counter == FCS_LENGTH-1) begin
                  next_state = WAIT;
                end

                else begin
                  next_state = current_state;
                end
            end

            WAIT :
            begin
                if (state_counter == WAIT_LENGTH-1) begin
                  next_state = IDLE;
                end

                else begin
                  next_state = current_state;
                end
            end
            default: 
                next_state = current_state;
        endcase 
    end


// state dependant variables
    reg [MII_WIDTH-1:0] tx_data;
    reg tx_valid;
    reg fcs_en;
    reg fcs_rst;

// drive output according to state, ah the bliss of writing FSMs
    always @(*) begin
        case (current_state)
            IDLE :
            begin
                tx_valid = 0;
                tx_data  = 0;
                fcs_en   = 0;
                fcs_rst  = 1;
            end 

            PREAMBLE : 
            begin
                tx_valid = 1;
                tx_data  = preamble_buffer[MII_WIDTH-1:0];
                fcs_en   = 0;
                fcs_rst  = 0;
            end  

            SFD :
            begin
                tx_valid = 1;
                tx_data  = sfd_buffer[MII_WIDTH-1:0];
                fcs_en   = 0;
                fcs_rst  = 0;                
            end 
            HEADER  :
            begin
               tx_valid = 1;
               tx_data  = header_buffer[MII_WIDTH-1:0];
               fcs_en   = 1;
               fcs_rst   = 0;

            end
            DATA  :
            begin
               tx_valid = 1;
               tx_data  = data_buffer[MII_WIDTH-1:0];
               fcs_en   = 1;
               fcs_rst   = 0;

            end
            FCS:
            begin
               tx_valid = 1;
               tx_data  = fcs_buffer[MII_WIDTH-1:0];
               fcs_en   = 0;
               fcs_rst  = 0;

            end
            WAIT   :
            begin
               tx_valid = 0;
               tx_data  = 0;
               fcs_en   = 0;
               fcs_rst  = 0;

            end            
            default: 
            begin
                tx_valid = 0;
                tx_data  = 0;
                fcs_en   = 0;
                fcs_rst  = 0;
            end
        endcase
    end 

       crc generator
    crc_gen crc_gen_i
     (
      .clk(clk_i),
      .rst(rst_i || fcs_rst),

      .data_in(tx_data),
      .crc_en(fcs_en),
      .crc_out(fcs)

      );

    wire reg [DATA_COUNTER_BITS-1:0] data_ones;
    assign data_ones = 1;

 // populate and shift buffers according to state
   always @(posedge clk_i) begin
      if (rst_i == 1) begin
         header_buffer   <= 0;
         preamble_buffer <= 0;
         fifo_rd_en      <= 0;

      end
      else begin
         fifo_rd_en      <= 0;

         // buffer loading
         if (current_state == IDLE) begin
            header_buffer   <= header;
            preamble_buffer <= 56'h55555555555555;
            sfd_buffer      <= 8'hd5;
         end
         // and fcs when it's available
         if (next_state == FCS && current_state != FCS) begin
            fcs_buffer <= fcs;
         end
         // and fcs when it's available
         if (next_state == DATA && current_state != DATA) begin
            data_buffer <= fifo_out;
            fifo_rd_en  <= 1;

         end

         // shift buffers during those states
         if (current_state == HEADER) begin
            header_buffer <= header_buffer >> MII_WIDTH;
         end
         if (current_state == PREAMBLE) begin
            preamble_buffer <= preamble_buffer >> MII_WIDTH;
         end
         if (current_state == SFD) begin
            sfd_buffer <= sfd_buffer >> MII_WIDTH;
         end
         if (current_state == DATA && next_state == DATA ) begin
            if (state_counter[DATA_COUNTER_BITS-1:0] == data_ones) begin
               data_buffer <= fifo_out;
               fifo_rd_en  <= 1;

            end
            else begin
               data_buffer <= data_buffer >> MII_WIDTH;
            end
         end
         if (current_state == FCS) begin
            fcs_buffer <= fcs_buffer >> MII_WIDTH;
         end
      end
   end

   // Register outputs
   //drive tx interfaces

   always @(posedge clk_i)

     begin
	    if(rst_i) begin
           tx_en_o <= 0;

	    end
	    else begin
           tx_en_o <= tx_valid;
           txd_o   <= tx_data;

	    end

     end


endmodule

