


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
                    write(buf, pack(field_value))
                else
                    write(buf, ntoh(field_value))
                end
            end

            return take!(buf)
        end
    end |> esc
end

macro generate_many(struct_names...)
    structs = ()
    for struct_name in struct_names
        structs = (structs..., :(@generate($struct_name)))
    end

    quote
        for s in $structs
            eval(s)
        end
    end |> esc
end

struct Header
    len::UInt16
    id::UInt32
    opcode::UInt16
end

@generate Header