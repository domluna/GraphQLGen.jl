function generate_api(
    module_path::String,
    schema_paths::Vector{String};
    generate_types::Bool = true,
    generate_functions::Bool = true,
)
    schema = ""
    for p in schema_paths
        if isfile(p)
            _, ext = splitext(p)
            if ext in (".graphql", ".schema")
                @info "reading in schema file" f
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
                        @info "reading in schema file" f
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

    dir = abspath(module_path)
    try
        mkdir(dir)
    catch e
        if e isa Base.IOError && e.code == -17
            # ignore
        else
            rethrow()
        end
    end

    module_name = splitpath(dir)[end]
    # make sure there's no extension
    module_name, _ = splitext(module_name)
    filename = joinpath(dir, module_name * ".jl")

    contents = """
    module $module_name

    using StructTypes

    include("types.jl")
    include("functions.jl")

    end
    """
    open("$filename", "w") do f
        Base.write(f, contents)
    end

    if generate_types
        filename = joinpath(dir, "types.jl")
        open("$filename", "w") do f
            GraphQLGen.print(f, types)
        end
    end

    if generate_functions
        filename = joinpath(dir, "functions.jl")
        open("$filename", "w") do f
            GraphQLGen.print(f, functions)
        end
    end

    @info "GraphQL API successfully generated ..." dir
    return nothing
end

function generate_api(
    module_path::String,
    schema_path::String;
    generate_types::Bool = true,
    generate_functions::Bool = true,
)
    generate_api(module_path, [schema_path]; generate_types, generate_functions)
end
