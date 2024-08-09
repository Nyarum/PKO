
struct Auth
    key::Vector{UInt8}
    login::String
    password::Vector{UInt8}
    mac::String
    is_cheat::UInt16
    client_version::UInt16
end

function unpack(::Type{Auth}, buf)
    println(typeof(buf))
    key_len = ntoh(read(buf, UInt16))
    println(key_len)
    key = read(buf, key_len)
    login_len = ntoh(read(buf, UInt16))
    login = String(read(buf, login_len))
    password_len = ntoh(read(buf, UInt16))
    password = read(buf, password_len)
    mac_len = ntoh(read(buf, UInt16))
    mac = String(read(buf, mac_len))
    is_cheat = ntoh(read(buf, UInt16))
    client_version = ntoh(read(buf, UInt16))
    return Auth(key, login, password, mac, is_cheat, client_version)
end