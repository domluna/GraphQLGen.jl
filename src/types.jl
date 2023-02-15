abstract type GraphQLNode end

struct ListType <: GraphQLNode
    type::Any
    # true for trailing !, false otherwise
    non_null::Bool

    function ListType(type, non_null::Some{Nothing})
        new(type, false)
    end

    function ListType(type, non_null::Some{T}) where {T}
        new(type, true)
    end

    function ListType(type, non_null::Bool)
        new(type, non_null)
    end
end

struct NamedType <: GraphQLNode
    type::Any
    # true for !, false otherwise
    non_null::Bool

    function NamedType(type, non_null::Some{Nothing})
        new(type, false)
    end

    function NamedType(type, non_null::Some{T}) where {T}
        new(type, true)
    end

    function NamedType(type, non_null::Bool)
        new(type, non_null)
    end
end

struct Document <: GraphQLNode
    definitions::Vector{Any}
end
Base.getindex(d::Document, ind...) = d.definitions[ind...]
Base.length(d::Document) = length(d.definitions)
Base.firstindex(d::Document) = 1
Base.lastindex(d::Document) = length(d.definitions)
Base.iterate(d::Document, state = 1) = state > length(d) ? nothing : (d[state], state + 1)

struct SelectionSet <: GraphQLNode
    selections::Vector{Any}
end

struct TypeDefinition <: GraphQLNode
    description::Any
    type::Any
end

struct Argument <: GraphQLNode
    name::Any
    value::Any
end

struct Arguments <: GraphQLNode
    arguments::Vector{Argument}
end

struct Directive <: GraphQLNode
    name::Any
    arguments::Vector{Argument}
end

struct Directives
    directives::Vector{Directive}
end

struct Alias <: GraphQLNode
    name::Any
end

struct Field <: GraphQLNode
    alias::Union{Alias,Nothing}
    name::Any
    arguments::Vector{Argument}
    directives::Vector{Directive}
    selection_set::Vector{Any}
end

struct TypeCondition <: GraphQLNode
    named_type::NamedType
end

struct ListValue <: GraphQLNode
    values::Vector{Any}

    function ListValue(values)
        new(_force_any(values))
    end
end

struct ObjectField <: GraphQLNode
    name::Any
    value::Any
end

struct ObjectValue <: GraphQLNode
    object_fields::Vector{ObjectField}
end

struct Variable <: GraphQLNode
    name::Any
end

struct DefaultValue <: GraphQLNode
    value::Any
end

struct VariableDefinition <: GraphQLNode
    var::Variable
    type::Any
    value::DefaultValue
end

struct VariableDefinitions <: GraphQLNode
    variable_definitions::Vector{VariableDefinition}
end

struct OperationTypeDefinition <: GraphQLNode
    operation_type::String
    named_type::NamedType
end

struct SchemaDefinition <: GraphQLNode
    directives::Vector{Directive}
    operation_type_definitions::Vector{OperationTypeDefinition}
end

struct ScalarTypeDefinition <: GraphQLNode
    name::Any
    directives::Vector{Directive}
end

struct ScalarTypeExtension <: GraphQLNode
    name::Any
    directives::Vector{Directive}
end

struct InputValueDefinition <: GraphQLNode
    description::Any
    name::Any
    type::Any
    default_value::Union{DefaultValue,Nothing}
    directives::Vector{Directive}
end

struct ArgumentsDefinition <: GraphQLNode
    input_value_definitions::Vector{InputValueDefinition}
end

struct FieldDefinition <: GraphQLNode
    description::Any
    name::Any
    arguments_definition::Union{ArgumentsDefinition,Nothing}
    type::Any
    directives::Vector{Directive}
end

struct FieldsDefinition <: GraphQLNode
    field_definitions::Vector{FieldDefinition}
end

struct EnumValueDefinition <: GraphQLNode
    description::Any
    value::Any
    directives::Vector{Directive}
end

struct EnumValuesDefinition <: GraphQLNode
    values::Vector{EnumValueDefinition}
end

struct EnumTypeDefinition <: GraphQLNode
    name::Any
    directives::Vector{Directive}
    enums::Vector{EnumValueDefinition}
end

struct InputFieldsDefinition <: GraphQLNode
    input_value_definitions::Vector{InputValueDefinition}
end

struct InputObjectTypeDefinition <: GraphQLNode
    name::Any
    directives::Vector{Directive}
    fields::Vector{InputValueDefinition}
