
function pack(opcode::Opcode, data)
    data_len = length(data)

    res = IOBuffer()
    write(res, ntoh(UInt16(8 + data_len)))
    write(res, UInt32(128))
    write(res, ntoh(UInt16(opcode)))
    write(res, data)
    return take!(res)
end