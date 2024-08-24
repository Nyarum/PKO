include("Opcodes.jl")
include("../packet/Auth.jl")
include("Actions.jl")
include("../packet/Chars.jl")

function route(::Type{Val{create_pincode}}, buf)
    println("create pincode route")

    data = unpack(CreatePincode, buf)

    return pack(CreatePincodeReply()) |> x -> pack(create_pincode_reply, x)
end

function route(::Type{Val{create_character}}, buf)
    println("create character route")

    data = unpack(CharacterCreate, buf)

    return pack(CharacterCreateReply()) |> x -> pack(create_character_reply, x)
end

function route(::Type{Val{remove_character}}, buf)
    println("remove character route")

    data = unpack(CharacterRemove, buf)
    println(data)

    return pack(CharacterRemoveReply()) |> x -> pack(remove_character_reply, x)
end

function route(::Type{Val{update_pincode}}, buf)
    println("update pincode route")

    data = unpack(UpdatePincode, buf)
    println(data)

    return pack(UpdatePincodeReply()) |> x -> pack(update_pincode_reply, x)
end