function print(io::IO, exprs::Vector{Expr})
    for ex in exprs
        ex = ExprPrettify.prettify(ex)
        if ex.head === :block
            for a in ex.args
                if !isnothing(a)
                    println(io, a)
                end
            end
        else
            println(io, ex)
        end
        println(io)
    end
    return
end
