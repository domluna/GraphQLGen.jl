using GraphQLGen
using Test
using Expronicon
using Pkg

@testset "GraphQLGen" begin
    @testset "get_leaf_type" begin
        ex = :(Union{Vector{Union{Person,Missing,Nothing}},Missing,Nothing})
        @test GraphQLGen.get_leaf_type(ex) == :Person

        ex = :(Union{Vector{Union{Person}},Missing,Nothing})
        @test GraphQLGen.get_leaf_type(ex) == :Person

        ex = :(Vector{Union{Person,Missing,Nothing}})
        @test GraphQLGen.get_leaf_type(ex) == :Person

        ex = :(Union{Person,Missing,Nothing})
        @test GraphQLGen.get_leaf_type(ex) == :Person

        ex = :Person
        @test GraphQLGen.get_leaf_type(ex) == :Person
    end

    @testset "scalar" begin
        str = """
        scalar A
        scalar B
        scalar C
        """
        scalar_type_map = Dict(:A => :Point, :B => Vector{UInt8})
        types, _ = GraphQLGen.tojl(GraphQLGen.parse(str); scalar_type_map)
        exprs = map(GraphQLGen.ExprPrettify.prettify, types)
        @test exprs[1] == :(const A = Point)
        @test exprs[2].args[1].head == :(=)
        @test exprs[2].args[1].args[1] == :(B)
        @test exprs[2].args[1].args[2] == Vector{UInt8}
        @test exprs[3].args[1].head == :(=)
        @test exprs[3].args[1].args[1] == :(C)
        @test exprs[3].args[1].args[2] == Any
    end

    @testset "enum" begin
        str = """
        enum Episode {
          NEWHOPE
          EMPIRE
          JEDI
        }
        """
        types, _ = GraphQLGen.tojl(GraphQLGen.parse(str))
        exprs = map(GraphQLGen.ExprPrettify.prettify, types)

        ret = :(@enum Episode begin
            NEWHOPE
            EMPIRE
            JEDI
        end)

        @test exprs[1] == GraphQLGen.ExprPrettify.prettify(ret)
    end

    @testset "union" begin
        str = """
        union U = U1 | U2
        """
        types, _ = GraphQLGen.tojl(GraphQLGen.parse(str))
        exprs = map(GraphQLGen.ExprPrettify.prettify, types)
        @test exprs[1] == :(const U = Union{U1,U2})
    end

    @testset "type fields" begin
        for t in [:type, :input]
            str = """
            $t A {
              field1: Int
              field2: ID!
              field3: [ID!]!
            }
            """

            types, _ = GraphQLGen.tojl(GraphQLGen.parse(str))
            ex = GraphQLGen.ExprPrettify.prettify(types[1])
            fields = ex.args[1].args[3].args

            @test fields[1].args[1] == :field1
            @test fields[1].args[2] == :(Union{Int,Missing,Nothing})

            @test fields[2].args[1] == :field2
            @test fields[2].args[2] == :String

            @test fields[3].args[1] == :field3
            @test fields[3].args[2] == :(Vector{String})

            # Union type
        end
    end

    # need to reorder expressions when writing Julia structs
    @testset "reorder types" begin
        str = """
        union U = U1 | A

        type C {
           field1: D
        }
        input A {
          field1: [B]
        }
        type D {
           field1: ID
        }
        input B {
           field1: C
        }


        scalar S

        enum E {
           E1
           E2
        }
        """

        # DAG is A -> B -> C -> D so the output order of types
        # should be D, C, B, A.
        #
        # scalar and enum types are moved to the top
        types, _ = GraphQLGen.tojl(GraphQLGen.parse(str))
        exprs = map(GraphQLGen.ExprPrettify.prettify, types)

        @test exprs[1].args[1].args[1] == :S
        @test exprs[2].args[3] == :E
        @test exprs[3].args[1].args[2] == :D
        @test exprs[4].args[1].args[2] == :C
        @test exprs[5].args[1].args[2] == :B
        @test exprs[6].args[1].args[2] == :A
        @test exprs[7] == :(const U = Union{U1,A})
    end

    @testset "cycles" begin
        str = """
        type C {
           field1: B
        }
        type B {
           field1: A
        }
        type A {
           field1: C
           field2: A
           field3: B!
        }
        """
        types, _ = GraphQLGen.tojl(GraphQLGen.parse(str))
        exprs = map(GraphQLGen.ExprPrettify.prettify, types)
        @test exprs[1].args[1].args[2] == :A
        @test exprs[2].args[1].args[2] == :B
        @test exprs[3].args[1].args[2] == :C

        @test exprs[1].args[2].head == :function
        f = JLFunction(exprs[1].args[2])
        @test f.kwargs[1] == :($(Expr(:kw, :field1, :nothing)))
        @test f.kwargs[2] == :($(Expr(:kw, :field2, :nothing)))
        @test f.kwargs[3] == :field3

        st = exprs[1].args[1]
        fields = st.args[3].args
        @test fields[1] == :field1
        @test fields[2] == :(field2::Union{A,Missing,Nothing})
        @test fields[3] == :field3

        @test exprs[1].args[end-1].head == :function
        f = JLFunction(exprs[1].args[end-1])
        @test f.name == :(Base.getproperty)
        @test length(f.args) == 2
        @test f.args[1] == :(t::A)
        @test f.args[2] == :(sym::Symbol)

        body = :(
            if sym === Symbol("field1")
                getfield(t, Symbol("field1"))::Union{C,Missing,Nothing}
            elseif sym === Symbol("field3")
                getfield(t, Symbol("field3"))::B
            else
                getfield(t, sym)
            end
        )
        @test f.body == GraphQLGen.ExprPrettify.prettify(body)

        @test exprs[1].args[end].head == :function
        f = JLFunction(exprs[1].args[end])
        @test f.name == :(Base.setproperty!)
        @test length(f.args) == 3
        @test f.args[1] == :(t::A)
        @test f.args[2] == :(sym::Symbol)
        @test f.args[3] == :(val::Any)

        body = :(
            if sym === Symbol("field1")
                setfield!(t, Symbol("field1"), val::Union{C,Missing,Nothing})
            elseif sym === Symbol("field3")
                setfield!(t, Symbol("field3"), val::B)
            else
                setfield!(t, sym, val)
            end
        )
        @test f.body == GraphQLGen.ExprPrettify.prettify(body)
    end

    @testset "functions" begin
        @testset "query" begin
            str = """
            schema {
              query: Query
            }

            type Query {
               "this returns some books"
               books(ids: [ID!]!): Book!
               authorBooks(authorName: String!, genre: Genre, limit: Int = 10): [Book!]
            }
            """
            _, functions = GraphQLGen.tojl(GraphQLGen.parse(str))
            exprs = map(GraphQLGen.ExprPrettify.prettify, functions)

            @test exprs[1].args[1].args[1] == false # not mutable
            @test exprs[1].args[1].args[2] == :books
            @test exprs[1].args[1].args[3] == :(query::String)
            @test exprs[1].args[2] == "\"\"\"\nthis returns some books\n\"\"\""
            f = JLFunction(exprs[1].args[3])
            @test f.name == :(f::books)
            @test f.args == Any[:(ids::Vector{String})]
            @test f.kwargs == Any[]

            f = JLFunction(exprs[2].args[2])
            @test f.name == :(f::authorBooks)
            @test f.args == Any[:(authorName::String)]
            @test f.kwargs[1] ==
                  :($(Expr(:kw, :(genre::Union{Genre,Missing,Nothing}), :nothing)))
            @test f.kwargs[2] == :($(Expr(:kw, :(limit::Union{Int,Missing,Nothing}), 10)))
        end

        @testset "mutation" begin
            str = """
            schema {
              mutation: Mutation
            }

            type Mutation {
              addBooks(input: [BookInput!]!): [ID!]!
            }

            input BookInput {
                author: String!
                name: String!
                year: Int
            }
            """

            types, functions = GraphQLGen.tojl(GraphQLGen.parse(str))
            @test length(types) == 1
            @test length(functions) == 1
            exprs = map(GraphQLGen.ExprPrettify.prettify, functions)

            f = JLFunction(exprs[1].args[2])
            @test f.name == :(f::addBooks)
            @test f.args == Any[:(input::Vector{BookInput})]
            @test f.kwargs == Any[]
        end
    end

    @testset "docstrings" begin
        @testset "types" begin
            str = """

            \"""The date a film was released.\"""
            scalar ReleaseDate

            \"""A single film.\"""
            type Film implements Node {
              \"""Title of this film.\"""
              title: String

              \"""Genre of the film.\"""
              genre: Genre
            }

            type TelevisionSeries implements Node {
              \"""Title of this tv show.\"""
              title: String

              \"""Genre of the tv show.\"""
              genre: Genre
            }

            \"""Input for a film.\"""
            input FilmInput {
              \"""The title of this film.\"""
              title: String!
              \"""Genre of the film.\"""
              genre: Genre!
            }

            \"""Genre of a film.\"""
            enum Genre {
              \"""An action film.\"""
              ACTION
              \"""A comedy film.\"""
              COMEDY
            }

            \"""Filmed on camera.\"""
            union CameraUsed = Film | TelevisionSeries
            """
            types, _ = GraphQLGen.tojl(GraphQLGen.parse(str))
            exprs = map(GraphQLGen.ExprPrettify.prettify, types)

            @test exprs[1].args[3] == "The date a film was released."

            @test exprs[2].args[3] == "Genre of a film."
            @test exprs[2].args[4].args[1] == Symbol("@enum")
            @test exprs[2].args[4].args[3] == :Genre
            fields = exprs[2].args[4].args[4]
            @test fields.args[1].args[3] == "An action film."
            @test fields.args[1].args[4] == :ACTION
            @test fields.args[2].args[3] == "A comedy film."
            @test fields.args[2].args[4] == :COMEDY

            st = exprs[3].args[1]
            @test st.args[2] == :TelevisionSeries
            fields = st.args[3]
            @test fields.args[1] == "Title of this tv show."
            @test fields.args[2] == :(title::Union{String,Missing,Nothing})
            @test fields.args[3] == "Genre of the tv show."
            @test fields.args[4] == :(genre::Union{Genre,Missing,Nothing})

            @test exprs[4].args[1] == "\"\"\"\nA single film.\n\"\"\""
            st = exprs[4].args[2]
            @test st.args[2] == :Film
            fields = st.args[3]
            @test fields.args[1] == "Title of this film."
            @test fields.args[2] == :(title::Union{String,Missing,Nothing})
            @test fields.args[3] == "Genre of the film."
            @test fields.args[4] == :(genre::Union{Genre,Missing,Nothing})

            @test exprs[5].args[3] == "Filmed on camera."

            @test exprs[6].args[1] == "\"\"\"\nInput for a film.\n\"\"\""
            st = exprs[6].args[2]
            @test st.args[2] == :FilmInput
            fields = st.args[3]
            @test fields.args[1] == "The title of this film."
            @test fields.args[2] == :(title::String)
            @test fields.args[3] == "Genre of the film."
            @test fields.args[4] == :(genre::Genre)
        end

        @testset "functions" begin
            str = """
            schema {
              query: Root
            }

            type Root {
              "Fetches an object given its ID."
              node(id: ID!): Node
            }
            """
            _, functions = GraphQLGen.tojl(GraphQLGen.parse(str))
            exprs = map(GraphQLGen.ExprPrettify.prettify, functions)

            @test exprs[1].args[2] == "\"\"\"\nFetches an object given its ID.\n\"\"\""

            body = :(
                function (f::node)(id::String;)
                    q = (inp -> begin
                            s = "query Node(\$id: ID!) {\n    node(id: \$id) {\n"
                            s *= inp
                            s *= "    }\n}\n"
                        end)
                    query = q(f.query)
                    variables = Dict{String,Any}("id" => id)
                    filter!((v -> !(isnothing(v[2]))), variables)
                    return (; query, variables)
                end
            )
            @test exprs[1].args[3] == GraphQLGen.ExprPrettify.prettify(body)
        end
    end

    @testset "skip" begin
        str = """
        schema {
          query: Query
          mutation: Mutation
          subscription: Subscription
        }

        union U = U1 | A

        type C {
           field1: D
        }
        input A {
          field1: [B]
        }

        scalar S

        enum E {
           E1
           E2
        }


        type Query {
          query1(id: ID!): Node
          query2(id: ID!): Node
        }

        type Mutation {
          mutation1(id: ID!): Node
          mutation2(id: ID!): Node
        }

        type Subscription {
        }

        """
        types, functions = GraphQLGen.tojl(
            GraphQLGen.parse(str);
            to_skip = Set([:U, :C, :A, :S, :E, :query1, :Mutation]),
        )
        @test length(types) == 0
        @test length(functions) == 1

        exprs = map(GraphQLGen.ExprPrettify.prettify, functions)
        @test exprs[1].args[1].args[2] == :query2
    end

    @testset "generate API" begin
        header = """
        # This file was generated by GraphQLGen.
        """
        td = tempname()
        d = splitpath(td)[end]
        pkgname = Symbol(d)
        GraphQLGen.generate(
            td,
            "$(@__DIR__)/../example/schema.graphql";
            to_skip = Set([:MyType]),
            generated_header = header,
            scalar_type_map = Dict(
                :MyType2 => :Int64,
            ),
        )

        Pkg.API.activate(td)

        filepath = "$td/$pkgname.jl"

        ex = :(include($filepath);
        API = $pkgname)
        eval(ex)

        @testset "API get/set" begin
            p = API.Person(; id = "22")
            edge = API.FilmCharactersEdge(p, "film")
            @test edge.node == p

            edge.node = nothing
            @test edge.node === nothing

            edge.node = missing
            @test edge.node === missing
        end

        @testset "API skip" begin
            try
                API.MyType
            catch err
                @test typeof(err) == UndefVarError
                @test err.var == :MyType
            end
        end

        @testset "API generated header" begin
            s = String(read(filepath))
            @test startswith(s, header)
        end

        @testset "API scalar type map" begin
            @test API.MyType2 == Int64
        end
    end
end
