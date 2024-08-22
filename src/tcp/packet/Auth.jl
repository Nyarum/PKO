
struct Auth
    key::Vector{UInt8}
    login::String
    password::Vector{UInt8}
    mac::String
    is_cheat::UInt16
    client_version::UInt16
    bro::Bro
end

@generate Auth