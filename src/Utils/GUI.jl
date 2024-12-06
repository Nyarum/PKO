# Paths to the dynamic libraries
const raylib_lib = "libs/libraylib_combined.so"

# Import Raylib functions
function InitWindow(width::Int, height::Int, title::String)
    ccall((:InitWindow, raylib_lib), Cvoid, (Cint, Cint, Cstring), width, height, title)
end

function CloseWindow()
    ccall((:CloseWindow, raylib_lib), Cvoid, ())
end

function WindowShouldClose()::Bool
    ccall((:WindowShouldClose, raylib_lib), Bool, ())
end

function BeginDrawing()
    ccall((:BeginDrawing, raylib_lib), Cvoid, ())
end

function EndDrawing()
    ccall((:EndDrawing, raylib_lib), Cvoid, ())
end

function ClearBackground(color::UInt32)
    ccall((:ClearBackground, raylib_lib), Cvoid, (UInt32,), color)
end

# Import Raygui functions
function GuiButton(bounds, text::String)::Bool
    rect = (bounds[1], bounds[2], bounds[3], bounds[4])
    ccall((:GuiButton, raylib_lib), Bool, (NTuple{4,Cfloat}, Cstring), rect, text)
end

# Helper function for colors
function Color(r::UInt8, g::UInt8, b::UInt8, a::UInt8)::UInt32
    return (a << 24) | (b << 16) | (g << 8) | r
end

# Main function
function main()
    InitWindow(800, 600, "Raylib + Raygui in Julia")
    button_bounds = (350.0f0, 280.0f0, 100.0f0, 50.0f0)

    while !WindowShouldClose()
        BeginDrawing()
        ClearBackground(Color(UInt8(245), UInt8(245), UInt8(245), UInt8(255)))

        # Draw a button
        if GuiButton(button_bounds, "Click Me")
            println("Button clicked!")
        end

        EndDrawing()
    end

    CloseWindow()
end

main()
