using Base.Threads
using DataFrames
import Dates
import CSV
using UUIDs
import JLD2

include("../packet/Chars.jl")

local_lock = ReentrantLock()

accounts = DataFrame()
rng = UUIDs.MersenneTwister(1234);

function save_account(login, password)
    println(accounts)
    lock(local_lock) do
        row_index = findfirst(row -> row.login == login, eachrow(accounts))

        if row_index === nothing
            push!(accounts, (id=string(UUIDs.uuid4(rng)), login=login, password=string(password), created_at=Dates.now(), characters=[]))
        end
    end
end

function get_account(login)
    lock(local_lock) do
        return filter(row -> row[:login] == login, eachrow(accounts))[1]
    end
end

function save_database()
    lock(local_lock) do
        JLD2.save("accounts.jld2", "accounts", accounts)
    end
end

atexit(save_database)

function load_database()
    global accounts = JLD2.load("accounts.jld2", "accounts")
    println(accounts)
end

# Function to update the 'characters' field for a specific login
function add_character(login::String, new_character)
    lock(local_lock) do
        # Find the row index where 'login' matches
        row_index = findfirst(row -> row.login == login, eachrow(accounts))

        # Check if the row was found
        if row_index !== nothing
            # Update the 'characters' field
            println(accounts[row_index, :characters])
            println(typeof(accounts[row_index, :characters]))
            push!(accounts[row_index, :characters], new_character)
            println(typeof(accounts[row_index, :characters]))
        else
            println("Login not found")
        end
    end
end