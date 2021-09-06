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
        if d isa ObjectTypeDefinition && jltype(d.name) in schema_types
            jlfuncs = jlfunction(d)
            for f in jlfuncs
                push!(functions, f)
            end
        else
            jlt = if d isa ScalarTypeDefinition
                jltype(d, scalar_type_map)
            elseif d isa ObjectTypeDefinition
                jltype(d, revisited_graph)
            elseif d isa InputObjectTypeDefinition
                jltype(d, revisited_graph)
            else
                jltype(d)
            end
            if !isnothing(jlt)
                push!(types, jlt)
            end
        end
    end

    return types, functions
end
tojl(doc::Document) = tojl(doc, Dict())

jltype(x) = nothing

function jltype(name::Symbol, fields::Vector{Expr}, graph::Dict{Symbol,Set{Symbol}})
    sort!(fields, lt = (e1, e2) -> e1.head === :(::) && e2.head === :(=))

    ex = if haskey(graph, name)
        quote
            Base.@kwdef mutable struct $name
                $(fields...)
            end

            StructTypes.StructType(::Type{$name}) = StructTypes.Mutable()

            StructTypes.omitempties(::Type{$name}) = true

            $(codegen_ast(generate_custom_getproperty!(fields, name, graph[name])))
        end
    else
        quote
            Base.@kwdef mutable struct $name
                $(fields...)
            end

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

    lhs = Expr(Symbol("::"), name, typ)

    ex = if !t.type.non_null
        Expr(:(=), lhs, nothing)
    else
        lhs
    end

    return ex
end

function jltype(t::ArgumentsDefinition)
    return jltype.(t.input_value_definitions)
end

function jlfunction(t::FieldDefinition, stype::Symbol)
    name = jltype(t.name)
    typ = jltype(t.type)
    argdefs = if isnothing(t.arguments_definition)
        []
    else
        jltype(t.arguments_definition)
    end

    args = filter(e -> e.head === :(::), argdefs)
    kwargs = filter(e -> e.head === :(=), argdefs)
    kwargs2 = map(kwargs) do e
        e = copy(e)
        e.head = :kw
        e
    end

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
        e = a.args[1]
        :($("$e") => $e)
    end
    variable_kw = map(kwargs2) do kw
        e = kw.args[1].args[1]
        :($("$e") => $e)
    end

    quote
        struct $name
            ret::String
        end

        function (f::$name)($(args...); $(kwargs2...))::$typ
            q = s -> $("""
            $(lowercase(string(stype))) $(uppercasefirst(string(name)))($sig) {
            $(name)($input) {
            """) * s * """
            }
            }"""

            query = q(f.ret)
            variables = Dict($(variable_args...), $(variable_kw...))
            filter!(v -> !isnothing(v[2]), variables)

            return (; query, variables)
        end
    end
end

function jltype(t::InputValueDefinition)
    name = jltype(t.name)
    typ = jltype(t.type)

    lhs = Expr(Symbol("::"), name, typ)

    ex = if !isnothing(t.default_value)
        Expr(:(=), lhs, jltype(t.default_value))
    elseif !t.type.non_null
        Expr(:(=), lhs, nothing)
    else
        lhs
    end

    return ex
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
jltype(t::RBNF.Token{:single_quote_string_value}) = t.str
jltype(t::RBNF.Token{:triple_quote_string_value}) = t.str
function jltype(t::Some)
    jltype(something(t))
end

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
    generate_custom_getproperty!(fields::Vector{Expr}, typename::Symbol, cyclic_types::Set{Symbol})

Generates a custom `Base.getproperty` function for the type `typename`. This is done
in effort to preserve type inference of fields there the type has to be removed due to
definitioning types in a cyclic order.

    !!! The `fields` argument is mutated by removing type information for cyclic fields.
"""
function generate_custom_getproperty!(
    fields::Vector{Expr},
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
