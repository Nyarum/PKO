
module Packet

using Revise

include("Packer.jl")

using Dates
using Printf
using .Packer

import .Packer: @packer, Opcode

@packer struct Header
    len::UInt16
    id::UInt32
    opcode::UInt16
end

@packer struct Auth
    key::Vector{UInt8}
    login::String
    password::Vector{UInt8}
    mac::String
    is_cheat::UInt16
    client_version::UInt16
end

@packer struct ItemAttr
    Attr::UInt16
    IsInit::Bool
end

@packer struct InstAttr
    ID::UInt16
    Value::UInt16
end

@packer struct ItemGrid
    ID::UInt16
    Num::UInt16
    Endure::NTuple{2,UInt16}
    Energy::NTuple{2,UInt16}
    ForgeLv::UInt8
    DBParams::NTuple{2,UInt32}
    InstAttrs::NTuple{5,InstAttr}
    ItemAttrs::NTuple{40,ItemAttr}
    IsChange::Bool
end

@packer struct Look
    Ver::UInt16
    TypeID::UInt16
    ItemGrids::NTuple{10,ItemGrid}
    Hair::UInt16
end

@packer struct Character
    IsActive::Bool
    Name::String
    Job::String
    Level::UInt16
    LookSize::UInt16
    Look::Look
end

@packer struct CharacterScreen
    ErrorCode::UInt16
    Key::Vector{UInt8}
    CharacterLen::UInt8
    Characters::Vector{Character}
    Pincode::UInt8
    Encryption::UInt32
    DWFlag::UInt32

    CharacterScreen(characters) = new(
        0x0000,
        UInt8[0x7C, 0x35, 0x09, 0x19, 0xB2, 0x50, 0xD3, 0x49],
        length(characters),
        characters,
        1,
        0x00000000,
        12820
    )
end

@packer struct CharacterCreate
    Name::String
    Map::String
    LookSize::UInt16
    Look::Look
end

@packer struct CharacterCreateReply
    ErrorCode::UInt16

    CharacterCreateReply() = new(0x0000)
end

@packer struct CharacterRemove
    Name::String
    Hash::String
end

@packer struct CharacterRemoveReply
    ErrorCode::UInt16

    CharacterRemoveReply() = new(0x0000)
end

@packer struct CreatePincode
    Hash::String

    CreatePincode(hash) = new(hash)
end

@packer struct CreatePincodeReply
    ErrorCode::UInt16

    CreatePincodeReply() = new(0x0000)
end

@packer struct UpdatePincode
    OldHash::String
    Hash::String
end

@packer struct UpdatePincodeReply
    ErrorCode::UInt16

    UpdatePincodeReply() = new(0x0000)
end

function getFirstDate()
    timeNow = now()
    return @sprintf("[%02d-%02d %02d:%02d:%02d:%03d]", month(timeNow), day(timeNow), hour(timeNow), minute(timeNow), second(timeNow), Dates.value(timeNow) % 1_000_000_000 ÷ 1_000_000)
end

# Enumeration Constants
const SynLookSwitch = 0
const SynLookChange = 1

const SYN_KITBAG_INIT = 0
const SYN_KITBAG_EQUIP = 1
const SYN_KITBAG_UNFIX = 2
const SYN_KITBAG_PICK = 3
const SYN_KITBAG_THROW = 4
const SYN_KITBAG_SWITCH = 5
const SYN_KITBAG_TRADE = 6
const SYN_KITBAG_FROM_NPC = 7
const SYN_KITBAG_TO_NPC = 8
const SYN_KITBAG_SYSTEM = 9
const SYN_KITBAG_FORGES = 10
const SYN_KITBAG_FORGEF = 11
const SYN_KITBAG_BANK = 12
const SYN_KITBAG_ATTR = 13

@packer struct Shortcut
    Type::UInt8
    GridID::UInt16
end

@packer struct CharacterShortcut
    Shortcuts::NTuple{36,Shortcut}

    CharacterShortcut() = new(
        ntuple(i -> Shortcut(0, 0), 36)
    )
end

@packer struct KitbagItem
    GridID::UInt16
    ID::UInt16
    Num::UInt16
    Endure::NTuple{2,UInt16}
    Energy::NTuple{2,UInt16}
    ForgeLevel::UInt8
    IsValid::Bool
    ItemDBInstID::UInt32
    ItemDBForge::UInt32
    BoatNull::UInt32
    ItemDBInstID2::UInt32
    IsParams::Bool
    InstAttrs::NTuple{5,InstAttr}
end

@packer struct CharacterKitbag
    Type::UInt8
    KeybagNum::UInt16
    Items::Vector{KitbagItem}

    CharacterKitbag() = new(
        0,
        0,
        Vector{KitbagItem}()
    )
end

@packer struct Attribute
    ID::UInt8
    Value::UInt32
end

@packer struct CharacterAttribute
    Type::UInt8
    Num::UInt16
    Attributes::Vector{Attribute}

    CharacterAttribute() = new(
        0,
        0,
        Vector{Attribute}()
    )
end

@packer struct SkillState
    ID::UInt8
    Level::UInt8
end

@packer struct CharacterSkillState
    StatesLen::UInt8
    States::Vector{SkillState}

    CharacterSkillState() = new(
        0,
        Vector{SkillState}()
    )
end

@packer struct CharacterSkill
    ID::UInt16
    State::UInt8
    Level::UInt8
    UseSP::UInt16
    UseEndure::UInt16
    UseEnergy::UInt16
    ResumeTime::UInt32
    RangeType::UInt16
    Params::Vector{UInt16}
