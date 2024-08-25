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
    save_login(context, auth_body.login)

    account = get_account(auth_body.login)
    println("account")

    characters = Character[]
    for char in account.characters
        push!(characters, Character(true, char.Name, "job", 1, char.LookSize, char.Look))
    end

    return pack(CharacterScreen(characters)) |> x -> pack(response_chars, x)
end

function route(::Type{Val{exit}}, buf)
    println("exit route")

    return a_exit
end

route(v::Opcode, data) = route(Val{v}, data)