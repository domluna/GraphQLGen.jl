function dagify(doc::Document)
    g = Dict{Symbol,Set{Symbol}}()

    node_ids = Dict{Symbol,Int}()
    sorted_definitions = Any[]

    # list of user defined types
    for (i, d) in enumerate(doc)
        !(d isa TypeDefinition) && continue

        typ = d.type
        if typ isa ObjectTypeDefinition ||
           typ isa InputObjectTypeDefinition ||
           typ isa UnionTypeDefinition
            n = node_id(d)
            g[n] = Set{Symbol}()
            node_ids[n] = i

            edges = collect_edges(d)
            for e in edges
                (e in BUILTIN_GRAPHQL_TYPES) && continue
                push!(g[n], e)
            end
        elseif typ isa ScalarTypeDefinition || typ isa EnumTypeDefinition
            # toplevel
            push!(sorted_definitions, d)
        end
    end

    sorted_nodes, revisited_graph = topological_sort(g)
    for n in sorted_nodes
        id = get(node_ids, n, nothing)
        !isnothing(id) && push!(sorted_definitions, doc[id])
    end

    return Document(sorted_definitions), revisited_graph
end

function topological_sort(graph::Dict{Symbol,Set{Symbol}})
    nodes = collect(keys(graph))
    visited_nodes = Set{Symbol}()
    temporary_nodes = Set{Symbol}()
    sorted_nodes = Symbol[]
    revisited_graph = Dict{Symbol,Set{Symbol}}()

    while !isempty(nodes)
        n = pop!(nodes)
        visit!(
            (nothing, n),
            graph,
            sorted_nodes,
            visited_nodes,
            temporary_nodes,
            revisited_graph,
        )
    end

    return sorted_nodes, revisited_graph
end

function visit!(
    edge::Tuple{Union{Symbol,Nothing},Symbol},
    graph::Dict{Symbol,Set{Symbol}},
    sorted_nodes::Vector{Symbol},
    visited_nodes::Set{Symbol},
    temporary_nodes::Set{Symbol},
    revisited_graph::Dict{Symbol,Set{Symbol}},
)
    from, node = edge[1], edge[2]

    node in visited_nodes && return

    if node in temporary_nodes
        node == from && return

        if haskey(revisited_graph, from)
            push!(revisited_graph[from], node)
        else
            revisited_graph[from] = Set([node])
        end
        return
    end

    push!(temporary_nodes, node)

    for n in get(graph, node, Symbol[])
        visit!(
            (node, n),
            graph,
            sorted_nodes,
            visited_nodes,
            temporary_nodes,
            revisited_graph,
        )
    end

    delete!(temporary_nodes, node)
    push!(visited_nodes, node)
    push!(sorted_nodes, node)

    return
end

collect_edges(t) = Symbol[]
collect_edges(t::TypeDefinition) = collect_edges(t.type)

function collect_edges(t::ObjectTypeDefinition)
    map(t.fields_definition) do fd
        node_id(fd)
    end
end

function collect_edges(t::InputObjectTypeDefinition)
    map(t.fields) do fd
        node_id(fd)
    end
end

function collect_edges(t::UnionTypeDefinition)
    map(t.types) do fd
        node_id(fd)
    end
end

node_id(x::TypeDefinition) = node_id(x.type)
node_id(x::ObjectTypeDefinition) = node_id(x.name)
node_id(x::InputObjectTypeDefinition) = node_id(x.name)
node_id(x::UnionTypeDefinition) = node_id(x.name)
node_id(x::ScalarTypeDefinition) = node_id(x.name)
node_id(x::EnumTypeDefinition) = node_id(x.name)
node_id(x::InputValueDefinition) = node_id(x.type)
node_id(x::FieldDefinition) = node_id(x.type)
node_id(x::NamedType) = node_id(x.type)
node_id(x::ListType) = node_id(x.type)
node_id(x::RBNF.Token) = Symbol(x.str)
