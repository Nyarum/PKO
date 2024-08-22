
function save()
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
                    value = String(read(buf, len))[1:end-1]
                elseif field_type == DataType
                    value = unpack(field_type, buf)
                else
                    value = ntoh(read(buf, field_type))
                end
                values = (values..., value)
            end

            return $struct_name_eval(values...)
        end

        function pack(val::$struct_name_eval, previous = Dict())
            buf = IOBuffer()

            for (field, field_type) in zip($fields, $types)
                field_value = getfield(val, field)

                if hasmethod(save, Tuple{$struct_name_eval, :field})
                    if save(val, field)
                        previous[field] = field_value
                    end
                end

                if hasmethod(filter, Tuple{$struct_name_eval, :field, :previous})
                    if filter(val, field, previous)
                        continue
                    end
                end

                if field_type == Vector{UInt8}
                    write(buf, hton(UInt16(length(field_value))))
                    write(buf, field_value)
                elseif field_type == String
                    write(buf, hton(UInt16(length(field_value) +1)))
                    write(buf, field_value)
                    write(buf, UInt8(0))
                elseif isstructtype(field_type)
                    if field_value isa Vector
                        for v in field_value
                            write(buf, pack(v, previous))
                        end
                    else
                        write(buf, pack(field_value, previous))
                    end
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