function print(io, exprs::Vector{Expr})
    for ex in exprs
        ex = ExprPrettify.prettify(ex)
        if ex.head === :block
            for a in ex.args
                println(io, a)
            end
        else
            println(io, ex)
        end
        println(io)
    end
    return
end

function print(exprs::Vector{Expr})
    print(stdout, exprs)
end
