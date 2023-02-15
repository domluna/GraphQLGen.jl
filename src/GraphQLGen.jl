module GraphQLGen

const RESERVED_JL_KEYWORDS = [
    :start,
    :baremodule,
    :begin,
    :break,
    :case,
    :const,
    :continue,
    :else,
    :elseif,
    :end,
    :export,
    Symbol("false"),
    :finally,
    :for,
    :function,
    :global,
    :if,
    :import,
    :in,
    :let,
    :local,
    :macro,
    :module,
    :nothing,
    :return,
    :struct,
    Symbol("true"),
    :try,
    :type,
    :using,
    :while,
    :do,
]

using Dates
using RBNF
using EnumX
using Expronicon

include("types.jl")
include("parser.jl")
include("dag.jl")
include("codegen.jl")

include("ExprPrettify/expr_prettify.jl")
include("print.jl")

include("generate.jl")

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
