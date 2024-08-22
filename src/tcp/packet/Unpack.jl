

module Packer
    export @generate, pack, unpack

    struct Default
    end

    function pack(val::Default)
    end

    macro generate(struct_name)
        fields = fieldnames(eval(struct_name))
        types = map(f -> fieldtype(eval(struct_name), f), fields)
        struct_name_eval = eval(struct_name)

        quote
            function unpack(::Type{$struct_name_eval}, buf)
                values = ()

                for (field, field_type) in zip($fields, $types)
                    if field_type == Vector{UInt8}
                        len = ntoh(read(buf, UInt16))
                        value = read(buf, len)
                    elseif field_type == String
                        len = ntoh(read(buf, UInt16))
                        value = String(read(buf, len))
                    elseif field_type == DataType
                        value = unpack(field_type, buf)
                    else
                        value = ntoh(read(buf, field_type))
                    end
                    values = (values..., value)
                end

                return $struct_name_eval(values...)
            end

            function pack(val::$struct_name_eval)
                buf = IOBuffer()
                values = ()


                for (field, field_type) in zip($fields, $types)
                    field_value = getfield(val, field)

                    if field_type == Vector{UInt8}
                        write(buf, UInt16(ntoh(length(field_value))))
                        write(buf, field_value)
                    elseif field_type == String
                        write(buf, UInt16(ntoh(length(field_value))))
                        write(buf, field_value)
                    elseif isstructtype(field_type)
                        println(field_value)
                        write(buf, pack(field_value))
                    else
                        write(buf, ntoh(field_value))
                    end
                end

                return take!(buf)
            end
        end |> esc
    end
end

using .Packer

struct Bro
    test::UInt8
end


@generate Main.Bro

println(pack(Bro(1)))

#=
println(@macroexpand @Packer.generate :Bro begin
    test::UInt8
end
)

@Packer.generate :Header begin
    len::UInt16
    id::UInt32
    opcode::UInt16
    bro::Bro
end

Bro(1)

println(@macroexpand @generate :Header begin
    len::UInt16
    id::UInt32
    opcode::UInt16
end)

println(pack(Packer.Header(1, 2, 3, Packer.Bro(2))))
=#