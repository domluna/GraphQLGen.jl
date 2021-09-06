const DEFAULT_TYPE_MAP = Dict{Symbol,Symbol}(
    :Float => :Float64, # graphql Float is Float64
    :Int => :Int32, # graphql Int is Int32
    :Boolean => :Bool,
    :ID => :String, # serialized as a String but not intended to be human-readable
)

const BUILTIN_GRAPHQL_TYPES = Set{Symbol}([:ID, :Int, :String, :Float, :Boolean])

function get_schema_types(doc::Document)
    schema_types = Set{Symbol}()
    for d in doc
        if d isa SchemaDefinition
            union!(schema_types, get_schema_types(d))
        end
    end
    return schema_types
end

function get_schema_types(sd::SchemaDefinition)
    schema_types = Set{Symbol}()
    for o in sd.operation_type_definitions
        if o.operation_type === "query" ||
           o.operation_type === "mutation" ||
           o.operation_type === "subscription"
            push!(schema_types, jltype(o.named_type.type))
        end
    end
    return schema_types
end

function tojl(doc::Document, scalar_type_map::Dict)
    schema_types = get_schema_types(doc)
    doc, revisited_graph = dagify(doc)
    types = Expr[]
    functions = Expr[]

    for d in doc
        if d isa TypeDefinition && d.type isa ObjectTypeDefinition && jltype(d.type.name) in schema_types
            jlfuncs = jlfunction(d)
            for f in jlfuncs
                push!(functions, f)
            end
        else
            jlt = jltype(d, revisited_graph, scalar_type_map)
            if !isnothing(jlt)
                push!(types, jlt)
            end
        end
    end

    return types, functions
end
tojl(doc::Document) = tojl(doc, Dict())

jltype(x) = nothing

function jltype(t::TypeDefinition, revisited_graph::Dict{Symbol,Set{Symbol}}, scalar_type_map::Dict)
    docstr = isnothing(something(t.description)) ? "" : jltype(t.description) 
    typ = t.type
    ex = if typ isa ScalarTypeDefinition
        jltype(typ, scalar_type_map)
    elseif typ isa ObjectTypeDefinition
        jltype(typ, revisited_graph)
    elseif typ isa InputObjectTypeDefinition
        jltype(typ, revisited_graph)
    else
        jltype(typ)
    end

    docstr == "" && return ex
    docstr = strip(docstr)

    ex = if typ isa ScalarTypeDefinition || typ isa UnionTypeDefinition
        :(Core.@doc $docstr $ex)
    else
        quote
            $("\"\"\"\n$docstr\n\"\"\"")
            # ignore initial LineNumberNode
            $(ex.args[2:end]...)
        end
    end

    return ex
end

function jltype(name::Symbol, fields::Vector{JLKwField}, graph::Dict{Symbol,Set{Symbol}})
    sort!(fields, lt = (e1, e2) -> e1.default isa NoDefault && !(e2 isa NoDefault))

    st = JLKwStruct(;ismutable=true, name=name, fields=fields)

    ex = if false
        quote
            $(codegen_ast(st))

            StructTypes.StructType(::Type{$name}) = StructTypes.Mutable()

            StructTypes.omitempties(::Type{$name}) = true

            $(codegen_ast(generate_custom_getproperty!(fields, name, graph[name])))
        end
    else
        quote
            $(codegen_ast(st))

            StructTypes.StructType(::Type{$name}) = StructTypes.Mutable()
            StructTypes.omitempties(::Type{$name}) = true
        end
    end

    return ex
end

function jltype(t::ObjectTypeDefinition, graph::Dict{Symbol,Set{Symbol}})
    name = jltype(t.name)
    fields = map(t.fields_definition) do fd
        jltype(fd)
    end

    return jltype(name, fields, graph)
end

jlfunction(t::TypeDefinition) = jlfunction(t.type)

function jlfunction(t::ObjectTypeDefinition)
    name = jltype(t.name)
    functions = map(t.fields_definition) do fd
        jlfunction(fd, name)
    end

    return functions
end

function jltype(t::InputObjectTypeDefinition, graph::Dict{Symbol,Set{Symbol}})
    name = jltype(t.name)
    fields = map(t.fields) do f
        jltype(f)
    end

    return jltype(name, fields, graph)
end

function jltype(t::FieldDefinition)
    name = jltype(t.name)
    typ = jltype(t.type)

    kw = if !t.type.non_null
        JLKwField(; name=name, type=typ, default=:nothing)
    else
        JLKwField(; name=name, type=typ)
    end

    if !isnothing(something(t.description))
        kw.doc = jltype(t.description)
    end

    return kw
end

function jltype(t::ArgumentsDefinition)
    return jltype.(t.input_value_definitions)
end

function jlfunction(t::FieldDefinition, stype::Symbol)
    name = jltype(t.name)
    typ = jltype(t.type)
    argdefs = if isnothing(t.arguments_definition)
        JLKwField[]
    else
        jltype(t.arguments_definition)::Vector{JLKwField}
    end

    args = filter(e -> e.default isa NoDefault, argdefs)
    kwargs = filter(e -> !(e.default isa NoDefault), argdefs)

    # Recover the original graphql syntax so that
    # the function signature can be used in the graphql response
    funcsigs = if isnothing(t.arguments_definition)
        []
    else
        gqlstr(t.arguments_definition)
    end
    # NOTE: not sure if keyword arguments need to come last
    sort!(funcsigs, by = s -> s.default)

    sig = join(map(funcsigs) do s
        v = "$(s.name): $(s.typ)"
        if s.default != ""
            v *= " = $(s.default)"
        end
        v
    end, ", ")

    input = join(map(funcsigs) do s
        "$(s.name): \$$(s.name)"
    end, ", ")

    variable_args = map(args) do a
        e = a.name
        :($("$e") => $e)
    end
    variable_kw = map(kwargs) do kw
        e = kw.name
        :($("$e") => $e)
    end

    body = quote
            q = s -> $("""
            $(lowercase(string(stype))) $(uppercasefirst(string(name)))($sig) {
            $(name)($input) {
            """) * s * """
            }
            }"""

            query = q(f.query)
            variables = Dict($(variable_args...), $(variable_kw...))
            filter!(v -> !isnothing(v[2]), variables)

            return (; query, variables)
    end

    jlf = JLFunction(;name=name, args=args, kwargs=kwargs, body=body, )
    @info "" args kwargs funcsigs jlf map(kw -> kw.default, kwargs)

    quote
        struct $name
            query::String
        end

        $(codegen_ast(jlf))
    end
