
function getChars() 
    buf = IOBuffer()
    write(buf, UInt16(0)) # error code
    write(buf, ntoh(UInt16(8)))
    write(buf, 0x7C, 0x35, 0x09, 0x19, 0xB2, 0x50, 0xD3, 0x49) # key
    write(buf, 0x00)
    write(buf, 0x01)
    write(buf, UInt32(0))
    write(buf, ntoh(UInt32(12820)))
    return take!(buf)
end