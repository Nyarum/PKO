include("Packer.jl")

@generate struct ItemAttr
    Attr::UInt16
    IsInit::Bool
end

@generate struct InstAttr
    ID::UInt16
    Value::UInt16
end

@generate struct ItemGrid
    ID::UInt16
    Num::UInt16
    Endure::NTuple{2, UInt16}
    Energy::NTuple{2, UInt16}
    ForgeLv::UInt8
    DBParams::NTuple{2, UInt32}
    InstAttrs::NTuple{5, InstAttr}
    ItemAttrs::NTuple{40, ItemAttr}
    IsChange::Bool
end

@generate struct Look
    Ver::UInt16
    TypeID::UInt16
    ItemGrids::NTuple{10, ItemGrid}
    Hair::UInt16
end

@generate struct Character
    IsActive::Bool
    Name::String
    Job::String
    Level::UInt16
    LookSize::UInt16
    Look::Look
end

@generate struct CharacterScreen
    ErrorCode::UInt16
    Key::Vector{UInt8}
    CharacterLen::UInt8
    Characters::Vector{Character}
    Pincode::UInt8
    Encryption::UInt32
    DWFlag::UInt32

    CharacterScreen() = new(
        0x0000,
        UInt8[0x7C, 0x35, 0x09, 0x19, 0xB2, 0x50, 0xD3, 0x49],
        0x00,
        Character[],
        1,
        0x00000000,
        12820
    )
end

@generate struct CharacterCreate
    Name::String
    Map::String
    LookSize::UInt16
    Look::Look
end

@generate struct CharacterCreateReply
    ErrorCode::UInt16

    CharacterCreateReply() = new(0x0000)
end

@generate struct CharacterRemove
    Name::String
    Hash::String
end

@generate struct CharacterRemoveReply
    ErrorCode::UInt16

    CharacterRemoveReply() = new(0x0000)
end

@generate struct CreatePincode
    Hash::String

    CreatePincode(hash) = new(hash)
end

@generate struct CreatePincodeReply
    ErrorCode::UInt16

    CreatePincodeReply() = new(0x0000)
end

@generate struct UpdatePincode
    OldHash::String
    Hash::String
end

@generate struct UpdatePincodeReply
    ErrorCode::UInt16

    UpdatePincodeReply() = new(0x0000)
end
