local Collection = {}
Collection.__index = Collection

function Collection:insert(document)
	local newid = #self.data+1
	document._id = newid
	table.insert(self.data, document)
	self.db:save()
end

return Collection
