using Sockets: accept_nonblock
module PKO

greet() = print("Hello World!")

end # module PKO

using Sockets

function handle_client(client::TCPSocket)
    println("testst")
    println("Client connected: ")

    ip, test = getpeername(client)
    println(ip)

    test = 1
    
    
    
    # Read data from the client
    while !eof(client)
        data = readline(client)
        println("Received from client: ", data)
        
        # Echo the received data back to the client
        write(client, "Server received: $data\n")
    end
    
    println("Client disconnected")
    close(client)
end

# Create and run the TCP server
function start_server(port::Int)
    server = listen(port)
    println("Server is listening on port $port")
    
    while true
        print("accept client")
        client = accept_nonblock(server) # Accept a new client
        @async handle_client(client) # Handle the client asynchronously
    end
end

# Start the server on port 1234
start_server(9999)

