include("Packer.jl")

struct ItemAttr
    Attr::UInt16
    IsInit::Bool
end

@generate ItemAttr

struct InstAttr
    ID::UInt16
    Value::UInt16
end

@generate InstAttr

struct ItemGrid
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

@generate ItemGrid

struct Look
    Ver::UInt16
    TypeID::UInt16
    ItemGrids::NTuple{10, ItemGrid}
    Hair::UInt16
end

@generate Look

struct Character
    IsActive::Bool
    Name::String
    Job::String
    Level::UInt16
    LookSize::UInt16
    Look::Look
end

@generate Character

struct CharacterScreen
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
        0x00,
        0x00000000,
        12820
    )
end

@generate CharacterScreen

struct CharacterCreate
    Name::String
    Map::String
    LookSize::UInt16
    Look::Look

    CharacterCreate() = new("", "", 0x0000, Look(0x0000, 0x0000, ItemGrid[], 0x0000))
end

@generate CharacterCreate

struct CharacterCreateReply
    ErrorCode::UInt16

    CharacterCreateReply() = new(0x0000)
end

@generate CharacterCreateReply

struct CharacterRemove
    Name::String
    Hash::String

    CharacterRemove() = new("", "")
end

@generate CharacterRemove

struct CharacterRemoveReply
    ErrorCode::UInt16

    CharacterRemoveReply() = new(0x0000)
end

@generate CharacterRemoveReply

struct CreatePincode
    Hash::String

    CreatePincode() = new("")
end

@generate CreatePincode

struct CreatePincodeReply
    ErrorCode::UInt16

    CreatePincodeReply() = new(0x0000)
end

@generate CreatePincodeReply

struct UpdatePincode
    OldHash::String
    Hash::String

    UpdatePincode() = new("", "")
end

@generate UpdatePincode

struct UpdatePincodeReply
    ErrorCode::UInt16

    UpdatePincodeReply() = new(0x0000)
end

@generate UpdatePincodeReply
