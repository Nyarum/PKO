using Base.Threads
using DataFrames
import Dates
import CSV
using UUIDs
import JSON

include("../packet/Chars.jl")

local_lock = ReentrantLock()

accounts = DataFrame(
    id = String[],
    login = String[],
    password = String[],
    created_at = Dates.DateTime[],
    characters = CharacterCreate[]
)
rng = UUIDs.MersenneTwister(1234);

function save_account(login, password)
    println(accounts)
    lock(local_lock) do
        row_index = findfirst(row -> row.login == login, eachrow(accounts))

        if row_index === nothing
            push!(accounts, (id=string(UUIDs.uuid4(rng)), login=login, password=string(password), created_at=Dates.now(), characters=CharacterCreate[]))
        end
    end
end

function get_account(login)
    lock(local_lock) do
        return accounts[accounts.login .== login, :]
    end
end

function save_database()
    lock(local_lock) do
        CSV.write("accounts.csv", accounts)
    end
end

atexit(save_database)

function load_database()
    global accounts = CSV.read("accounts.csv", DataFrame)
    println(accounts)
end

# Function to update the 'characters' field for a specific login
function add_character(login::String, new_character)
    lock(local_lock) do
        # Find the row index where 'login' matches
        row_index = findfirst(row -> row.login == login, eachrow(accounts))

        # Check if the row was found
        if row_index !== nothing
            println(row_index)
            println(accounts[row_index, :characters])

            # Update the 'characters' field
            accounts[row_index, :characters] = JSON.json(new_character)
        else
            println("Login not found")
        end
    end
end