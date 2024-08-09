
struct Header
    len::UInt16
    id::UInt32
    opcode::UInt16
end

function unpack_header(data)
    len = ntoh(read(data, UInt16))
    id = read(data, UInt32)
    opcode = ntoh(read(data, UInt16))
    return Header(len, id, opcode)
end