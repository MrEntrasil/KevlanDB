local uuid = require"uuid"
local Collection = {}
Collection.__index = Collection

function Collection:insert(document)
	document._uuid = uuid()
	self.data[document._uuid] = document
	self.db:save()
	return document
end

function Collection:find(uuid)
	local document = self.data[uuid]
	if document then
		return document
	end
	return false
end

function Collection:find_where(query)
	local results = {}
	for _, document in pairs(self.data) do
		local t = true
		for key, value in pairs(query) do
			if document[key] ~= value then
				t = false
				break
			end
		end
		if t then table.insert(results, document) end
	end
	return results
end

function Collection:find(uuid)
	local document = self.data[uuid]
	if document then
		return document
	end
	return false
end

return Collection
