include("packet/FirstDate.jl")
include("packet/Pack.jl")
include("packet/Chars.jl")
include("packet/Packer.jl")
include("handler/Auth.jl")

using Sockets

function handle_client(client::TCPSocket)
    println("accept client")

    write(client, getFirstDate() |> x -> pack(940, x))

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

            res = Opcode(header.opcode) |> x -> route(x, buf)
            if typeof(res) == Action && res == a_exit
                break
            end

            write(client, res)
        catch e
            println("Error occurred: ", e)
            break  # Exit the loop if an error occurs (like client disconnection)
        end
    end
    
    println("Client disconnected")
    close(client)
end

# Create and run the TCP server
function start_server(port::Int)
    server = listen(IPv4(0), port)
    println("Server is listening on port $port")
    
    while true
        client = accept(server) # Accept a new client
        @async handle_client(client) # Handle the client asynchronously
    end
end