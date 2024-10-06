module ActorLike
    import Base.Threads

    # Define a Client structure
    struct Client
        id::Int
    end

    # Define a Connect message structure
    struct Connect
        client_id::Int
    end

    # Define the Storage structure
    struct Storage
        map::Dict{DataType, Vector{Any}}  # Maps message types to actors
    end

    # Handle function to process Connect messages for a Client actor
    function handle(actor::Client, msg::Connect)
        println("Client $(actor.id) handling connection from client $(msg.client_id)")
    end

    mutex = ReentrantLock()
    storage = Storage(Dict{DataType, Vector{Any}}())

    # Subscribe function to map message types (actions) to actors
    function subscribe(storage::Storage, actor::Any, actions::Vector{DataType})
        for action in actions
            lock(mutex)
            if !haskey(storage.map, action)
                storage.map[action] = Vector{Any}()  # Initialize an empty vector for the message type if not already present
            end
            push!(storage.map[action], actor)  # Add the actor to the list for this message type
            unlock(mutex)
        end
    end

    # Send function to trigger actions for actors based on message type
    function send(storage::Storage, msg::Any)
        action_type = typeof(msg)  # Get the type of the message
        lock(mutex)
        if haskey(storage.map, action_type)
            actors = storage.map[action_type]  # Get all actors subscribed to the message type
            for actor in actors
                @async handle(actor, msg)  # Call the handle function for each actor with the message
            end
        else
            println("No actors subscribed to message type $(action_type)")
        end
        unlock(mutex)
    end

    # Example usage
    function main()
        # Initialize storage
        storage = Storage(Dict{DataType, Vector{Any}}())

        # Create a client
        client1 = Client(1)

        # Subscribe the client to handle `Connect` messages
        actions = [Connect]
        subscribe(storage, client1, actions)

        # Create a client
        client1 = Client(2)

        # Subscribe the client to handle `Connect` messages
        actions = [Connect]
        subscribe(storage, client1, actions)

        # Create a connect message
        msg = Connect(2)  # Client with ID 2 connecting

        # Send the `Connect` message to all subscribed actors
        send(storage, msg)

        sleep(1)  # Wait for the message to be handled
    end

end # module ActorLike

# Call main to run the example
ActorLike.main()