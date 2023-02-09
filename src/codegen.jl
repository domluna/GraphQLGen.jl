const DEFAULT_TYPE_MAP = Dict{Symbol,Symbol}(
    :Float => :Float64, # graphql Float is Float64
    :Int => :Int, # graphql Int is Int
    :Boolean => :Bool,
    :ID => :String, # serialized as a String but not intended to be human-readable
)

const BUILTIN_GRAPHQL_TYPES = Set{Symbol}([:ID, :Int, :String, :Float, :Boolean])

function get_schema_types(doc::Document)
    schema_types = Dict{Symbol,Symbol}()
    for d in doc
        if d isa SchemaDefinition
            merge!(schema_types, get_schema_types(d))
        end
    end
    return schema_types
end

struct Config
    root_abstract_type::Union{Nothing,Symbol}
    scalar_type_map::Dict
    to_skip::Set{Symbol}
    schema_types::Dict{Symbol,Symbol}
    graph::Dict{Symbol,Set{Symbol}}
    enums::Set{Symbol}
end

function get_schema_types(sd::SchemaDefinition)
    schema_types = Dict{Symbol,Symbol}()
    for o in sd.operation_type_definitions
        if o.operation_type === "query" ||
           o.operation_type === "mutation" ||
           o.operation_type === "subscription"
            schema_types[jltype(o.named_type.type)] = Symbol(o.operation_type)
        end
    end
    return schema_types
end

getname(t::TypeDefinition) = jltype(t.type.name)
getname(t) = jltype(t.name)

function tojl(
    doc::Document;
    scalar_type_map::Dict = Dict(),
    to_skip::Set{Symbol} = Set{Symbol}(),
    root_abstract_type::Union{Nothing,Symbol} = nothing,
)
    schema_types = get_schema_types(doc)
    doc, graph = dagify(doc)
    types = Expr[]
    functions = Expr[]

    config = Config(root_abstract_type, scalar_type_map, to_skip, schema_types, graph, Set{Symbol}())

    for d in doc
        getname(d) in config.to_skip && continue

        if d isa TypeDefinition &&
           d.type isa ObjectTypeDefinition &&
           haskey(config.schema_types, jltype(d.type.name))
            jlfuncs = jlfunction(d, config)
            for f in jlfuncs
                push!(functions, f)
            end
        else
            if d.type isa EnumTypeDefinition
                push!(config.enums, jltype(d.type.name))
            end
            jlt = jltype(d, config)
            if !isnothing(jlt)
                push!(types, jlt)
            end
        end
    end

function is_enum(expr::Expr)
        expr.head == :macrocall && expr.args[1] == Symbol("@enumx") && return true
        expr.head == :macrocall && expr.args[1] == :(Core.var"@doc") && return is_enum(expr.args[end])
        return false
end
is_enum(s::Symbol) = false    

 sub = Substitute() do expr
            if expr isa Symbol && expr in config.enums
        return true
        end
           return false
       end;

    for i in 1:length(types)
        types[i] = ExprPrettify.prettify(types[i])
        if is_enum(types[i])
            continue
        end
        types[i] = sub(x -> :($x.T), types[i])
    end

    for i in 1:length(functions)
        functions[i] = ExprPrettify.prettify(functions[i])
    end

    return types, functions
end

jltype(x) = nothing

function jltype(t::TypeDefinition, config::Config)
    typ = t.type
    ex = if typ isa ScalarTypeDefinition
        jltype(typ, config)
    elseif typ isa ObjectTypeDefinition
        jltype(typ, config)
    elseif typ isa InputObjectTypeDefinition
        jltype(typ, config)
    else
        jltype(typ)
    end

    docstr = isnothing(something(t.description)) ? "" : jltype(t.description)
    docstr == "" && return ex
    docstr = strip(docstr)

    ex =
        if typ isa ScalarTypeDefinition ||
           typ isa UnionTypeDefinition ||
           typ isa EnumTypeDefinition
            :(Core.@doc $docstr $ex)
        else
            quote
                $("\"\"\"\n$docstr\n\"\"\"")
                $(ex.args...)
            end
        end

    return ex
