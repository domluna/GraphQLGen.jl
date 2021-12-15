# GraphQLGen.jl

Generates Julia types and functions from GraphQL schema. See the [example](./example) for usage.

## Quick Start

```julia
# Generate julia files in the GraphQLAPI directory based off all the files found in
# the schemas directory.
# 
# NOTE: You should do one call for all schema files rather than N seperate calls.
julia> GraphQLGen.generate("GraphQLAPI", "schemas/")
```

Now you'll have two files:

- `graphqlgen_types.jl`: contains all the GraphQL types
- `graphqlgen_functions.jl`: contains all the GraphQL functions (mutations, queries, subscriptions)

You can import and use these types and functions however you wish but note **the `StructTypes` dependency is REQUIRED since various functions were generated so the types are automatically compatible with `StructTypes`.**

## Codegen Peculiarities

Types may be ordered differently in the Julia file than the schema file. This is because
the Julia types must be ordered by usage. For example, if struct A uses struct B in a field
then B must appear before A in Julia code. This is also why all schema files should be parsed
at together. If there are types which reference eachother across files and code is generated
for each file separately, then the codegen can't ensure they will be ordered correctly.

If there is a cycle then the types of the affected fields will be dropped altogether to ensure
they are not referenced out of turn.
