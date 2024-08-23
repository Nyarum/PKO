include("Opcodes.jl")
include("../packet/Auth.jl")
include("Actions.jl")
include("../packet/Chars.jl")

function route(::Type{Val{create_pincode}}, buf)
    println("auth route")

    create_pincode = unpack(CreatePincode, buf)
    println(create_pincode)

    return pack(CreatePincodeReply()) |> x -> pack(create_pincode_reply, x)
end