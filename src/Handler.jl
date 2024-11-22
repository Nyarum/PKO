

using Base.Threads

@enum Opcode auth=431 exit=432 response_chars=931 first_date=940 create_pincode=346 create_pincode_reply=941 create_character=435 create_character_reply=935 remove_character=436 remove_character_reply=936 update_pincode=347 update_pincode_reply=942

@enum Action a_exit=1

context = Dict()
local_lock = SpinLock()


function save_login(context, login)
    lock(local_lock) do
        context[:login] = login
    end
end

function get_login(context)
    lock(local_lock) do
        return context[:login]
    end
end

route(v::Opcode, data) = route(Val{v}, data)

function route(::Type{Val{auth}}, buf)
    println("auth route")

    auth_body = unpack(Auth, buf)

    save_account(auth_body.login, auth_body.password)
    save_login(context, auth_body.login)

    account = get_account(auth_body.login)

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

function route(::Type{Val{create_pincode}}, buf)
    println("create pincode route")

    data = unpack(CreatePincode, buf)

    return pack(CreatePincodeReply()) |> x -> pack(create_pincode_reply, x)
end

function route(::Type{Val{create_character}}, buf)
    println("create character route")

    data = unpack(CharacterCreate, buf)

    add_character(get_login(context), data)

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