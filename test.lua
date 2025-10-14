local KevlanDB = require("init")
local db = KevlanDB.Generic:new("sla.kvl")
local marcas_collection = db:collection"marcas"

marcas_collection:insert{
	nome = "Intel",
	presta = false
}
marcas_collection:insert{
	nome = "Amd",
	presta = true
}
marcas_collection:insert{
	nome = "Arm",
	presta = true
}
