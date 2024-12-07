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

struct RaylibColor
    r::UInt8
    g::UInt8
    b::UInt8
    a::UInt8
end

function ClearBackground(color::RaylibColor)
    ccall((:ClearBackground, raylib_lib), Cvoid, (RaylibColor,), color)
end

# Import Raygui functions
function GuiButton(bounds, text::String)::Bool
    rect = (bounds[1], bounds[2], bounds[3], bounds[4])
    ccall((:GuiButton, raylib_lib), Bool, (NTuple{4,Cfloat}, Cstring), rect, text)
end

function DrawRectangle(x::Int, y::Int, width::Int, height::Int, color::RaylibColor)
    ccall((:DrawRectangle, raylib_lib), Cvoid, (Cint, Cint, Cint, Cint, RaylibColor), x, y, width, height, color)
end

function Color(r::UInt8, g::UInt8, b::UInt8, a::UInt8)::RaylibColor
    return RaylibColor(r, g, b, a)
end

# Define supporting structs for Texture2D, Rectangle, and GlyphInfo
struct Texture2D
    id::UInt32            # OpenGL texture id
    width::Cint           # Texture base width
    height::Cint          # Texture base height
    mipmaps::Cint         # Mipmap levels, 1 by default
    format::Cint          # Data format (PixelFormat type)
end

struct Image
    data::Ptr{Cvoid}  # corresponds to void*
    width::Cint       # corresponds to int
    height::Cint      # corresponds to int
    mipmaps::Cint     # corresponds to int
    format::Cint      # corresponds to int
end

struct Rectangle
    x::Cfloat
    y::Cfloat
    width::Cfloat
    height::Cfloat
end

struct GlyphInfo
    value::Cint           # Character value (Unicode)
    offsetX::Cint         # Character offset X when drawing
    offsetY::Cint         # Character offset Y when drawing
    advanceX::Cint        # Character advance position X
    image::Image      # Character image (glyph)
end

# Define the Font struct
mutable struct Font
    baseSize::Cint        # Base size (default chars height)
    glyphCount::Cint      # Number of glyph characters
    glyphPadding::Cint    # Padding around the glyph characters
    texture::Texture2D    # Texture atlas containing the glyphs
    recs::Ptr{Rectangle}  # Rectangles in texture for the glyphs
    glyphs::Ptr{GlyphInfo}  # Glyphs info data
end

function LoadFontEx(fileName::String, fontSize::Int, codepoints::Union{Vector{Int64},Nothing}, codepointCount::Int)
    codepoints_ptr = codepoints === nothing ? C_NULL : pointer(codepoints)

    ccall((:LoadFontEx, raylib_lib), Font,
        (Cstring, Cint, Ptr{Cint}, Cint),
        fileName, Cint(fontSize), codepoints_ptr, Cint(codepointCount))
end


function GuiSetFont(font::Font)
    ccall((:GuiSetFont, raylib_lib), Cvoid, (Font,), font)
end

function DrawTextEx(font::Ptr{Cvoid}, text::String, position::NTuple{2,Float32}, fontSize::Float32, spacing::Float32, color::RaylibColor)
    ccall((:DrawTextEx, raylib_lib), Cvoid, (Ptr{Cvoid}, Cstring, NTuple{2,Cfloat}, Cfloat, Cfloat, Ref{RaylibColor}), font, text, position, fontSize, spacing, color)
end

function glyph_to_string(glyph::GlyphInfo)::String
    try
        return string(
            "GlyphInfo(",
            "value: ", Char(glyph.value), " (", glyph.value, "), ",
            "offsetX: ", glyph.offsetX, ", ",
            "offsetY: ", glyph.offsetY, ", ",
            "advanceX: ", glyph.advanceX, ", ",
            "image: ", glyph.image,
            ")"
        )
    catch
        return string(
            "GlyphInfo(",
            "value: ", glyph.value, " (", glyph.value, "), ",
            "offsetX: ", glyph.offsetX, ", ",
            "offsetY: ", glyph.offsetY, ", ",
            "advanceX: ", glyph.advanceX, ", ",
            "image: ", glyph.image,
            ")"
        )
    end
end

function glyphs_to_strings(glyphs::Vector{GlyphInfo})
    return [glyph_to_string(glyph) |> println for glyph in glyphs]
end

function generate_codepoints_cyrillic()
    # Initialize an array of length 512 filled with zeros
    codepoints = fill(0, 512)

    # In C, arrays start at index 0, but in Julia they start at index 1.
    # For i in 0:94 in C becomes i in 0:94 in Julia, but we store at i+1.
    for i in 0:94
        codepoints[i+1] = 32 + i
    end

    # Similarly, for i in 0:254 in C corresponds to i in 0:254 in Julia.
    # codepoints[96 + i] in C becomes codepoints[(96 + i) + 1] in Julia.
    for i in 0:254
        codepoints[(96+i)+1] = 0x400 + i
    end

    return codepoints
end

# GuiSetStyle function
function GuiSetStyle(control::Int, property::Int, value::Int)
    ccall((:GuiSetStyle, raylib_lib), Cvoid, (Int32, Int32, Int32), control, property, value)
end

# Main function
function main()
    InitWindow(800, 600, "Raylib + Raygui in Julia")

    # Define header and button bounds
    header_height = 60.0f0
    logo_bounds = (10.0f0, 10.0f0, 30.0f0, 30.0f0) # x, y, width, height
    button1_bounds = (700.0f0, 10.0f0, 80.0f0, 30.0f0)
    button2_bounds = (610.0f0, 10.0f0, 80.0f0, 30.0f0)

    codepoints = generate_codepoints_cyrillic()
    font = LoadFontEx(abspath("fonts/Roboto-Black.ttf"), 32, codepoints, codepoints |> length)
    GuiSetFont(font)
    GuiSetStyle(0, 16, 11)

    while !WindowShouldClose()
        BeginDrawing()
        ClearBackground(Color(UInt8(255), UInt8(255), UInt8(255), UInt8(255)))

        DrawRectangle(0, 0, 800, 50, Color(UInt8(117), UInt8(191), UInt8(154), UInt8(255)))

        # Draw buttons in the header
        if GuiButton(button1_bounds, "Регистрация")
            println("Button 1 clicked!")
        end

        if GuiButton(button2_bounds, "Авторизация")
            println("Button 2 clicked!")
        end

        EndDrawing()
    end

    CloseWindow()
end

main()
