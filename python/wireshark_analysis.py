import pyshark


PCAP_FILE_PATH = r'C:\Users\inba2\Desktop\DDFPGA\TermProject\ddfpga-project\python\caputre_ws_2.pcapng'
DEST_SRC_MAC = b'<|?\x1a\xea\x02\x00\x18>\x01\xebn'


sample_bytes = 4
sample_rate = 3e6//64

with open("test.bin", "wb") as f:
    cap = pyshark.FileCapture(
        PCAP_FILE_PATH, only_summaries=False, use_json=True, include_raw=True)

    for packet in cap:
        try:
            # Accessing the binary data of the packet
            binary_data = bytes(packet.get_raw_packet())
            print("Parsing packet of length: ", len(binary_data)-14)
            if binary_data[0:12] == DEST_SRC_MAC:
                # Trim off header
                f.write(binary_data[14:])
            else:
                print(
                    f"Wrong packet received with mac {binary_data[0:12].hex()}")
        except Exception as e:
            # In case of any error
            print(f"Error extracting data: {e}")
