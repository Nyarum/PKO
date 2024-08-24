include("Opcodes.jl")
include("../packet/Auth.jl")
include("Actions.jl")
include("../packet/Chars.jl")
include("../repository/Repository.jl")
include("Context.jl")

function route(::Type{Val{auth}}, buf)
    println("auth route")

    auth_body = unpack(Auth, buf)
    println(auth_body)

    save_account(auth_body.login, auth_body.password)

    println(accounts)

    save_login(context, auth_body.login)

    return pack(CharacterScreen()) |> x -> pack(response_chars, x)
end

function route(::Type{Val{exit}}, buf)
    println("exit route")

    return a_exit
end

route(v::Opcode, data) = route(Val{v}, data)