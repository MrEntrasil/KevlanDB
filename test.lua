local KevlanDB = require("init")
local db = KevlanDB.Generic:new("sla.kvl")
local marcas_collection = db:collection"marcas"

marcas_collection:flush()
