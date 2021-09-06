# adapted from https://github.com/FluxML/MacroTools.jl/blob/master/src/utils.jl
module ExprPrettify

export prettify

walk(x, inner, outer) = outer(x)
walk(x::Expr, inner, outer) = outer(Expr(x.head, map(inner, x.args)...))

"""
    postwalk(f, expr)

Applies `f` to each node in the given expression tree, returning the result.
`f` sees expressions *after* they have been transformed by the walk.

See also: [`prewalk`](@ref).
"""
postwalk(f, x) = walk(x, x -> postwalk(f, x), f)

"""
    prewalk(f, expr)

Applies `f` to each node in the given expression tree, returning the result.
`f` sees expressions *before* they have been transformed by the walk, and the
walk will be applied to whatever `f` returns.

This makes `prewalk` somewhat prone to infinite loops; you probably want to try
[`postwalk`](@ref) first.
"""
prewalk(f, x) = walk(f(x), x -> prewalk(f, x), identity)

"""
    isexpr(x, ts...)

Convenient way to test the type of a Julia expression.
Expression heads and types are supported, so for example
you can call

    isexpr(expr, String, :string)

to pick up on all string-like expressions.
"""
isexpr(x::Expr) = true
isexpr(x) = false
isexpr(x::Expr, ts...) = x.head in ts
isexpr(x, ts...) = any(T -> isa(T, Type) && isa(x, T), ts)

isline(ex) = isexpr(ex, :line) || isa(ex, LineNumberNode)

rmlines(x) = x
function rmlines(x::Expr)
    # Do not strip the first argument to a macrocall, which is
    # required.
    if x.head == :macrocall && length(x.args) >= 2
        Expr(x.head, x.args[1], nothing, filter(x -> !isline(x), x.args[3:end])...)
    else
        Expr(x.head, filter(x -> !isline(x), x.args)...)
    end
end

striplines(ex) = prewalk(rmlines, ex)

function flatten1(ex)
    isexpr(ex, :block) || return ex
    #ex′ = :(;)
    ex′ = Expr(:block)
    for x in ex.args
        isexpr(x, :block) ? append!(ex′.args, x.args) : push!(ex′.args, x)
    end
    # Don't use `unblock` to preserve line nos
    return length(ex′.args) == 1 ? ex′.args[1] : ex′
end

"""
    flatten(ex)

Flatten any redundant blocks into a single block, over the whole expression.
"""
flatten(ex) = postwalk(flatten1, ex)

"""
    prettify(ex)

Makes generated code generaly nicer to look at.
"""
prettify(ex; lines = false) = ex |> (lines ? identity : striplines) |> flatten

end
