
using Base.Threads

context = Dict()
local_lock = ReentrantLock()

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