"""
    function generate(
        saved_files_dir::String,
        schema_paths::Vector{String};
        generate_types::Bool = true,
        generate_functions::Bool = true,
    )

Generate Julia code files for GraphQL types and functions.

"graphqlgen_types.jl": contains all the GraphQL types

"graphqlgen_functions.jl": contains all the GraphQL functions (mutations, queries, subscriptions)

* `saved_files_dir`: directory where the generated files will be saved
* `schema_paths`: list of paths to GraphQL schema files. This can be a file or a directory. If it's a directory, it will be recursively searched for GraphQL schema files.
* `generate_types`: whether to generate "types.jl"
* `generate_functions`: whether to generate "functons.jl"
"""
function generate(
    saved_files_dir::String,
    schema_paths::Vector{String};
    generate_types::Bool = true,
    generate_functions::Bool = true,
)
    schema = ""
    for p in schema_paths
        if isfile(p)
            _, ext = splitext(p)
            if ext in (".graphql", ".schema")
                @info "reading in schema file" file = p
                str = String(read(p))
                schema *= str
                schema *= "\n"
            end
        else
            for (root, dirs, files) in walkdir(p)
                for f in files
                    fp = joinpath(root, f)
                    ".git" in split(fp, Base.Filesystem.path_separator) && continue
                    _, ext = splitext(fp)
                    if ext in (".graphql", ".schema")
                        @info "reading in schema file" file = f
                        str = String(read(fp))
                        schema *= str
                        schema *= "\n"
                    end
                end
            end
        end
    end

    generate_from_schema(saved_files_dir, schema; generate_types, generate_functions)

    return nothing
end

function generate(
    saved_files_dir::String,
    schema_path::String;
    generate_types::Bool = true,
    generate_functions::Bool = true,
)
    generate(saved_files_dir, [schema_path]; generate_types, generate_functions)
end

"""
    function generate_from_schema(
        saved_files_dir::String,
        schema::String;
        generate_types::Bool = true,
        generate_functions::Bool = true,
    )

Generate Julia code files for GraphQL types and functions.

"graphqlgen_types.jl": contains all the GraphQL types

"graphqlgen_functions.jl": contains all the GraphQL functions (mutations, queries, subscriptions)

* `saved_files_dir`: directory where the generated files will be saved
* `schema`: GraphQL schema as a string
* `generate_types`: whether to generate "types.jl"
* `generate_functions`: whether to generate "functons.jl"
"""
function generate_from_schema(
    saved_files_dir::String,
    schema::String;
    generate_types::Bool = true,
    generate_functions::Bool = true,
)
    # generate types and functions
    types, functions = GraphQLGen.tojl(GraphQLGen.parse(schema))

    dir = abspath(saved_files_dir)
    try
        mkdir(dir)
    catch e
        if e isa Base.IOError && e.code == -17
            # ignore
        else
            rethrow()
        end
    end

    if generate_types
        filename = joinpath(dir, "graphqlgen_types.jl")
        open("$filename", "w") do f
            GraphQLGen.print(f, types)
        end
        @info "Generated Julia GraphQL types" path = filename
    end

    if generate_functions
        filename = joinpath(dir, "graphqlgen_functions.jl")
        open("$filename", "w") do f
            GraphQLGen.print(f, functions)
        end
        @info "Generated Julia GraphQL functions" path = filename
    end

    return nothing
end
