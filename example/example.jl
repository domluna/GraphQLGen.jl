using JSON3

module API
using StructTypes
include("graphqlgen_types.jl")
include("graphqlgen_functions.jl")
end;

NODE_QUERY = """
id
"""
f = API.node(NODE_QUERY)

# Returns a GraphQL query and the variables required to execute it.
x = f("10")

# You can serialize the variables to JSON (as an example) and send use it
# in an HTTP request.
j = JSON3.write(x.variables)
# output: "{\"id\":\"10\"}"
