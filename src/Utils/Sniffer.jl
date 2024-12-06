const PCAP_ERRBUF_SIZE = 256

#----------
# lookup default device
#----------
function pcap_lookupdev()
    dev = ccall((:pcap_lookupdev, "libpcap"), Ptr{UInt8}, ())
    if dev == C_NULL
        return Union()
    end
    return unsafe_string(dev)
end # function pcap_lookupdev

# Callback to process packets
function process_packet(user_data, header, packet)
    println(user_data)
    println("header")
    println(header)
    println("packet")
    println(packet)
    println("Packet captured! Length: $(unsafe_load(header, 1)) bytes")

    process_packet2(user_data, header, packet)
end

# Define the pcap_pkthdr structure
struct PcapPktHdr
    ts_sec::UInt32      # Timestamp seconds
    ts_usec::UInt32     # Timestamp microseconds
    caplen::UInt32      # Length of portion present
    len::UInt32         # Length of the packet (off the wire)
end

function process_packet2(user_data, header, packet)
    # Interpret the header
    pkt_header = unsafe_load(Ptr{PcapPktHdr}(header))
    println("Timestamp: $(pkt_header.ts_sec).$(pkt_header.ts_usec)")
    println("Captured Length: $(pkt_header.caplen) bytes")
    println("Original Length: $(pkt_header.len) bytes")

    # Interpret the packet
    packet_data = unsafe_wrap(Vector{UInt8}, packet, pkt_header.caplen; own=false)
    #println("Packet data (hex): $(join(map(x -> string(x, base=16, pad=2), packet_data)))")

    # Further unpacking can be done here depending on the protocol
    if pkt_header.caplen >= 14  # Ethernet header is at least 14 bytes
        eth_type = UInt16(packet_data[13] + (packet_data[12] << 8))
        println("Ethernet Type: $(eth_type)")
    end
end

function capture_tcp_packets()
    device = pcap_lookupdev()
    println("Using device: $device")

    # Allocate memory for the error buffer
    errbuf = Vector{UInt8}(undef, PCAP_ERRBUF_SIZE)
    pcap_handle = ccall(
        (:pcap_open_live, "libpcap"),
        Ptr{Cvoid},  # Pointer to the capture handle
        (Ptr{UInt8}, Cint, Cint, Cint, Ptr{UInt8}),
        device, 65535, 1, 1000, errbuf
    )

    if pcap_handle == C_NULL
        error("Failed to open device: $(String(errbuf))")
    end

    println("Device opened successfully.")

    # Compile the filter for TCP packets
    filter = "tcp"
    bpf_program = Ref{Cvoid}()
    if ccall(
        (:pcap_compile, "libpcap"),
        Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{UInt8}, Cint, UInt32),
        pcap_handle, bpf_program, filter, 1, 0
    ) != 0
        error("Error compiling filter.")
    end

    # Set the compiled filter
    if ccall(
        (:pcap_setfilter, "libpcap"),
        Cint,
        (Ptr{Cvoid}, Ptr{Cvoid}),
        pcap_handle, bpf_program
    ) != 0
        error("Error setting filter.")
    end

    println("Filter applied: $filter")

    # Start capturing packets
    ccall(
        (:pcap_loop, "libpcap"),
        Cint,
        (Ptr{Cvoid}, Cint, Ptr{Cvoid}, Ptr{UInt8}),
        pcap_handle, -1, @cfunction(process_packet, Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{UInt8})), C_NULL
    )
end

capture_tcp_packets()