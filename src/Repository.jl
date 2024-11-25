

module Repository

import Dates
import CSV
import JLD2

using Base.Threads
using DataFrames
using UUIDs

local_lock = SpinLock()

accounts = DataFrame()
rng = UUIDs.MersenneTwister(1234)


function save_database()
    while true
        sleep(5)
        lock(local_lock) do
            JLD2.save("./accounts.jld2", "accounts", accounts)
        end
    end
end

function load_database()
    try
        global accounts = JLD2.load("accounts.jld2", "accounts")
    catch e
        println("Database wasn't ready but it doesn't matter at first start :)")
    end
end


function save_account(login, password)
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

# Function to update the 'characters' field for a specific login
function add_character(login::String, new_character)
    lock(local_lock) do
        # Find the row index where 'login' matches
        row_index = findfirst(row -> row.login == login, eachrow(accounts))

        # Check if the row was found
        if row_index !== nothing
            # Update the 'characters' field
            push!(accounts[row_index, :characters], new_character)
        else
            println("Login not found")
        end
    end
end

end