end

struct DirectiveDefinition <: GraphQLNode
    description::Any
    name::Any
    arguments_definition::Union{ArgumentsDefinition,Nothing}
    directive_locations::Any
end

struct UnionTypeDefinition <: GraphQLNode
    name::Any
    directives::Vector{Directive}
    types::Vector{NamedType}
end

struct InterfaceTypeDefinition <: GraphQLNode
    name::Any
    directives::Vector{Directive}
    fields_definition::Vector{FieldDefinition}
end

struct ObjectTypeDefinition <: GraphQLNode
    name::Any
    implements_interfaces::Any
    directives::Vector{Directive}
    fields_definition::Vector{FieldDefinition}
end

struct FragmentSpread <: GraphQLNode
    fragment_name::Any
    directives::Vector{Directive}
end

struct InlineFragment <: GraphQLNode
    type_condition::TypeCondition
    directives::Vector{Directive}
    selection_set::Vector{Any}
end

struct FragmentDefinition <: GraphQLNode
    fragment_name::Any
    type_condition::TypeCondition
    directives::Vector{Directive}
    selection_set::Vector{Any}
end

# Copied from OpenQASM.jl
#
# NOTE:
# In order to preserve some line number
# we usually don't annote types to AST

# work around JuliaLang/julia/issues/38091
function _force_any(x)
    if isnothing(x)
        return Any[]
    else
        return Vector{Any}(x)
    end
end

function _force_any(x::Some{Vector{T}}) where {T}
    return Vector{Any}(something(x))
end

function Base.convert(
    ::Type{Vector{Directive}},
    x::Some{T},
) where {T<:Union{Directives,Nothing}}
    s = something(x)
    if isnothing(s)
        return Directive[]
    else
        Vector{Directive}(s.directives)
    end
end

function Base.convert(
    ::Type{Vector{Argument}},
    x::Some{T},
) where {T<:Union{Arguments,Nothing}}
    s = something(x)
    if isnothing(s)
        return Argument[]
    else
        Vector{Argument}(s.arguments)
    end
end

function Base.convert(
    ::Type{Vector{Any}},
    x::Some{T},
) where {T<:Union{SelectionSet,Nothing}}
    s = something(x)
    if isnothing(s)
        return Any[]
    else
        Vector{Any}(s.selections)
    end
end

function Base.convert(
    ::Type{Vector{FieldDefinition}},
    x::Some{T},
) where {T<:Union{FieldsDefinition,Nothing}}
    s = something(x)
    if isnothing(s)
        return FieldDefinition[]
    else
        Vector{FieldDefinition}(s.field_definitions)
    end
end

function Base.convert(
    ::Type{Vector{InputValueDefinition}},
    x::Some{T},
) where {T<:Union{ArgumentsDefinition,InputFieldsDefinition,Nothing}}
    s = something(x)
    if isnothing(s)
        return InputValueDefinition[]
    else
        Vector{InputValueDefinition}(s.input_value_definitions)
    end
end

function Base.convert(
    ::Type{Vector{EnumValueDefinition}},
    x::Some{T},
) where {T<:Union{EnumValuesDefinition,Nothing}}
    s = something(x)
    if isnothing(s)
        return EnumValueDefinition[]
    else
        Vector{EnumValueDefinition}(s.values)
    end
end

function Base.convert(
    ::Type{Vector{NamedType}},
    x::Some{T},
) where {T<:Union{Vector{NamedType},Nothing}}
    s = something(x)
    return isnothing(s) ? NamedType[] : s
end

function Base.convert(
    ::Type{Vector{ObjectField}},
    x::Some{T},
) where {T<:Union{Vector{Any},Nothing}}
    s = something(x)
    return isnothing(s) ? ObjectField[] : Vector{ObjectField}(s)
end

function Base.convert(::Type{Union{T,Nothing}}, x::Some{Nothing}) where {T<:GraphQLNode}
    nothing
end

function Base.convert(::Type{Union{T,Nothing}}, x::Some{T}) where {T<:GraphQLNode}
    something(x)
end

Base.convert(::Type{String}, ::Some{Nothing}) = ""

# julia> GraphQLGen.parse(s0)
# ERROR: MethodError: Cannot `convert` an object of type Some{Vector{Any}} to an object of type Vector{GraphQLGen.ObjectField}