end

@packer struct CharacterSkillBag
    SkillID::UInt16
    Type::UInt8
    SkillNum::UInt16
    Skills::Vector{CharacterSkill}

    CharacterSkillBag() = new(
        0,
        0,
        0,
        Vector{CharacterSkill}()
    )
end

@packer struct CharacterAppendLook
    LookID::UInt16
    IsValid::UInt8
end

@packer struct CharacterPK
    PkCtrl::UInt8

    CharacterPK() = new(
        0
    )
end

@packer struct CharacterLookBoat
    PosID::UInt16
    BoatID::UInt16
    Header::UInt16
    Body::UInt16
    Engine::UInt16
    Cannon::UInt16
    Equipment::UInt16

    CharacterLookBoat() = new(
        0,
        0,
        0,
        0,
        0,
        0,
        0
    )
end

@packer struct CharacterLookItemSync
    Endure::UInt16
    Energy::UInt16
    IsValid::UInt8
end

@packer struct CharacterLookItemShow
    Num::UInt16
    Endure::NTuple{2,UInt16}
    Energy::NTuple{2,UInt16}
    ForgeLevel::UInt8
    IsValid::UInt8
end

@packer struct CharacterLookItem
    SynType::UInt8
    ID::UInt16
    ItemSync::CharacterLookItemSync
    ItemShow::CharacterLookItemShow
    IsDBParams::UInt8
    DBParams::NTuple{2,UInt32}
    IsInstAttrs::UInt8
    InstAttrs::NTuple{5,InstAttr}

    CharacterLookItem() = new(
        0,
        0,
        CharacterLookItemSync(0, 0, 0),
        CharacterLookItemShow(0, ntuple(i -> 0, 2), ntuple(i -> 0, 2), 0, 0),
        0,
        ntuple(i -> 0, 2),
        0,
        ntuple(i -> InstAttr(0, 0), 5),
    )
end

@packer struct CharacterLookHuman
    HairID::UInt16
    ItemGrid::NTuple{10,CharacterLookItem}

    CharacterLookHuman() = new(
        2817,
        ntuple(i -> CharacterLookItem(), 10)
    )
end

@packer struct CharacterLook
    SynType::UInt8
    TypeID::UInt16
    IsBoat::UInt8
    LookBoat::CharacterLookBoat
    LookHuman::CharacterLookHuman

    CharacterLook() = new(
        0,
        4,
        0,
        CharacterLookBoat(),
        CharacterLookHuman()
    )
end

@packer struct EntityEvent
    EntityID::UInt32
    EntityType::UInt8
    EventID::UInt16
    EventName::String
end

@packer struct CharacterSide
    SideID::UInt8

    CharacterSide() = new(0)
end

@packer struct Position
    X::UInt32
    Y::UInt32
    Radius::UInt32
end

@packer struct CharacterBase
    ChaID::UInt32
    WorldID::UInt32
    CommID::UInt32
    CommName::String
    GmLvl::UInt8
    Handle::UInt32
    CtrlType::UInt8
    Name::String
    MottoName::String
    Icon::UInt16
    GuildID::UInt32
    GuildName::String
    GuildMotto::String
    StallName::String
    State::UInt16
    Position::Position
    Angle::UInt16
    TeamLeaderID::UInt32
    Side::CharacterSide
    EntityEvent::EntityEvent
    Look::CharacterLook
    PkCtrl::CharacterPK
    LookAppend::NTuple{4,CharacterAppendLook}

    CharacterBase() = new(
        240,
        212,
        1,
        "Grisha",
        0,
        0,
        0,
        "Grisha",
        "Grisha",
        0,
        0,
        "Grisha",
        "Motto",
        "StallName",
        0,
        Position(0, 0, 0),
        0,
        0,
        CharacterSide(),
        EntityEvent(0, 0, 0, ""),
        CharacterLook(),
        CharacterPK(),
        (CharacterAppendLook(0, 0), CharacterAppendLook(0, 0), CharacterAppendLook(0, 0), CharacterAppendLook(0, 0))
    )
end

# @packer Struct Definitions
@packer struct CharacterBoat
    CharacterBase::CharacterBase
    CharacterAttribute::CharacterAttribute
    CharacterKitbag::CharacterKitbag
    CharacterSkillState::CharacterSkillState

    CharacterBoat() = new(
        CharacterBase(),
        CharacterAttribute(),
        CharacterKitbag(),
        CharacterSkillState()
    )
end

@packer struct EnterGame
    EnterRet::UInt16
    AutoLock::UInt8
    KitbagLock::UInt8
    EnterType::UInt8
    IsNewChar::UInt8
    MapName::String
    CanTeam::UInt8
    CharacterBase::CharacterBase
    CharacterSkillBag::CharacterSkillBag
    CharacterSkillState::CharacterSkillState
    CharacterAttribute::CharacterAttribute
    CharacterKitbag::CharacterKitbag
    CharacterShortcut::CharacterShortcut
    BoatLen::UInt8
    CharacterBoats::Vector{CharacterBoat}
    ChaMainID::UInt32

    EnterGame() = new(
        1,
        1,
        1,
        1,
        1,
        "garner",
        1,
        CharacterBase(),
        CharacterSkillBag(),
        CharacterSkillState(),
        CharacterAttribute(),
        CharacterKitbag(),
        CharacterShortcut(),
        0,
        Vector{CharacterBoat}([]),
        240
    )
end

@packer struct EnterGameRequest
    CharacterName::String
end

end