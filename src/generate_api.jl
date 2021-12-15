using Pkg

function generate_api(
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
                str = String(read(fp))
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

function generate_api(
    saved_files_dir::String,
    schema_path::String;
    generate_types::Bool = true,
    generate_functions::Bool = true,
)
    generate_api(saved_files_dir, [schema_path]; generate_types, generate_functions)
end
