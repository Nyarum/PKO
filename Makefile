
.PHONY: run
run:
	julia --project=. src/PKO.jl

test:
	julia --project=. src/tcp/packet/AuthTest.jl
	julia --project=. src/tcp/packet/CharsTest.jl
	julia --project=. src/tcp/packet/WorldTest.jl