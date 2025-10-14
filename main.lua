local KevlanDB = require"storage/KV"
local db = KevlanDB:new("teste.db")
local carros_cll = db:collection("carros")
carros_cll:insert({ preco = 500, nome = "Tesla" })
