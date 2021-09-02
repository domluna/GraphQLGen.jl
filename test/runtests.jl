using GraphQLGen
using Test
using Expronicon

@testset "scalar" begin
    str = """
    scalar A
    scalar B
    scalar C
    """
    scalar_type_map = Dict(:A => :Point, :B => Vector{UInt8})
    types, _ = GraphQLGen.tojl(GraphQLGen.parse(str), scalar_type_map)
    exprs = map(GraphQLGen.ExprPrettify.prettify, types)
    @test exprs[1] == :(const A = Point)
    @test exprs[2].args[1].head == :(=)
    @test exprs[2].args[1].args[1] == :(B)
    @test exprs[2].args[1].args[2] == Vector{UInt8}
    @test exprs[3] == :(const C = Any)
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
        fields = ex.args[1].args[3].args[3].args

        # field2 should appear before field1 because it's not optional
        @test fields[1].args[1] == :field2
        @test fields[1].args[2] == :String

        @test fields[2].args[1] == :field3
        @test fields[2].args[2] == :(Vector{String})

        # Union type
        @test fields[3].args[1].args[1] == :field1
        @test fields[3].args[1].args[2] == :(Union{Int32,Missing,Nothing})
        @test isnothing(fields[3].args[2])
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
    @test exprs[3].args[1].args[3].args[2] == :D
    @test exprs[4].args[1].args[3].args[2] == :C
    @test exprs[5].args[1].args[3].args[2] == :B
    @test exprs[6].args[1].args[3].args[2] == :A
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
    @test exprs[1].args[1].args[3].args[2] == :A
    @test exprs[2].args[1].args[3].args[2] == :B
    @test exprs[3].args[1].args[3].args[2] == :C

    @test exprs[1].args[end].head == :function
    f = JLFunction(exprs[1].args[end])

    funcdef = :(Base.getproperty(t::A, sym::Symbol))
    @test f.name == :(Base.getproperty)

    body = :(
        if s === Symbol("field3")
            getfield(t, Symbol("field3"))::B
        elseif s === Symbol("field1")
            getfield(t, Symbol("field1"))::Union{C,Missing,Nothing}
        else
            getfield(t, s)
        end
    )
    @test f.body == GraphQLGen.ExprPrettify.prettify(body)
end

@testset "functions" begin
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

    f = JLFunction(exprs[1].args[2])
    @test f.name == :(f::books)
    @test f.args == Any[:(ids::Vector{String})]
    @test f.kwargs == Any[]

    f = JLFunction(exprs[2].args[2])
    @test f.name == :(f::authorBooks)
    @test f.args == Any[:(authorName::String)]
    @test f.kwargs[1] == :($(Expr(:kw, :(genre::Union{Genre,Missing,Nothing}), nothing)))
    @test f.kwargs[2] ==
          :($(Expr(:kw, :(limit::Union{Int32,Missing,Nothing}), Symbol("10"))))

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
    # ID turns into String
    @test f.rettype == :(Vector{String})
end
