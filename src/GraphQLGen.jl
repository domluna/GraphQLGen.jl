module GraphQLGen

using RBNF
using Expronicon

include("types.jl")
include("parser.jl")
include("dag.jl")
include("jlgen.jl")

include("ExprPrettify/expr_prettify.jl")
include("print.jl")

"""
    parse(schema::AbstractString)

Parse a GraphQL schema at top-level to AST.
"""
function parse(schema::AbstractString)
    tokens = RBNF.runlexer(GQL, schema)
    ast, ctx = RBNF.runparser(document, tokens)
    ctx.tokens.current > ctx.tokens.length ||
        throw(Meta.ParseError("invalid syntax in GraphQL program"))
    return ast
end

end