end

function jltype(t::InputValueDefinition)
    name = jltype(t.name)
    typ = jltype(t.type)

    kw = if !t.type.non_null
        JLKwField(; name=name, type=typ, default=jltype(t.default_value))
    else
        JLKwField(; name=name, type=typ)
    end

    if !isnothing(something(t.description))
        kw.doc = jltype(t.description)
    end

    return kw
end

function jltype(t::UnionTypeDefinition)
    name = jltype(t.name)
    types = map(something(t.types)) do tt
        jltype(tt.type)
    end
    lhs = Expr(:curly, :Union, types...)
    return Expr(:const, Expr(:(=), name, lhs))
end

function jltype(t::EnumTypeDefinition)
    name = jltype(t.name)
    enums = map(jltype, t.enums)
    ex = quote
        @enum $name begin
            $(enums...)
        end
    end
    return ex
end

function jltype(t::EnumValueDefinition)
    jltype(t.value)
end

function jltype(t::ScalarTypeDefinition, scalar_type_map::Dict)
    name = jltype(t.name)
    typ = get(scalar_type_map, name, Any)
    return Expr(:const, Expr(:(=), name, typ))
end

function jltype(t::NamedType)
    typ = jltype(t.type)
    typ = get(DEFAULT_TYPE_MAP, typ, typ)
    if !t.non_null
        :(Union{$typ,Missing,Nothing})
    else
        typ
    end
end

function jltype(t::ListType)
    typ = :(Vector{$(jltype(t.type))})
    if !t.non_null
        :(Union{$typ,Missing,Nothing})
    else
        typ
    end
end
jltype(t::DefaultValue) = jltype(t.value)
jltype(t::RBNF.Token) = Symbol(t.str)
jltype(t::RBNF.Token{:int_value}) = Base.parse(Int32, t.str)
jltype(t::RBNF.Token{:float_value}) = Base.parse(Float64, t.str)
jltype(t::RBNF.Token{:single_quote_string_value}) = convert(String, t)
jltype(t::RBNF.Token{:triple_quote_string_value}) = convert(String, t)
jltype(t::Some) = jltype(something(t))
jltype(t::Nothing) = :nothing

"""
Returns the string GraphQL representation of the parsed GraphQL type.

In a sense it's a "reverse parse".
"""
function gqlstr end

function gqlstr(t::ArgumentsDefinition)
    map(t.input_value_definitions) do iv
        gqlstr(iv)
    end
end

function gqlstr(t::InputValueDefinition)
    name = gqlstr(t.name)
    typ = gqlstr(t.type)
    default = gqlstr(t.default_value)
    (; name, typ, default)
end

function gqlstr(t::NamedType)
    s = gqlstr(t.type)
    t.non_null && (s *= "!")
    s
end

function gqlstr(t::ListType)
    s = "[$(gqlstr(t.type))]"
    t.non_null && (s *= "!")
    s
end
gqlstr(t::DefaultValue) = gqlstr(t.value)
gqlstr(t::RBNF.Token) = t.str
gqlstr(::Nothing) = ""

"""
    generate_custom_getproperty!(fields::Vector{JLKwField}, typename::Symbol, cyclic_types::Set{Symbol})

Generates a custom `Base.getproperty` function for the type `typename`. This is done
in effort to preserve type inference of fields there the type has to be removed due to
definitioning types in a cyclic order.

    !!! The `fields` argument is mutated by removing type information for cyclic fields.
"""
function generate_custom_getproperty!(
    fields::Vector{JLKwField},
    typename::Symbol,
    cyclic_types::Set{Symbol},
)
    fnames = Symbol[]
    ftyps = Union{Expr,Symbol}[]

    for (i, f) in enumerate(fields)
        non_null_type = f.head === :(::)
        fname, ftyp = if non_null_type
            f.args[1], f.args[2]
        else
            f.args[1].args[1], f.args[1].args[2]
        end

        ft = if ftyp isa Symbol
            ftyp
        else
            filter(ft -> !in(ft, [:Union, :Missing, :Nothing]), ftyp.args)[1]
        end
        ft in cyclic_types || continue

        push!(fnames, fname)
        push!(ftyps, ftyp)

        if non_null_type
            fields[i] = Expr(:($fname))
        else
            fields[i] = Expr(:(=), fname, nothing)
        end
    end

    length(fnames) == 0 && return

    ifexpr = JLIfElse()
    for i = 1:length(fnames)
        # using symbols with :symbol syntax is tricky in exprs
        ifexpr[:(s === Symbol($("$(fnames[i])")))] =
            :(getfield(t, (Symbol($("$(fnames[i])"))))::$(ftyps[i]))
    end
    ifexpr.otherwise = :(getfield(t, s))

    ex = quote
        function Base.getproperty(t::$typename, sym::Symbol)
            $(codegen_ast(ifexpr))
        end
    end

    return ex
end
