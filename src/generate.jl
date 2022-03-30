"""
    function generate(
        saved_files_dir::String,
        schema_paths::Vector{String};
        generate_types::Bool = true,
        generate_functions::Bool = true,
        generated_header::String = "",
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
    generated_header::String = "",
)
    io = IOBuffer()
    for p in schema_paths
        if isfile(p)
            _, ext = splitext(p)
            if ext in (".graphql", ".schema")
                @info "reading in schema file" file = p
                str = String(read(p))
                write(io, str)
                write(io, '\n')
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
                        write(io, str)
                        write(io, '\n')
                    end
                end
            end
        end
    end

    schema = String(take!(io))

    generate_from_schema(saved_files_dir, schema; generate_types, generate_functions, generated_header)

    return nothing
end

function generate(
    saved_files_dir::String,
    schema_path::String;
    generate_types::Bool = true,
    generate_functions::Bool = true,
    generated_header::String = "",
)
    generate(saved_files_dir, [schema_path]; generate_types, generate_functions, generated_header)
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
    generated_header::String = "",
)
    # generate types and functions
    types, functions = GraphQLGen.tojl(GraphQLGen.parse(schema))

    types_filename = "graphqlgen_types.jl"
    functions_filename = "graphqlgen_functions.jl"

    dir = abspath(saved_files_dir)
    d = splitpath(dir)[end]

    !isdir(dir) && mkdir(dir)

    filename = "$dir/$d.jl"
    open(filename, "w") do f
        write(f, generated_header)
        Base.print(
            f,
            """
            module $d

            using StructTypes

            include("$types_filename")
            include("$functions_filename")

            end # module $d
            """,
        )
    end

    if generate_types
        filename = joinpath(dir, types_filename)
        open("$filename", "w") do f
            write(f, generated_header)
            GraphQLGen.print(f, types)
        end
        @info "Generated Julia GraphQL types" path = filename
    end

    if generate_functions
        filename = joinpath(dir, functions_filename)
        open("$filename", "w") do f
            write(f, generated_header)
            GraphQLGen.print(f, functions)
        end
        @info "Generated Julia GraphQL functions" path = filename
    end

    return nothing
end
