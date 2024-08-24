using Base.Threads
using DataFrames
import Dates
import CSV

local_lock = ReentrantLock()

accounts = DataFrame()

function save_account(login, password)
    lock(local_lock) do
        row_index = findfirst(row -> row.login == login, eachrow(accounts))

        println(row_index)

        if row_index === nothing
            push!(accounts, (id=rand((1, 1000000)), login=login, password=password, created_at=Dates.now(), characters=[]))
        end
    end
end

function save_database(accounts)
    return function()
        lock(local_lock) do
            CSV.write("accounts.csv", accounts)
        end
    end
end

function load_database()
    lock(local_lock) do
        test = CSV.read("accounts.csv", DataFrame)
        accounts = copy(test)
        println(accounts)
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