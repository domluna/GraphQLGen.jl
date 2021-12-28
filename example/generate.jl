using GraphQLGen

# Generate Julia code files in the same directory based on the GraphQL schema in "schema.graphql".
#
# The code fles are
#  * graphqlgen_types.jl - contains all the GraphQL types
#  * graphqlgen_functions.jl - contains all the GraphQL functions (mutations, queries, subscriptions)
GraphQLGen.generate("$(@__DIR__)", "schema.graphql")
