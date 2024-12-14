
build:
	cd libs && gcc -shared -fPIC -o libraylib_combined.so \
    combined.c \
    raylib/src/rcore.c raylib/src/rshapes.c raylib/src/rtextures.c raylib/src/rtext.c \
    raylib/src/rmodels.c raylib/src/raudio.c raylib/src/utils.c \
    raylib/src/rglfw.c \
    -I./raylib/src -I./raygui/src -lm -ldl -lpthread -lX11 -DPLATFORM_DESKTOP -DSUPPORT_X11 -D_GLFW_X11

.PHONY: run-gui-w
run-gui-w:
	julia --project=. src/Utils/GUI.jl

.PHONY: run-gui
run-gui: build
	julia --project=. src/Utils/GUI.jl

.PHONY: run-proxy
run-proxy:
	julia --project=. src/PKO.jl proxy

.PHONY: run
run:
	julia --project=. src/PKO.jl

test:
	julia --project=. src/tcp/packet/AuthTest.jl
	julia --project=. src/tcp/packet/CharsTest.jl
	julia --project=. src/tcp/packet/WorldTest.jl