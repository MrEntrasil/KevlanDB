local KevlanDB = require"storage.KV"
local db = KevlanDB:new()
local carros_cll = db:collection("carros")

carros_cll:insert({ nome = "Tesla" })
local result = carros_cll:find_where{
	nome = "Tesla"
}

print(#result)
