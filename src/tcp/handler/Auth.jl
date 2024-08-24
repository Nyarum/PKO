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

    characters = ()
    println(length(account.characters))
    println(account.characters[1])
    for ch in account.characters
        println(ch.name)
        #characters = (characters..., Character(true, char.name, "job", 1, char.lookSize, char.look))
    end

    return pack(CharacterScreen([])) |> x -> pack(response_chars, x)
end

function route(::Type{Val{exit}}, buf)
    println("exit route")

    return a_exit
end

route(v::Opcode, data) = route(Val{v}, data)