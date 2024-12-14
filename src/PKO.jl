println("Loading PKO.jl...")

include("Server.jl")
include("Proxy.jl")

using JET

if length(ARGS) > 0 && ARGS[1] == "proxy"
    start_proxy(1973, "192.168.0.10", 1973)
else
    start_server(1973)
end
