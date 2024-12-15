function save()
end

logger = false


function pack(opcode::Opcode, data)
    data_len = length(data)

    res = IOBuffer()
    write(res, ntoh(UInt16(8 + data_len)))
    write(res, UInt32(128))
    write(res, ntoh(UInt16(opcode)))
    write(res, data)
    return take!(res)
end


function print_hex(buf)
    new_data = Vector{UInt8}()
    copy!(new_data, buf.data)
    hex_string = join(string.(new_data, base=16, pad=2), " ")

    # Print the result
    println(hex_string)
end

function _print_expr(expr, level=0)
    indent = "  "^level
    println(indent, "Head: ", expr.head)
    println(indent, "Arguments: ")
    for (i, arg) in enumerate(expr.args)
        println(indent, "  Argument $i: $arg (Type: $(typeof(arg)))")
        if arg isa Expr
            _print_expr(arg, level + 1)  # Recursive call for nested expressions
        end
    end
end

macro packer2(expr)
    _print_expr(expr)
end


macro packer_functions(struct_name)
    struct_def = esc(struct_name)
    struct_type = eval(struct_def.args[1].args[2])

    fields = fieldnames(struct_type)
    types = map(f -> fieldtype(struct_type, f), fields)

    quote
        function unpack(::Type{$struct_type}, buf)
            values = ()

            for (field, field_type) in zip($fields, $types)
                if field_type == Vector{UInt8}
                    len = ntoh(read(buf, UInt16))
                    value = read(buf, len)
                elseif field_type == String
                    len = ntoh(read(buf, UInt16))
                    value = String(read(buf, len))[1:end-1]
                elseif field_type <: NTuple
                    value = ()
                    for v in 1:fieldcount(field_type)
                        if isstructtype(field_type.parameters[1])
                            value = (value..., unpack(field_type.parameters[1], buf))
                        else
                            value = (value..., ntoh(read(buf, field_type.parameters[1])))
                        end
                    end

                    value = field_type(value)
                elseif isstructtype(field_type)
                    if field_type isa Vector
                        value = field_type()
                        for v in 1:fieldcount(field_type)
                            unpack(field_type.parameters[1], buf) |> x -> push!(value, x)
                        end
                    else
                        value = unpack(field_type, buf)
                    end
                else
                    value = ntoh(read(buf, field_type))
                end

                values = (values..., value)
            end

            return $struct_type(values...)
        end

        function pack(val::$struct_type, previous=Dict())
            buf = IOBuffer()

            for (field, field_type) in zip($fields, $types)
                field_value = getfield(val, field)

                if hasmethod(save, Tuple{$struct_type,:field})
                    if save(val, field)
                        previous[field] = field_value
                    end
                end

                if hasmethod(filter, Tuple{$struct_type,:field,:previous})
                    if filter(val, field, previous)
                        continue
                    end
                end

                if field_type == Vector{UInt8}
                    write(buf, hton(UInt16(length(field_value))))
                    write(buf, field_value)
                elseif field_type == String
                    write(buf, hton(UInt16(length(field_value) + 1)))
                    write(buf, field_value)
                    write(buf, UInt8(0))
                elseif field_value isa NTuple
                    for v in field_value
                        if isstructtype(typeof(v))
                            write(buf, pack(v, previous))
                        else
                            write(buf, v)
                        end
                    end
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

            if logger
                println("Type: ", typeof(val))

                len = 1
                if buf.ptr > 1
                    len = buf.ptr - 1
                end
                println(buf.data[1:len])
            end

            return take!(buf)
        end
    end |> esc
end

macro packer(expr)
    dump(expr)
    # Ensure the input starts with `struct`
    if expr.head !== :struct
        throw(ArgumentError("Expected `@packer2 struct ...`"))
    end

    # Extract struct name and body
    struct_name = expr.args[2]  # Second argument is the struct name (Symbol)
    body = expr.args[3]         # Third argument is the body (Expr with `head = :block`)

    # Prepare to collect fields and metadata
    fields = []
    metadata = Dict{Symbol,Any}()

    # Parse each field in the block
    for field_expr in body.args
        if field_expr isa LineNumberNode
            continue
        end

        # Check if field is a tuple (e.g., `Name::String, ("Test", true)`)
        if field_expr.head === :tuple
            # Extract field definition (e.g., `Name::String`) and attributes (e.g., `("Test", true)`)
            field_def = field_expr.args[1]
            attributes = field_expr.args[2]

            # Parse field name and type from `Name::String`
            if field_def.head === :(::)
                field_name = field_def.args[1]
                field_type = field_def.args[2]
                push!(fields, (field_name, field_type))
                metadata[field_name] = eval(attributes)
            else
                throw(ArgumentError("Field must have a type definition, e.g., Name::String"))
            end
        elseif field_expr.head === :(::)
            # Field without attributes (e.g., `Hash::String`)
            field_name = field_expr.args[1]
            field_type = field_expr.args[2]
            push!(fields, (field_name, field_type))
        else
            throw(ArgumentError("Unexpected field format"))
        end
    end

    # Generate the struct definition
    struct_fields = [Expr(:(::), field[1], field[2]) for field in fields]
    struct_def = Expr(
        :struct,
        false,
        struct_name,
        Expr(:block, struct_fields...)
    )

    eval(struct_def)

    # Return the struct definition and metadata
    quote
        @packer_functions $struct_def
        const $(Symbol(struct_name, "_metadata")) = $metadata
    end |> eval
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