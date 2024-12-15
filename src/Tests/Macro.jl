include("../Opcodes.jl")
include("../Packer.jl")

@packer struct CharacterRemove2
    Name::String, Dict("One" => true, "test2" => false)
    Hash::String
end

@packer struct CharacterRemove
    One::Int, :save
    Bro::CharacterRemove2
end

println(CharacterRemove(1, CharacterRemove2("", "")))

println(CharacterRemove2_metadata[:Name]["Test"])