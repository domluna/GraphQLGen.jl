struct GQL end

Base.convert(::Type{String}, t::RBNF.Token) = t.str
Base.convert(::Type{Symbol}, t::RBNF.Token{:name}) = Symbol(t.str)
Base.convert(::Type{Symbol}, t::RBNF.Token{:reserved}) = Symbol(t.str)
Base.convert(::Type{Int}, t::RBNF.Token{:int_value}) = Base.parse(Int, t.str)
Base.convert(::Type{Float64}, t::RBNF.Token{:float_value}) = Base.parse(Float64, t.str)
function Base.convert(::Type{String}, t::RBNF.Token{:str})
    startswith(t.str, "\"\"\"") ? String(t.str[4:end-3]) : String(t.str[2:end-1])
end
function Base.convert(::Type{String}, t::RBNF.Token{:single_quote_string_value})
    string(t.str[2:end-1])
end
function Base.convert(::Type{String}, t::RBNF.Token{:triple_quote_string_value})
    string(t.str[4:end-3])
end

RBNF.@parser GQL begin
    ignore{whitespace,comment,comma}

    @grammar
    atom = (name | float_value | int_value | string_value | punctuator)

    document::Document := [definitions = definition{*}]
    definition = (executable_definition | type_system_definition | type_system_extension)

    executable_definition = (operation_definition | fragment_definition)

    operation_definition = (
        selection_set |
        [operation_type, name.?, variable_definitions.?, directives.?, selection_set]
    )

    operation_type = ("query" | "mutation" | "subscription")

    selection_set::SelectionSet := ['{', selections = selection{*}, '}']

    selection = (field | fragment_spread | inline_fragment)

    field::Field := [
        alias = alias.?,
        name = name,
        arguments = arguments.?,
        directives = directives.?,
        selection_set = selection_set.?,
    ]

    alias::Alias := [name = name, ':']

    arguments::Arguments := ['(', arguments = argument{*}, ')']
    argument::Argument := [name = name, ':', value = value]

    fragment_spread::FragmentSpread :=
        ["...", fragment_name = fragment_name, directives = directives.?]
    inline_fragment::InlineFragment := [
        "...",
        type_condition = type_condition.?,
        directives = directives.?,
        selection_set = selection_set,
    ]
    fragment_definition::FragmentDefinition := [
        "fragment",
        fragment_name = fragment_name,
        type_condition = type_condition,
        directives = directives.?,
        selection_set = selection_set,
    ]

    # but not on
    fragment_name = name
    type_condition::TypeCondition := ["on", named_type = named_type]

    value = (
        variable |
        int_value |
        float_value |
        string_value |
        bool_value |
        null_value |
        enum_value |
        list_value |
        object_value
    )

    bool_value = ("true" | "false")
    null_value = "null"

    # but not true, false, or null
    enum_value = name

    list_value::ListValue := ['[', values = value{*}.?, ']']
    object_value::ObjectValue := ['{', object_fields = object_field{*}.?, '}']

    object_field::ObjectField := [name = name, ':', value = value]

    variable_definitions::VariableDefinitions :=
        ['(', variable_definitions = variable_definition{*}, ')']
    variable_definition::VariableDefinition :=
        [name = variable, ':', type = typ, value = default_value.?]
    variable::Variable := ['$', name = name]
    default_value::DefaultValue := ['=', value = value]

    typ = (list_type | named_type)
    named_type::NamedType := [type = name, non_null = '!'.?]
    list_type::ListType := ['[', type = typ, ']', non_null = '!'.?]

    directives::Directives := [directives = directive{*}]
    directive::Directive := ['@', name = name, arguments = arguments.?]

    type_system_definition = (schema_definition | type_definition | directive_definition)

    type_system_extension = (schema_extension | type_extension)

    schema_definition::SchemaDefinition := [
        "schema",
        directives = directives.?,
        '{',
        operation_type_definitions = operation_type_definition{*},
        '}',
    ]
    schema_extension = (
        ["extend", "schema", directives.?, '{', operation_type_definition{*}, '}'] |
        ["extend", "schema", directives]
    )

    operation_type_definition::OperationTypeDefinition :=
        [operation_type = operation_type, ':', named_type = named_type]

    type_definition::TypeDefinition := [
        description = string_value.?,
        type = (
            scalar_type_definition |
            object_type_definition |
            interface_type_definition |
            union_type_definition |
            enum_type_definition |
            input_object_type_definition
        )
    ]

    # TODO: extensions might not work
    type_extension = (
        scalar_type_extension |
        object_type_extension |
        interface_type_extension |
        union_type_extension |
        enum_type_extension |
        input_object_type_extension
    )

    scalar_type_definition::ScalarTypeDefinition :=
        ["scalar", name = name, directives = directives.?]
    scalar_type_extension::ScalarTypeExtension :=
        ["extend", "scalar", name = name, directives = directives]

    object_type_definition::ObjectTypeDefinition := [
        "type",
        name = name,
        implements_interfaces = implements_interfaces.?,
        directives = directives.?,
        fields_definition = fields_definition.?,
    ]
    object_type_extension = (
        ["extend", "type", name, implements_interfaces.?, directives.?, fields_definition] |
        ["extend", "type", name, implements_interfaces.?, directives] |
        ["extend", "type", name, implements_interfaces]
    )

    # TODO: recursion
    implements_interfaces = ["implements", '&'.?, type = named_type]

    # implements_interfaces = (
    #                          ["implements", '&'.?, named_type] |
    #                          [implements_interfaces, '&', named_type]
    #                         )

    fields_definition::FieldsDefinition :=
        ['{', field_definitions = field_definition{*}, '}']

    field_definition::FieldDefinition := [
        description = string_value.?,
        name = name,
        arguments_definition = arguments_definition.?,
        ':',
        type = typ,
        directives = directives.?,
    ]

    arguments_definition::ArgumentsDefinition :=
        ['(', input_value_definitions = input_value_definition{*}, ')']

    input_value_definition::InputValueDefinition := [
        description = string_value.?,
        name = name,
        ':',
        type = typ,
        default_value = default_value.?,
        directives = directives.?,
    ]

    interface_type_definition::InterfaceTypeDefinition := [
        "interface",
        name = name,
        directives = directives.?,
        fields_definition = fields_definition.?,
    ]

    interface_type_extension = (
        ["extend", "interface", name, directives.?, fields_definition] |
        ["extend", "interface", name, directives]
    )

    union_type_definition::UnionTypeDefinition := [
        "union",
        name = name,
        directives = directives.?,
        types = union_member_types.?,
    ]

    union_member_types = @direct_recur begin
        init = [['=', '|'.?, named_type] % (x -> x[3])]
        prefix = [recur..., ('|', named_type) % (x -> x[2])]
    end

    union_type_extension = (
        ["extend", "union", name, directives.?, union_member_types] |
        ["extend", "union", name, directives]
    )

    enum_type_definition::EnumTypeDefinition := [
        "enum",
        name = name,
        directives = directives.?,
        enums = enum_values_definition.?,
    ]

    enum_values_definition::EnumValuesDefinition :=
        ['{', values = enum_value_definition{*}, '}']
    enum_value_definition::EnumValueDefinition :=
        [description = string_value.?, value = enum_value, directives = directives.?]
    enum_type_extension = (
        ["extend", "enum", name, directives.?, enum_values_definition] |
        ["extend", "enum", name, directives]
    )

    input_object_type_definition::InputObjectTypeDefinition := [
        "input",
        name = name,
        directives = directives.?,
        fields = input_fields_definition.?,
    ]

    input_fields_definition::InputFieldsDefinition :=
        ['{', input_value_definitions = input_value_definition{*}, '}']

    input_object_type_extension = (
        ["extend", "input", name, directives.?, input_fields_definition] |
        ["extend", "input", name, directives]
    )

    directive_definition::DirectiveDefinition := [
        description = string_value.?,
        "directive",
        '@',
        name = name,
        arguments_definition = arguments_definition.?,
        "on",
        directive_locations = directive_locations,
    ]

    # TODO: recursion
    directive_locations =
        (['|'.?, directive_location] | [directive_locations, '|', directive_location])

    directive_location = (executable_directive_location | type_system_directive_location)

    executable_directive_location = (
        "QUERY" |
        "MUTATION" |
        "SUBSCRIPTION" |
        "FIELD" |
        "FRAGMENT_DEFINITION" |
        "FRAGMENT_SPREAD" |
        "INLINE_FRAGMENT"
    )
    type_system_directive_location = (
        "SCHEMA" |
        "SCALAR" |
        "OBJECT" |
        "FIELD_DESCRIPTION" |
        "ARGUMENT_DEFINITION" |
        "INTERFACE" |
        "UNION" |
        "ENUM" |
        "ENUM_VALUE" |
        "INPUT_OBJECT" |
        "INPUT_FIELD_DEFINITION"
    )

    string_value = triple_quote_string_value | single_quote_string_value

    @token
    comment := r"\G#.*(\r|\n)?"
    whitespace := r"\G\s+"
    comma := r"\G,"

    name := r"\G[A-Za-z][_0-9A-Za-z]*"
    float_value := r"\G([0-9]+\.[0-9]*|[0-9]*\.[0.9]+)([eE][-+]?[0-9]+)?"
    int_value := r"\G([1-9]+[0-9]*|0)"
    triple_quote_string_value := @quote ("\"\"\"", "\\\"\"\"", "\"\"\"")
    single_quote_string_value := @quote ("\"", "\\\"", "\"")

    punctuator := r"\G(!|\$|\(|\)|\.\.\.|:|=|@|\[|\]|{|}|\|)"
end
