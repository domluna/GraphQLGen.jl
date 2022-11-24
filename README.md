# GraphQLGen.jl

Generates Julia types and functions from GraphQL schema. See the [example](./example) for usage.

## API

```julia
"""
    function generate(
        codegen_dir::String,
        schema_paths::Vector{String};
        generate_types::Bool = true,
        generate_functions::Bool = true,
        generated_header::String = "",
        to_skip::Set{Symbol} = Set{Symbol}(),
        scalar_type_map::Dict = Dict(),
    )

    function generate_from_schema(
        codegen_dir::String,
        schema::String;
        generate_types::Bool = true,
        generate_functions::Bool = true,
        generated_header::String = "",
        to_skip::Set{Symbol} = Set{Symbol}(),
        scalar_type_map::Dict = Dict(),
    )

Generate Julia code files for GraphQL types and functions.

- "graphqlgen_types.jl": contains all the GraphQL types
- "graphqlgen_functions.jl": contains all the GraphQL functions (mutations, queries, subscriptions)

* `codegen_dir`: directory where the generated files will be saved
* `schema_paths`: list of paths to GraphQL schema files. This can be a file or a directory. If it's a directory, it will be recursively searched for GraphQL schema files.

* `generate_types`: whether to generate "graphqlgen_types.jl"
* `generate_functions`: whether to generate "graphqlgen_functions.jl"
* `generated_header`: header prepended to generated files
* `to_skip`: types or functions to skip generating
* `scalar_type_map`: mapping of GraphQL scalar types to their corresponding Julia types
"""
```

> `generate_from_schema` has the same API as `generate` but the second argument is the schema itself rather than the file(s) of the schema.


## Quick Start

```julia
# Generate julia files in the GraphQLAPI directory based off all the files found in
# the schemas directory.
# 
# NOTE: You should do one call for all schema files rather than N seperate calls.
julia> GraphQLGen.generate("GraphQLAPI", "schemas/")

# This generates a module in the GraphQLAPI (intended to be used as a submodule of a project)
# The file structure will be

# | GraphQLAPI
# --- GraphQLAPI.jl
# --- graphqlgen_types.jl
# --- graphqlgen_functions.jl

# The contents of GraphQLAPI will be:

module GraphQLAPI

include("graphqlgen_types.jl")
include("graphqlgen_functions.jl")

end # module GraphQLAPI

```

> You do not need to use `GraphQLAPI.jl`, in-fact it may be preferable to just include the types and functions files themselves or create your own submodule.

Generated files:

- `graphqlgen_types.jl`: contains all the GraphQL types
- `graphqlgen_functions.jl`: contains all the GraphQL functions (mutations, queries, subscriptions). The intended use of these functions at the moment is to create easily create queries and variables such that they can be easily serialized for an HTTP request.

## Codegen Peculiarities

Types may be ordered differently in the Julia file than the schema file. This is because
the Julia types must be ordered by usage. For example, if struct A uses struct B in a field
then B must appear before A in Julia code. This is also why all schema files should be parsed
at together. If there are types which reference eachother across files and code is generated
for each file separately, then the codegen can't ensure they will be ordered correctly.

If there is a cycle then the types of the affected fields will be dropped altogether to ensure
they are not referenced out of turn.
