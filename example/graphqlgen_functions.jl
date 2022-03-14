struct allFilms
    query::String
end
function (f::allFilms)(;
    after::Union{String,Missing,Nothing} = nothing,
    first::Union{Int,Missing,Nothing} = nothing,
    before::Union{String,Missing,Nothing} = nothing,
    last::Union{Int,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query AllFilms(after: String, first: Int, before: String, last: Int) {\n    allFilms(after: \$after, first: \$first, before: \$before, last: \$last) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("after" => after, "first" => first, "before" => before, "last" => last)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct film
    query::String
end
function (f::film)(;
    id::Union{String,Missing,Nothing} = nothing,
    filmID::Union{String,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query Film(id: ID, filmID: ID) {\n    film(id: \$id, filmID: \$filmID) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("id" => id, "filmID" => filmID)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct allPeople
    query::String
end
function (f::allPeople)(;
    after::Union{String,Missing,Nothing} = nothing,
    first::Union{Int,Missing,Nothing} = nothing,
    before::Union{String,Missing,Nothing} = nothing,
    last::Union{Int,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query AllPeople(after: String, first: Int, before: String, last: Int) {\n    allPeople(after: \$after, first: \$first, before: \$before, last: \$last) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("after" => after, "first" => first, "before" => before, "last" => last)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct person
    query::String
end
function (f::person)(;
    id::Union{String,Missing,Nothing} = nothing,
    personID::Union{String,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query Person(id: ID, personID: ID) {\n    person(id: \$id, personID: \$personID) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("id" => id, "personID" => personID)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct allPlanets
    query::String
end
function (f::allPlanets)(;
    after::Union{String,Missing,Nothing} = nothing,
    first::Union{Int,Missing,Nothing} = nothing,
    before::Union{String,Missing,Nothing} = nothing,
    last::Union{Int,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query AllPlanets(after: String, first: Int, before: String, last: Int) {\n    allPlanets(after: \$after, first: \$first, before: \$before, last: \$last) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("after" => after, "first" => first, "before" => before, "last" => last)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct planet
    query::String
end
function (f::planet)(;
    id::Union{String,Missing,Nothing} = nothing,
    planetID::Union{String,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query Planet(id: ID, planetID: ID) {\n    planet(id: \$id, planetID: \$planetID) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("id" => id, "planetID" => planetID)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct allSpecies
    query::String
end
function (f::allSpecies)(;
    after::Union{String,Missing,Nothing} = nothing,
    first::Union{Int,Missing,Nothing} = nothing,
    before::Union{String,Missing,Nothing} = nothing,
    last::Union{Int,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query AllSpecies(after: String, first: Int, before: String, last: Int) {\n    allSpecies(after: \$after, first: \$first, before: \$before, last: \$last) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("after" => after, "first" => first, "before" => before, "last" => last)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct species
    query::String
end
function (f::species)(;
    id::Union{String,Missing,Nothing} = nothing,
    speciesID::Union{String,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query Species(id: ID, speciesID: ID) {\n    species(id: \$id, speciesID: \$speciesID) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("id" => id, "speciesID" => speciesID)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct allStarships
    query::String
end
function (f::allStarships)(;
    after::Union{String,Missing,Nothing} = nothing,
    first::Union{Int,Missing,Nothing} = nothing,
    before::Union{String,Missing,Nothing} = nothing,
    last::Union{Int,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query AllStarships(after: String, first: Int, before: String, last: Int) {\n    allStarships(after: \$after, first: \$first, before: \$before, last: \$last) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("after" => after, "first" => first, "before" => before, "last" => last)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct starship
    query::String
end
function (f::starship)(;
    id::Union{String,Missing,Nothing} = nothing,
    starshipID::Union{String,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query Starship(id: ID, starshipID: ID) {\n    starship(id: \$id, starshipID: \$starshipID) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("id" => id, "starshipID" => starshipID)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct allVehicles
    query::String
end
function (f::allVehicles)(;
    after::Union{String,Missing,Nothing} = nothing,
    first::Union{Int,Missing,Nothing} = nothing,
    before::Union{String,Missing,Nothing} = nothing,
    last::Union{Int,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query AllVehicles(after: String, first: Int, before: String, last: Int) {\n    allVehicles(after: \$after, first: \$first, before: \$before, last: \$last) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("after" => after, "first" => first, "before" => before, "last" => last)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct vehicle
    query::String
end
function (f::vehicle)(;
    id::Union{String,Missing,Nothing} = nothing,
    vehicleID::Union{String,Missing,Nothing} = nothing,
)
    q = (
        inp -> begin
            s = "query Vehicle(id: ID, vehicleID: ID) {\n    vehicle(id: \$id, vehicleID: \$vehicleID) {\n"
            s *= inp
            s *= "    }\n}\n"
        end
    )
    query = q(f.query)
    variables = Dict("id" => id, "vehicleID" => vehicleID)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end

struct node
    query::String
end
"""
Fetches an object given its ID
"""
function (f::node)(id::String;)
    q = (inp -> begin
        s = "query Node(id: ID!) {\n    node(id: \$id) {\n"
        s *= inp
        s *= "    }\n}\n"
    end)
    query = q(f.query)
    variables = Dict("id" => id)
    filter!((v -> !(isnothing(v[2]))), variables)
    return (; query, variables)
end
