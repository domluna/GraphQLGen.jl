using JSON3
using Test

# module name is example
include("example.jl")

NODE_QUERY = """
id
"""
f = example.node(NODE_QUERY)

# Returns a GraphQL query and the variables required to execute it.
x = f("10")

# You can serialize the variables to JSON (as an example) and send use it
# in an HTTP request.
j = JSON3.write(x.variables)
# output: "{\"id\":\"10\"}"

@testset "API" begin
    p = example.Person(; id = "22")
    edge = example.FilmCharactersEdge(p, "film")
    @test edge.node == p

    edge.node = nothing
    @test edge.node === nothing

    edge.node = missing
    @test edge.node === missing
end
