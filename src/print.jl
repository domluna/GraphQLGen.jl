function print(io::IO, ex::Expr)
    ex = ExprPrettify.prettify(ex)
    if ex.head === :block
        for a in ex.args
            if !isnothing(a) && a !== :nothing
                println(io, a)
            end
        end
    else
        println(io, ex)
    end
    println(io)
end

function print(io::IO, exprs::Vector{Expr})
    for ex in exprs
        print(io, ex)
    end
    return
end
