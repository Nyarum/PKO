include("Packer.jl")

struct Bro2
    id::UInt8
end

function filter(v::Bro2, field, previous)
    if field == :id
        return v.id == previous[:client_version]
    end
    
    return false
end

struct Bro
    id::UInt8
    bro2::Bro2
end

struct Auth2
    key::Vector{UInt8}
    login::String
    password::Vector{UInt8}
    mac::String
    is_cheat::UInt16
    client_version::UInt16
    bro::Bro
end

function save(v::Auth2, field)
    if field == :client_version
        return true
    end

    return false
end

@generate Auth2
@generate Bro
@generate Bro2

result = pack(Auth2([0x02, 0x01], "login", [0x01, 0x02], "mac", 1, 1, Bro(0x01, Bro2(0x01))))

@assert result == [0x00, 0x02, 0x02, 0x01, 0x00, 0x06, 0x6c, 0x6f, 0x67, 0x69, 0x6e, 0x00, 0x00, 0x02, 0x01, 0x02, 0x00, 0x04, 0x6d, 0x61, 0x63, 0x00, 0x00, 0x01, 0x00, 0x01, 0x01] "result isn't correct pack"