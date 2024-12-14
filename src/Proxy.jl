using Sockets

# Function to handle proxying traffic between the client and the server
function proxy_traffic(client_socket, server_host, server_port)
    try
        # Connect to the backend server
        server_socket = connect(server_host, server_port)

        # Channels to handle bidirectional communication
        client_to_server = Channel{Nothing}(1)
        server_to_client = Channel{Nothing}(1)

        # Forward traffic from client to server
        @async begin
            try
                while true
                    data = readavailable(client_socket)
                    isempty(data) && break
                    write(server_socket, data)
                    flush(server_socket)
                end
            catch e
                println("Error forwarding client to server: $e")
            end
            close(client_to_server)
        end

        # Forward traffic from server to client
        @async begin
            try
                while true
                    data = readavailable(server_socket)
                    isempty(data) && break
                    write(client_socket, data)
                    flush(client_socket)
                end
            catch e
                println("Error forwarding server to client: $e")
            end
            close(server_to_client)
        end

        # Wait for both channels to close before cleaning up
        wait(client_to_server)
        wait(server_to_client)
    catch e
        println("Error in proxy traffic: $e")
    finally
        close(client_socket)
        close(server_socket)
    end
end

# Main function to run the TCP proxy
function start_proxy(listen_port, server_host, server_port)
    server = listen(listen_port)
    println("Proxy listening on port $listen_port, forwarding to $server_host:$server_port")

    while true
        client_socket = accept(server)
        println("Accepted connection from $(client_socket)")

        @async proxy_traffic(client_socket, server_host, server_port)
    end
end

# Example usage
# Listens on port 8080 and forwards traffic to localhost:9090
#start_proxy(8080, "127.0.0.1", 9090)
