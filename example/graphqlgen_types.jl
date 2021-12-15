"""
Information about pagination in a connection.
"""
mutable struct PageInfo
    "When paginating forwards, are there more items?"
    hasNextPage::Bool
    "When paginating backwards, are there more items?"
    hasPreviousPage::Bool
    "When paginating backwards, the cursor to continue."
    startCursor::Union{String, Missing, Nothing}
    "When paginating forwards, the cursor to continue."
    endCursor::Union{String, Missing, Nothing}
end
function PageInfo(; hasNextPage, hasPreviousPage, startCursor = nothing, endCursor = nothing)
    PageInfo(hasNextPage, hasPreviousPage, startCursor, endCursor)
end
StructTypes.StructType(::Type{PageInfo}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PageInfo}) = true

"""
An edge in a connection.
"""
mutable struct FilmCharactersEdge
    node
    "A cursor for use in pagination"
    cursor::String
end
function FilmCharactersEdge(; node = nothing, cursor)
    FilmCharactersEdge(node, cursor)
end
StructTypes.StructType(::Type{FilmCharactersEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmCharactersEdge}) = true
function Base.getproperty(t::FilmCharactersEdge, sym::Symbol)
    if s === Symbol("node")
        getfield(t, Symbol("node"))::Union{Person, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A connection to a list of items.
"""
mutable struct FilmCharactersConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{FilmCharactersEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    characters
end
function FilmCharactersConnection(; pageInfo, edges = nothing, totalCount = nothing, characters = nothing)
    FilmCharactersConnection(pageInfo, edges, totalCount, characters)
end
StructTypes.StructType(::Type{FilmCharactersConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmCharactersConnection}) = true
function Base.getproperty(t::FilmCharactersConnection, sym::Symbol)
    if s === Symbol("characters")
        getfield(t, Symbol("characters"))::Union{Vector{Union{Person, Missing, Nothing}}, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
An edge in a connection.
"""
mutable struct StarshipFilmsEdge
    node
    "A cursor for use in pagination"
    cursor::String
end
function StarshipFilmsEdge(; node = nothing, cursor)
    StarshipFilmsEdge(node, cursor)
end
StructTypes.StructType(::Type{StarshipFilmsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{StarshipFilmsEdge}) = true
function Base.getproperty(t::StarshipFilmsEdge, sym::Symbol)
    if s === Symbol("node")
        getfield(t, Symbol("node"))::Union{Film, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A connection to a list of items.
"""
mutable struct StarshipFilmsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{StarshipFilmsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    films
end
function StarshipFilmsConnection(; pageInfo, edges = nothing, totalCount = nothing, films = nothing)
    StarshipFilmsConnection(pageInfo, edges, totalCount, films)
end
StructTypes.StructType(::Type{StarshipFilmsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{StarshipFilmsConnection}) = true
function Base.getproperty(t::StarshipFilmsConnection, sym::Symbol)
    if s === Symbol("films")
        getfield(t, Symbol("films"))::Union{Vector{Union{Film, Missing, Nothing}}, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
An edge in a connection.
"""
mutable struct StarshipPilotsEdge
    node
    "A cursor for use in pagination"
    cursor::String
end
function StarshipPilotsEdge(; node = nothing, cursor)
    StarshipPilotsEdge(node, cursor)
end
StructTypes.StructType(::Type{StarshipPilotsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{StarshipPilotsEdge}) = true
function Base.getproperty(t::StarshipPilotsEdge, sym::Symbol)
    if s === Symbol("node")
        getfield(t, Symbol("node"))::Union{Person, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A connection to a list of items.
"""
mutable struct StarshipPilotsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{StarshipPilotsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    pilots
end
function StarshipPilotsConnection(; pageInfo, edges = nothing, totalCount = nothing, pilots = nothing)
    StarshipPilotsConnection(pageInfo, edges, totalCount, pilots)
end
StructTypes.StructType(::Type{StarshipPilotsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{StarshipPilotsConnection}) = true
function Base.getproperty(t::StarshipPilotsConnection, sym::Symbol)
    if s === Symbol("pilots")
        getfield(t, Symbol("pilots"))::Union{Vector{Union{Person, Missing, Nothing}}, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A single transport craft that has hyperdrive capability.
"""
mutable struct Starship
    "The name of this starship. The common name, such as \"Death Star\"."
    name::Union{String, Missing, Nothing}
    "\n  The model or official name of this starship. Such as \"T-65 X-wing\" or \"DS-1\n  Orbital Battle Station\".\n  "
    model::Union{String, Missing, Nothing}
    "\n  The class of this starship, such as \"Starfighter\" or \"Deep Space Mobile\n  Battlestation\"\n  "
    starshipClass::Union{String, Missing, Nothing}
    "The manufacturers of this starship."
    manufacturers::Union{Vector{Union{String, Missing, Nothing}}, Missing, Nothing}
    "The cost of this starship new, in galactic credits."
    costInCredits::Union{Float64, Missing, Nothing}
    "The length of this starship in meters."
    length::Union{Float64, Missing, Nothing}
    "The number of personnel needed to run or pilot this starship."
    crew::Union{String, Missing, Nothing}
    "The number of non-essential people this starship can transport."
    passengers::Union{String, Missing, Nothing}
    "\n  The maximum speed of this starship in atmosphere. null if this starship is\n  incapable of atmosphering flight.\n  "
    maxAtmospheringSpeed::Union{Int32, Missing, Nothing}
    "The class of this starships hyperdrive."
    hyperdriveRating::Union{Float64, Missing, Nothing}
    "\n  The Maximum number of Megalights this starship can travel in a standard hour.\n  A \"Megalight\" is a standard unit of distance and has never been defined before\n  within the Star Wars universe. This figure is only really useful for measuring\n  the difference in speed of starships. We can assume it is similar to AU, the\n  distance between our Sun (Sol) and Earth.\n  "
    MGLT::Union{Int32, Missing, Nothing}
    "The maximum number of kilograms that this starship can transport."
    cargoCapacity::Union{Float64, Missing, Nothing}
    "\n  The maximum length of time that this starship can provide consumables for its\n  entire crew without having to resupply.\n  "
    consumables::Union{String, Missing, Nothing}
    pilotConnection::Union{StarshipPilotsConnection, Missing, Nothing}
    filmConnection::Union{StarshipFilmsConnection, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was created."
    created::Union{String, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was edited."
    edited::Union{String, Missing, Nothing}
    "The ID of an object"
    id::String
end
function Starship(; name = nothing, model = nothing, starshipClass = nothing, manufacturers = nothing, costInCredits = nothing, length = nothing, crew = nothing, passengers = nothing, maxAtmospheringSpeed = nothing, hyperdriveRating = nothing, MGLT = nothing, cargoCapacity = nothing, consumables = nothing, pilotConnection = nothing, filmConnection = nothing, created = nothing, edited = nothing, id)
    Starship(name, model, starshipClass, manufacturers, costInCredits, length, crew, passengers, maxAtmospheringSpeed, hyperdriveRating, MGLT, cargoCapacity, consumables, pilotConnection, filmConnection, created, edited, id)
end
StructTypes.StructType(::Type{Starship}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{Starship}) = true

"""
An edge in a connection.
"""
mutable struct FilmStarshipsEdge
    "The item at the end of the edge"
    node::Union{Starship, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function FilmStarshipsEdge(; node = nothing, cursor)
    FilmStarshipsEdge(node, cursor)
end
StructTypes.StructType(::Type{FilmStarshipsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmStarshipsEdge}) = true

"""
A connection to a list of items.
"""
mutable struct FilmStarshipsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{FilmStarshipsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    starships::Union{Vector{Union{Starship, Missing, Nothing}}, Missing, Nothing}
end
function FilmStarshipsConnection(; pageInfo, edges = nothing, totalCount = nothing, starships = nothing)
    FilmStarshipsConnection(pageInfo, edges, totalCount, starships)
end
StructTypes.StructType(::Type{FilmStarshipsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmStarshipsConnection}) = true

"""
An edge in a connection.
"""
mutable struct FilmVehiclesEdge
    node
    "A cursor for use in pagination"
    cursor::String
end
function FilmVehiclesEdge(; node = nothing, cursor)
    FilmVehiclesEdge(node, cursor)
end
StructTypes.StructType(::Type{FilmVehiclesEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmVehiclesEdge}) = true
function Base.getproperty(t::FilmVehiclesEdge, sym::Symbol)
    if s === Symbol("node")
        getfield(t, Symbol("node"))::Union{Vehicle, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A connection to a list of items.
"""
mutable struct FilmVehiclesConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{FilmVehiclesEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    vehicles
end
function FilmVehiclesConnection(; pageInfo, edges = nothing, totalCount = nothing, vehicles = nothing)
    FilmVehiclesConnection(pageInfo, edges, totalCount, vehicles)
end
StructTypes.StructType(::Type{FilmVehiclesConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmVehiclesConnection}) = true
function Base.getproperty(t::FilmVehiclesConnection, sym::Symbol)
    if s === Symbol("vehicles")
        getfield(t, Symbol("vehicles"))::Union{Vector{Union{Vehicle, Missing, Nothing}}, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
An edge in a connection.
"""
mutable struct FilmPlanetsEdge
    node
    "A cursor for use in pagination"
    cursor::String
end
function FilmPlanetsEdge(; node = nothing, cursor)
    FilmPlanetsEdge(node, cursor)
end
StructTypes.StructType(::Type{FilmPlanetsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmPlanetsEdge}) = true
function Base.getproperty(t::FilmPlanetsEdge, sym::Symbol)
    if s === Symbol("node")
        getfield(t, Symbol("node"))::Union{Planet, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A connection to a list of items.
"""
mutable struct FilmPlanetsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{FilmPlanetsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    planets
end
function FilmPlanetsConnection(; pageInfo, edges = nothing, totalCount = nothing, planets = nothing)
    FilmPlanetsConnection(pageInfo, edges, totalCount, planets)
end
StructTypes.StructType(::Type{FilmPlanetsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmPlanetsConnection}) = true
function Base.getproperty(t::FilmPlanetsConnection, sym::Symbol)
    if s === Symbol("planets")
        getfield(t, Symbol("planets"))::Union{Vector{Union{Planet, Missing, Nothing}}, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
An edge in a connection.
"""
mutable struct SpeciesFilmsEdge
    node
    "A cursor for use in pagination"
    cursor::String
end
function SpeciesFilmsEdge(; node = nothing, cursor)
    SpeciesFilmsEdge(node, cursor)
end
StructTypes.StructType(::Type{SpeciesFilmsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{SpeciesFilmsEdge}) = true
function Base.getproperty(t::SpeciesFilmsEdge, sym::Symbol)
    if s === Symbol("node")
        getfield(t, Symbol("node"))::Union{Film, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A connection to a list of items.
"""
mutable struct SpeciesFilmsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{SpeciesFilmsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    films
end
function SpeciesFilmsConnection(; pageInfo, edges = nothing, totalCount = nothing, films = nothing)
    SpeciesFilmsConnection(pageInfo, edges, totalCount, films)
end
StructTypes.StructType(::Type{SpeciesFilmsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{SpeciesFilmsConnection}) = true
function Base.getproperty(t::SpeciesFilmsConnection, sym::Symbol)
    if s === Symbol("films")
        getfield(t, Symbol("films"))::Union{Vector{Union{Film, Missing, Nothing}}, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
An edge in a connection.
"""
mutable struct SpeciesPeopleEdge
    node
    "A cursor for use in pagination"
    cursor::String
end
function SpeciesPeopleEdge(; node = nothing, cursor)
    SpeciesPeopleEdge(node, cursor)
end
StructTypes.StructType(::Type{SpeciesPeopleEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{SpeciesPeopleEdge}) = true
function Base.getproperty(t::SpeciesPeopleEdge, sym::Symbol)
    if s === Symbol("node")
        getfield(t, Symbol("node"))::Union{Person, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A connection to a list of items.
"""
mutable struct SpeciesPeopleConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{SpeciesPeopleEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    people
end
function SpeciesPeopleConnection(; pageInfo, edges = nothing, totalCount = nothing, people = nothing)
    SpeciesPeopleConnection(pageInfo, edges, totalCount, people)
end
StructTypes.StructType(::Type{SpeciesPeopleConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{SpeciesPeopleConnection}) = true
function Base.getproperty(t::SpeciesPeopleConnection, sym::Symbol)
    if s === Symbol("people")
        getfield(t, Symbol("people"))::Union{Vector{Union{Person, Missing, Nothing}}, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A type of person or character within the Star Wars Universe.
"""
mutable struct Species
    "The name of this species."
    name::Union{String, Missing, Nothing}
    "The classification of this species, such as \"mammal\" or \"reptile\"."
    classification::Union{String, Missing, Nothing}
    "The designation of this species, such as \"sentient\"."
    designation::Union{String, Missing, Nothing}
    "The average height of this species in centimeters."
    averageHeight::Union{Float64, Missing, Nothing}
    "The average lifespan of this species in years, null if unknown."
    averageLifespan::Union{Int32, Missing, Nothing}
    "\n  Common eye colors for this species, null if this species does not typically\n  have eyes.\n  "
    eyeColors::Union{Vector{Union{String, Missing, Nothing}}, Missing, Nothing}
    "\n  Common hair colors for this species, null if this species does not typically\n  have hair.\n  "
    hairColors::Union{Vector{Union{String, Missing, Nothing}}, Missing, Nothing}
    "\n  Common skin colors for this species, null if this species does not typically\n  have skin.\n  "
    skinColors::Union{Vector{Union{String, Missing, Nothing}}, Missing, Nothing}
    "The language commonly spoken by this species."
    language::Union{String, Missing, Nothing}
    homeworld
    personConnection::Union{SpeciesPeopleConnection, Missing, Nothing}
    filmConnection::Union{SpeciesFilmsConnection, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was created."
    created::Union{String, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was edited."
    edited::Union{String, Missing, Nothing}
    "The ID of an object"
    id::String
end
function Species(; name = nothing, classification = nothing, designation = nothing, averageHeight = nothing, averageLifespan = nothing, eyeColors = nothing, hairColors = nothing, skinColors = nothing, language = nothing, homeworld = nothing, personConnection = nothing, filmConnection = nothing, created = nothing, edited = nothing, id)
    Species(name, classification, designation, averageHeight, averageLifespan, eyeColors, hairColors, skinColors, language, homeworld, personConnection, filmConnection, created, edited, id)
end
StructTypes.StructType(::Type{Species}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{Species}) = true
function Base.getproperty(t::Species, sym::Symbol)
    if s === Symbol("homeworld")
        getfield(t, Symbol("homeworld"))::Union{Planet, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
An edge in a connection.
"""
mutable struct FilmSpeciesEdge
    "The item at the end of the edge"
    node::Union{Species, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function FilmSpeciesEdge(; node = nothing, cursor)
    FilmSpeciesEdge(node, cursor)
end
StructTypes.StructType(::Type{FilmSpeciesEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmSpeciesEdge}) = true

"""
A connection to a list of items.
"""
mutable struct FilmSpeciesConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{FilmSpeciesEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    species::Union{Vector{Union{Species, Missing, Nothing}}, Missing, Nothing}
end
function FilmSpeciesConnection(; pageInfo, edges = nothing, totalCount = nothing, species = nothing)
    FilmSpeciesConnection(pageInfo, edges, totalCount, species)
end
StructTypes.StructType(::Type{FilmSpeciesConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmSpeciesConnection}) = true

"""
A single film.
"""
mutable struct Film
    "The title of this film."
    title::Union{String, Missing, Nothing}
    "The episode number of this film."
    episodeID::Union{Int32, Missing, Nothing}
    "The opening paragraphs at the beginning of this film."
    openingCrawl::Union{String, Missing, Nothing}
    "The name of the director of this film."
    director::Union{String, Missing, Nothing}
    "The name(s) of the producer(s) of this film."
    producers::Union{Vector{Union{String, Missing, Nothing}}, Missing, Nothing}
    "The ISO 8601 date format of film release at original creator country."
    releaseDate::Union{String, Missing, Nothing}
    speciesConnection::Union{FilmSpeciesConnection, Missing, Nothing}
    starshipConnection::Union{FilmStarshipsConnection, Missing, Nothing}
    vehicleConnection::Union{FilmVehiclesConnection, Missing, Nothing}
    characterConnection::Union{FilmCharactersConnection, Missing, Nothing}
    planetConnection::Union{FilmPlanetsConnection, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was created."
    created::Union{String, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was edited."
    edited::Union{String, Missing, Nothing}
    "The ID of an object"
    id::String
end
function Film(; title = nothing, episodeID = nothing, openingCrawl = nothing, director = nothing, producers = nothing, releaseDate = nothing, speciesConnection = nothing, starshipConnection = nothing, vehicleConnection = nothing, characterConnection = nothing, planetConnection = nothing, created = nothing, edited = nothing, id)
    Film(title, episodeID, openingCrawl, director, producers, releaseDate, speciesConnection, starshipConnection, vehicleConnection, characterConnection, planetConnection, created, edited, id)
end
StructTypes.StructType(::Type{Film}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{Film}) = true

"""
An edge in a connection.
"""
mutable struct VehicleFilmsEdge
    "The item at the end of the edge"
    node::Union{Film, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function VehicleFilmsEdge(; node = nothing, cursor)
    VehicleFilmsEdge(node, cursor)
end
StructTypes.StructType(::Type{VehicleFilmsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{VehicleFilmsEdge}) = true

"""
A connection to a list of items.
"""
mutable struct VehicleFilmsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{VehicleFilmsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    films::Union{Vector{Union{Film, Missing, Nothing}}, Missing, Nothing}
end
function VehicleFilmsConnection(; pageInfo, edges = nothing, totalCount = nothing, films = nothing)
    VehicleFilmsConnection(pageInfo, edges, totalCount, films)
end
StructTypes.StructType(::Type{VehicleFilmsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{VehicleFilmsConnection}) = true

"""
An edge in a connection.
"""
mutable struct VehiclePilotsEdge
    node
    "A cursor for use in pagination"
    cursor::String
end
function VehiclePilotsEdge(; node = nothing, cursor)
    VehiclePilotsEdge(node, cursor)
end
StructTypes.StructType(::Type{VehiclePilotsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{VehiclePilotsEdge}) = true
function Base.getproperty(t::VehiclePilotsEdge, sym::Symbol)
    if s === Symbol("node")
        getfield(t, Symbol("node"))::Union{Person, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A connection to a list of items.
"""
mutable struct VehiclePilotsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{VehiclePilotsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    pilots
end
function VehiclePilotsConnection(; pageInfo, edges = nothing, totalCount = nothing, pilots = nothing)
    VehiclePilotsConnection(pageInfo, edges, totalCount, pilots)
end
StructTypes.StructType(::Type{VehiclePilotsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{VehiclePilotsConnection}) = true
function Base.getproperty(t::VehiclePilotsConnection, sym::Symbol)
    if s === Symbol("pilots")
        getfield(t, Symbol("pilots"))::Union{Vector{Union{Person, Missing, Nothing}}, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
A single transport craft that does not have hyperdrive capability
"""
mutable struct Vehicle
    "\n  The name of this vehicle. The common name, such as \"Sand Crawler\" or \"Speeder\n  bike\".\n  "
    name::Union{String, Missing, Nothing}
    "\n  The model or official name of this vehicle. Such as \"All-Terrain Attack\n  Transport\".\n  "
    model::Union{String, Missing, Nothing}
    "The class of this vehicle, such as \"Wheeled\" or \"Repulsorcraft\"."
    vehicleClass::Union{String, Missing, Nothing}
    "The manufacturers of this vehicle."
    manufacturers::Union{Vector{Union{String, Missing, Nothing}}, Missing, Nothing}
    "The cost of this vehicle new, in Galactic Credits."
    costInCredits::Union{Float64, Missing, Nothing}
    "The length of this vehicle in meters."
    length::Union{Float64, Missing, Nothing}
    "The number of personnel needed to run or pilot this vehicle."
    crew::Union{String, Missing, Nothing}
    "The number of non-essential people this vehicle can transport."
    passengers::Union{String, Missing, Nothing}
    "The maximum speed of this vehicle in atmosphere."
    maxAtmospheringSpeed::Union{Int32, Missing, Nothing}
    "The maximum number of kilograms that this vehicle can transport."
    cargoCapacity::Union{Float64, Missing, Nothing}
    "\n  The maximum length of time that this vehicle can provide consumables for its\n  entire crew without having to resupply.\n  "
    consumables::Union{String, Missing, Nothing}
    pilotConnection::Union{VehiclePilotsConnection, Missing, Nothing}
    filmConnection::Union{VehicleFilmsConnection, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was created."
    created::Union{String, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was edited."
    edited::Union{String, Missing, Nothing}
    "The ID of an object"
    id::String
end
function Vehicle(; name = nothing, model = nothing, vehicleClass = nothing, manufacturers = nothing, costInCredits = nothing, length = nothing, crew = nothing, passengers = nothing, maxAtmospheringSpeed = nothing, cargoCapacity = nothing, consumables = nothing, pilotConnection = nothing, filmConnection = nothing, created = nothing, edited = nothing, id)
    Vehicle(name, model, vehicleClass, manufacturers, costInCredits, length, crew, passengers, maxAtmospheringSpeed, cargoCapacity, consumables, pilotConnection, filmConnection, created, edited, id)
end
StructTypes.StructType(::Type{Vehicle}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{Vehicle}) = true

"""
An edge in a connection.
"""
mutable struct PersonVehiclesEdge
    "The item at the end of the edge"
    node::Union{Vehicle, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function PersonVehiclesEdge(; node = nothing, cursor)
    PersonVehiclesEdge(node, cursor)
end
StructTypes.StructType(::Type{PersonVehiclesEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PersonVehiclesEdge}) = true

"""
A connection to a list of items.
"""
mutable struct PersonVehiclesConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{PersonVehiclesEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    vehicles::Union{Vector{Union{Vehicle, Missing, Nothing}}, Missing, Nothing}
end
function PersonVehiclesConnection(; pageInfo, edges = nothing, totalCount = nothing, vehicles = nothing)
    PersonVehiclesConnection(pageInfo, edges, totalCount, vehicles)
end
StructTypes.StructType(::Type{PersonVehiclesConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PersonVehiclesConnection}) = true

"""
An edge in a connection.
"""
mutable struct PersonFilmsEdge
    "The item at the end of the edge"
    node::Union{Film, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function PersonFilmsEdge(; node = nothing, cursor)
    PersonFilmsEdge(node, cursor)
end
StructTypes.StructType(::Type{PersonFilmsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PersonFilmsEdge}) = true

"""
A connection to a list of items.
"""
mutable struct PersonFilmsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{PersonFilmsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    films::Union{Vector{Union{Film, Missing, Nothing}}, Missing, Nothing}
end
function PersonFilmsConnection(; pageInfo, edges = nothing, totalCount = nothing, films = nothing)
    PersonFilmsConnection(pageInfo, edges, totalCount, films)
end
StructTypes.StructType(::Type{PersonFilmsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PersonFilmsConnection}) = true

"""
An edge in a connection.
"""
mutable struct PersonStarshipsEdge
    "The item at the end of the edge"
    node::Union{Starship, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function PersonStarshipsEdge(; node = nothing, cursor)
    PersonStarshipsEdge(node, cursor)
end
StructTypes.StructType(::Type{PersonStarshipsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PersonStarshipsEdge}) = true

"""
A connection to a list of items.
"""
mutable struct PersonStarshipsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{PersonStarshipsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    starships::Union{Vector{Union{Starship, Missing, Nothing}}, Missing, Nothing}
end
function PersonStarshipsConnection(; pageInfo, edges = nothing, totalCount = nothing, starships = nothing)
    PersonStarshipsConnection(pageInfo, edges, totalCount, starships)
end
StructTypes.StructType(::Type{PersonStarshipsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PersonStarshipsConnection}) = true

"""
An individual person or character within the Star Wars universe.
"""
mutable struct Person
    "The name of this person."
    name::Union{String, Missing, Nothing}
    "\n  The birth year of the person, using the in-universe standard of BBY or ABY -\n  Before the Battle of Yavin or After the Battle of Yavin. The Battle of Yavin is\n  a battle that occurs at the end of Star Wars episode IV: A New Hope.\n  "
    birthYear::Union{String, Missing, Nothing}
    "\n  The eye color of this person. Will be \"unknown\" if not known or \"n/a\" if the\n  person does not have an eye.\n  "
    eyeColor::Union{String, Missing, Nothing}
    "\n  The gender of this person. Either \"Male\", \"Female\" or \"unknown\",\n  \"n/a\" if the person does not have a gender.\n  "
    gender::Union{String, Missing, Nothing}
    "\n  The hair color of this person. Will be \"unknown\" if not known or \"n/a\" if the\n  person does not have hair.\n  "
    hairColor::Union{String, Missing, Nothing}
    "The height of the person in centimeters."
    height::Union{Int32, Missing, Nothing}
    "The mass of the person in kilograms."
    mass::Union{Float64, Missing, Nothing}
    "The skin color of this person."
    skinColor::Union{String, Missing, Nothing}
    homeworld
    filmConnection::Union{PersonFilmsConnection, Missing, Nothing}
    "The species that this person belongs to, or null if unknown."
    species::Union{Species, Missing, Nothing}
    starshipConnection::Union{PersonStarshipsConnection, Missing, Nothing}
    vehicleConnection::Union{PersonVehiclesConnection, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was created."
    created::Union{String, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was edited."
    edited::Union{String, Missing, Nothing}
    "The ID of an object"
    id::String
end
function Person(; name = nothing, birthYear = nothing, eyeColor = nothing, gender = nothing, hairColor = nothing, height = nothing, mass = nothing, skinColor = nothing, homeworld = nothing, filmConnection = nothing, species = nothing, starshipConnection = nothing, vehicleConnection = nothing, created = nothing, edited = nothing, id)
    Person(name, birthYear, eyeColor, gender, hairColor, height, mass, skinColor, homeworld, filmConnection, species, starshipConnection, vehicleConnection, created, edited, id)
end
StructTypes.StructType(::Type{Person}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{Person}) = true
function Base.getproperty(t::Person, sym::Symbol)
    if s === Symbol("homeworld")
        getfield(t, Symbol("homeworld"))::Union{Planet, Missing, Nothing}
    else
        getfield(t, s)
    end
end

"""
An edge in a connection.
"""
mutable struct PlanetResidentsEdge
    "The item at the end of the edge"
    node::Union{Person, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function PlanetResidentsEdge(; node = nothing, cursor)
    PlanetResidentsEdge(node, cursor)
end
StructTypes.StructType(::Type{PlanetResidentsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PlanetResidentsEdge}) = true

"""
A connection to a list of items.
"""
mutable struct PlanetResidentsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{PlanetResidentsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    residents::Union{Vector{Union{Person, Missing, Nothing}}, Missing, Nothing}
end
function PlanetResidentsConnection(; pageInfo, edges = nothing, totalCount = nothing, residents = nothing)
    PlanetResidentsConnection(pageInfo, edges, totalCount, residents)
end
StructTypes.StructType(::Type{PlanetResidentsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PlanetResidentsConnection}) = true

"""
An edge in a connection.
"""
mutable struct PlanetFilmsEdge
    "The item at the end of the edge"
    node::Union{Film, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function PlanetFilmsEdge(; node = nothing, cursor)
    PlanetFilmsEdge(node, cursor)
end
StructTypes.StructType(::Type{PlanetFilmsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PlanetFilmsEdge}) = true

"""
A connection to a list of items.
"""
mutable struct PlanetFilmsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{PlanetFilmsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    films::Union{Vector{Union{Film, Missing, Nothing}}, Missing, Nothing}
end
function PlanetFilmsConnection(; pageInfo, edges = nothing, totalCount = nothing, films = nothing)
    PlanetFilmsConnection(pageInfo, edges, totalCount, films)
end
StructTypes.StructType(::Type{PlanetFilmsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PlanetFilmsConnection}) = true

"""
A large mass, planet or planetoid in the Star Wars Universe, at the time of
0 ABY.
"""
mutable struct Planet
    "The name of this planet."
    name::Union{String, Missing, Nothing}
    "The diameter of this planet in kilometers."
    diameter::Union{Int32, Missing, Nothing}
    "\n  The number of standard hours it takes for this planet to complete a single\n  rotation on its axis.\n  "
    rotationPeriod::Union{Int32, Missing, Nothing}
    "\n  The number of standard days it takes for this planet to complete a single orbit\n  of its local star.\n  "
    orbitalPeriod::Union{Int32, Missing, Nothing}
    "\n  A number denoting the gravity of this planet, where \"1\" is normal or 1 standard\n  G. \"2\" is twice or 2 standard Gs. \"0.5\" is half or 0.5 standard Gs.\n  "
    gravity::Union{String, Missing, Nothing}
    "The average population of sentient beings inhabiting this planet."
    population::Union{Float64, Missing, Nothing}
    "The climates of this planet."
    climates::Union{Vector{Union{String, Missing, Nothing}}, Missing, Nothing}
    "The terrains of this planet."
    terrains::Union{Vector{Union{String, Missing, Nothing}}, Missing, Nothing}
    "\n  The percentage of the planet surface that is naturally occuring water or bodies\n  of water.\n  "
    surfaceWater::Union{Float64, Missing, Nothing}
    residentConnection::Union{PlanetResidentsConnection, Missing, Nothing}
    filmConnection::Union{PlanetFilmsConnection, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was created."
    created::Union{String, Missing, Nothing}
    "The ISO 8601 date format of the time that this resource was edited."
    edited::Union{String, Missing, Nothing}
    "The ID of an object"
    id::String
end
function Planet(; name = nothing, diameter = nothing, rotationPeriod = nothing, orbitalPeriod = nothing, gravity = nothing, population = nothing, climates = nothing, terrains = nothing, surfaceWater = nothing, residentConnection = nothing, filmConnection = nothing, created = nothing, edited = nothing, id)
    Planet(name, diameter, rotationPeriod, orbitalPeriod, gravity, population, climates, terrains, surfaceWater, residentConnection, filmConnection, created, edited, id)
end
StructTypes.StructType(::Type{Planet}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{Planet}) = true

"""
An edge in a connection.
"""
mutable struct PlanetsEdge
    "The item at the end of the edge"
    node::Union{Planet, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function PlanetsEdge(; node = nothing, cursor)
    PlanetsEdge(node, cursor)
end
StructTypes.StructType(::Type{PlanetsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PlanetsEdge}) = true

"""
An edge in a connection.
"""
mutable struct PeopleEdge
    "The item at the end of the edge"
    node::Union{Person, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function PeopleEdge(; node = nothing, cursor)
    PeopleEdge(node, cursor)
end
StructTypes.StructType(::Type{PeopleEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PeopleEdge}) = true

"""
An edge in a connection.
"""
mutable struct VehiclesEdge
    "The item at the end of the edge"
    node::Union{Vehicle, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function VehiclesEdge(; node = nothing, cursor)
    VehiclesEdge(node, cursor)
end
StructTypes.StructType(::Type{VehiclesEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{VehiclesEdge}) = true

"""
A connection to a list of items.
"""
mutable struct VehiclesConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{VehiclesEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    vehicles::Union{Vector{Union{Vehicle, Missing, Nothing}}, Missing, Nothing}
end
function VehiclesConnection(; pageInfo, edges = nothing, totalCount = nothing, vehicles = nothing)
    VehiclesConnection(pageInfo, edges, totalCount, vehicles)
end
StructTypes.StructType(::Type{VehiclesConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{VehiclesConnection}) = true

"""
An edge in a connection.
"""
mutable struct FilmsEdge
    "The item at the end of the edge"
    node::Union{Film, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function FilmsEdge(; node = nothing, cursor)
    FilmsEdge(node, cursor)
end
StructTypes.StructType(::Type{FilmsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmsEdge}) = true

"""
An edge in a connection.
"""
mutable struct SpeciesEdge
    "The item at the end of the edge"
    node::Union{Species, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function SpeciesEdge(; node = nothing, cursor)
    SpeciesEdge(node, cursor)
end
StructTypes.StructType(::Type{SpeciesEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{SpeciesEdge}) = true

"""
A connection to a list of items.
"""
mutable struct SpeciesConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{SpeciesEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    species::Union{Vector{Union{Species, Missing, Nothing}}, Missing, Nothing}
end
function SpeciesConnection(; pageInfo, edges = nothing, totalCount = nothing, species = nothing)
    SpeciesConnection(pageInfo, edges, totalCount, species)
end
StructTypes.StructType(::Type{SpeciesConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{SpeciesConnection}) = true

"""
A connection to a list of items.
"""
mutable struct PeopleConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{PeopleEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    people::Union{Vector{Union{Person, Missing, Nothing}}, Missing, Nothing}
end
function PeopleConnection(; pageInfo, edges = nothing, totalCount = nothing, people = nothing)
    PeopleConnection(pageInfo, edges, totalCount, people)
end
StructTypes.StructType(::Type{PeopleConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PeopleConnection}) = true

"""
A connection to a list of items.
"""
mutable struct FilmsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{FilmsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    films::Union{Vector{Union{Film, Missing, Nothing}}, Missing, Nothing}
end
function FilmsConnection(; pageInfo, edges = nothing, totalCount = nothing, films = nothing)
    FilmsConnection(pageInfo, edges, totalCount, films)
end
StructTypes.StructType(::Type{FilmsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{FilmsConnection}) = true

"""
A connection to a list of items.
"""
mutable struct PlanetsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{PlanetsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    planets::Union{Vector{Union{Planet, Missing, Nothing}}, Missing, Nothing}
end
function PlanetsConnection(; pageInfo, edges = nothing, totalCount = nothing, planets = nothing)
    PlanetsConnection(pageInfo, edges, totalCount, planets)
end
StructTypes.StructType(::Type{PlanetsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{PlanetsConnection}) = true

"""
An edge in a connection.
"""
mutable struct StarshipsEdge
    "The item at the end of the edge"
    node::Union{Starship, Missing, Nothing}
    "A cursor for use in pagination"
    cursor::String
end
function StarshipsEdge(; node = nothing, cursor)
    StarshipsEdge(node, cursor)
end
StructTypes.StructType(::Type{StarshipsEdge}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{StarshipsEdge}) = true

"""
A connection to a list of items.
"""
mutable struct StarshipsConnection
    "Information to aid in pagination."
    pageInfo::PageInfo
    "A list of edges."
    edges::Union{Vector{Union{StarshipsEdge, Missing, Nothing}}, Missing, Nothing}
    "\n  A count of the total number of objects in this connection, ignoring pagination.\n  This allows a client to fetch the first five objects by passing \"5\" as the\n  argument to \"first\", then fetch the total count so it could display \"5 of 83\",\n  for example.\n  "
    totalCount::Union{Int32, Missing, Nothing}
    "\n  A list of all of the objects returned in the connection. This is a convenience\n  field provided for quickly exploring the API; rather than querying for\n  \"{ edges { node } }\" when no edge data is needed, this field can be be used\n  instead. Note that when clients like Relay need to fetch the \"cursor\" field on\n  the edge to enable efficient pagination, this shortcut cannot be used, and the\n  full \"{ edges { node } }\" version should be used instead.\n  "
    starships::Union{Vector{Union{Starship, Missing, Nothing}}, Missing, Nothing}
end
function StarshipsConnection(; pageInfo, edges = nothing, totalCount = nothing, starships = nothing)
    StarshipsConnection(pageInfo, edges, totalCount, starships)
end
StructTypes.StructType(::Type{StarshipsConnection}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{StarshipsConnection}) = true