end

function jltype(name::Symbol, fields::Vector{JLKwField}, config::Config)
    ex = if haskey(config.graph, name)
        get_property_expr = generate_getset!(fields, name, config.graph[name])
        st = JLKwStruct(;
            ismutable = true,
            name = name,
            fields = fields,
            supertype = config.root_abstract_type,
        )
        quote
            $(codegen_ast(st))

            $(codegen_ast(get_property_expr))
        end
    else
        st = JLKwStruct(;
            ismutable = true,
            name = name,
            fields = fields,
            supertype = config.root_abstract_type,
        )
        quote
            $(codegen_ast(st))
        end
    end

    return ex
end

function jltype(t::ObjectTypeDefinition, config::Config)
    name = jltype(t.name)
    fields = map(t.fields_definition) do fd
        jltype(fd)
    end

    return jltype(name, fields, config)
end

jlfunction(t::TypeDefinition, config::Config) = jlfunction(t.type, config)

function jlfunction(t::ObjectTypeDefinition, config::Config)
    name = jltype(t.name)
    functions = Expr[]
    for fd in t.fields_definition
        jltype(fd.name) in config.to_skip && continue
        push!(functions, jlfunction(fd, config.schema_types[name]))
    end

    return functions
end

function jltype(t::InputObjectTypeDefinition, config::Config)
    name = jltype(t.name)
    fields = map(t.fields) do f
        jltype(f)
    end

    return jltype(name, fields, config)
end

function jltype(t::FieldDefinition)
    name = jltype(t.name)
    typ = jltype(t.type)

    if name in RESERVED_JL_KEYWORDS
        name = Symbol(name, "_")
    end

    kw = if !t.type.non_null
        JLKwField(; name = name, type = typ, default = :nothing)
    else
        JLKwField(; name = name, type = typ)
    end

    if !isnothing(something(t.description))
        kw.doc = jltype(t.description)
    end

    return kw
end

function jltype(t::ArgumentsDefinition)
    map(t.input_value_definitions) do inp
        jltype(inp)
    end
end

function jlfunctionarg(t::ArgumentsDefinition)
    map(t.input_value_definitions) do inp
        jlfunctionarg(inp)
    end
end

function jlfunction(t::FieldDefinition, stype::Symbol)
    name = jltype(t.name)
    typ = jltype(t.type)
    argdefs = if isnothing(t.arguments_definition)
        Expr[]
    else
        jlfunctionarg(t.arguments_definition)::Vector{Expr}
    end

    args = filter(e -> e.head != :kw, argdefs)
    kwargs = filter(e -> e.head == :kw, argdefs)

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
        v = "\$$(s.name): $(s.typ)"
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
    variable_kw = map(kwargs) do kw
        e = kw.args[1].args[1]
        :($("$e") => $e)
    end

    body = quote
        q = inp -> begin
                s = $("""
                $(lowercase(string(stype))) $(uppercasefirst(string(name)))($sig) {
                    $(name)($input) {
                """)
                s *= inp
                s *= """
                    }
                }
                """
            end

        query = q(f.query)
        variables = Dict{String,Any}($(variable_args...), $(variable_kw...))
        filter!(v -> !isnothing(v[2]), variables)

        return (; query, variables)
    end

    doc::Union{Nothing,String} = if isnothing(something(t.description))
        nothing
    else
        strip(jltype(t.description))
    end
    jlf = JLFunction(; name = :(f::$name), args, kwargs, body)

    ex = if isnothing(doc)
        quote
            struct $name
                query::String
            end

            $(codegen_ast(jlf))
        end
    else
        quote
            struct $name
                query::String
            end

            $("\"\"\"\n$doc\n\"\"\"")
            $(codegen_ast(jlf))
        end
    end

    return ex
