
macro generate_pack_function(struct_name)
    esc(quote
        function pack(x::$struct_name)::Vector{UInt8}
            buffer = Vector{UInt8}()
            for field in fieldnames($struct_name)
                value = getfield(x, field)
                push!(buffer, reinterpret(UInt8, [value])...)
            end
            return buffer
        end
    end)
end

macro generate_unpack_function(struct_name)
    fields = fieldnames(eval(struct_name))
    types = map(f -> fieldtype(eval(struct_name), f), fields)

    quote
        function unpack(::Type{$struct_name}, buf)
            values = ()

            for (field, field_type) in zip($fields, $types)
                if field_type == Vector{UInt8}
                    len = ntoh(read(buf, UInt16))
                    value = read(buf, len)
                elseif field_type == String
                    len = ntoh(read(buf, UInt16))
                    value = String(read(buf, len))
                else
                    value = ntoh(read(buf, field_type))
                end
                values = (values..., value)
            end

            return $struct_name(values...)
        end
    end |> esc
end

struct MyStruct
    a::Int32
    b::Float64
    c::UInt8
end

@generate_pack_function MyStruct

println(@macroexpand @generate_pack_function MyStruct)

println(pack(MyStruct(1, 2, 3)))

struct Auth
    key::Vector{UInt8}
    login::String
    password::Vector{UInt8}
    mac::String
    is_cheat::UInt16
    client_version::UInt16
end
