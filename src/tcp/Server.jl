include("packet/FirstDate.jl")
include("packet/Pack.jl")
include("packet/Chars.jl")
include("packet/Packer.jl")
include("handler/Auth.jl")
include("handler/Opcodes.jl")
include("handler/CharScreen.jl")
include("repository/Repository.jl")

using Sockets

function handle_client(client::TCPSocket)
    println("accept client")

    write(client, getFirstDate() |> x -> pack(first_date, x))

    # Read data from the client
    while isopen(client)
        try
            data = readavailable(client)
            if length(data) == 2
                write(client, data)
                continue
            end

            buf = IOBuffer(data)

            header = unpack(Header, buf)
            println("Received from client: ", header.opcode)

            errormonitor(@async begin
                res = Opcode(header.opcode) |> x -> route(x, buf)
                if res == a_exit
                    close(client)
                    return
                end

                write(client, res)
            end)
        catch e
            if e isa EOFError
                return
            end

            showerror(stdout, e, catch_backtrace())
            break  # Exit the loop if an error occurs (like client disconnection)
        end
    end
    
    println("Client disconnected")
end

atexit(save_database(accounts))

# Create and run the TCP server
function start_server(port::Int)
    server = listen(IPv4(0), port)
    println("Server is listening on port $port")

    load_database()
    
    while true
        client = accept(server) # Accept a new client
        @async handle_client(client) # Handle the client asynchronously
    end
end