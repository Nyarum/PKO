
.PHONY: run
run:
	julia --project=. src/PKO.jl

test:
	julia --project=. src/tcp/packet/AuthTest.jl