end

function jltype(t::InputValueDefinition)
    name = jltype(t.name)
    typ = jltype(t.type)

    if name in RESERVED_JL_KEYWORDS
        name = Symbol(name, "_")
    end

    kw = if !t.type.non_null
        JLKwField(; name = name, type = typ, default = jltype(t.default_value))
    else
        JLKwField(; name = name, type = typ)
    end

    if !isnothing(something(t.description))
        kw.doc = jltype(t.description)
    end

    return kw
end

function jlfunctionarg(t::InputValueDefinition)
    name = jltype(t.name)
    typ = jltype(t.type)

    if !t.type.non_null
        Expr(:kw, Expr(:(::), name, typ), jltype(t.default_value))
    else
        Expr(:(::), name, typ)
    end
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
        @enumx $name begin
            $(enums...)
        end
    end
    return ex
end

function jltype(t::EnumValueDefinition)
    ex = jltype(t.value)
    # docstrings for enum values are not supported
    # so these will be ignored
    # if !isnothing(something(t.description))
    #     doc = jltype(t.description)
    #     ex = :(Core.@doc $doc $ex)
    # end
    return ex
end

function jltype(t::ScalarTypeDefinition, config::Config)
    name = jltype(t.name)
    typ = get(config.scalar_type_map, name, Any)
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
jltype(t::RBNF.Token{:bool_value}) = Base.parse(Bool, t.str)
jltype(t::RBNF.Token{:null_value}) = missing
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
    generate_getset!(fields::Vector{JLKwField}, typename::Symbol, cyclic_types::Set{Symbol})

Generates a custom `Base.getproperty` and `Base.setproperty!` function for the type `typename`. This is done
in effort to preserve type inference of fields there the type has to be removed due to defining types in a cyclic order.

    !!! The `fields` argument is mutated by removing type information for cyclic fields.
"""
function generate_getset!(
    fields::Vector{JLKwField},
    typename::Symbol,
    cyclic_types::Set{Symbol},
)
    fnames = Symbol[]
    ftypes = Union{Expr,Symbol}[]

    for (i, f) in enumerate(fields)
        fname = f.name
        ftype = f.type
        fdefault = f.default

        ft = get_leaf_type(ftype)
        ft in cyclic_types || continue

        push!(fnames, fname)
        push!(ftypes, ftype)

        fields[i] = JLKwField(; name = fname, default = fdefault)
    end

    length(fnames) == 0 && return

    get_ifexpr = JLIfElse()
    for i in 1:length(fnames)
        # using symbols with :symbol syntax is tricky in exprs
        get_ifexpr[:(sym === Symbol($("$(fnames[i])")))] =
            :(getfield(t, (Symbol($("$(fnames[i])"))))::$(ftypes[i]))
    end
    get_ifexpr.otherwise = :(getfield(t, sym))

    set_ifexpr = JLIfElse()
    for i in 1:length(fnames)
        # using symbols with :symbol syntax is tricky in exprs
        set_ifexpr[:(sym === Symbol($("$(fnames[i])")))] =
            :(setfield!(t, (Symbol($("$(fnames[i])"))), val::$(ftypes[i])))
    end
    set_ifexpr.otherwise = :(setfield!(t, sym, val))

    ex = quote
        function Base.getproperty(t::$typename, sym::Symbol)
            $(codegen_ast(get_ifexpr))
        end

        function Base.setproperty!(t::$typename, sym::Symbol, val::Any)
            $(codegen_ast(set_ifexpr))
        end
    end

    return ex
end

function get_leaf_type(ex::Union{Expr,Symbol})
    ex isa Symbol && return ex

    t = if ex.args[1] == :Vector
        get_leaf_type(ex.args[2])
    else
        idx = findfirst(ft -> !in(ft, (:Union, :Missing, :Nothing)), ex.args)
        get_leaf_type(ex.args[idx])
    end

    return t
end
