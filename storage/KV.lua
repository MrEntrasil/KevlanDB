local os = require"os"
local io = require"io"
local uuid = require"uuid"
local Collection = require"storage.collection"

local function split(str, delimiter)
	delimiter = delimiter or " "
	local result = {}

	for part in str:gmatch("([^" .. delimiter .. "]+)") do
		table.insert(result, part)
	end
	return result
end

local function decode_document(doc)
	local parts = {}
	for key, value in doc:gmatch"([%w_]+)%s*=%s*([^;]+)" do
		key = key:gsub("^%s*(.-)%s*$", "%1")
		value = value:gsub("^%s*(.-)%s*$", "%1")
		if value:match'^".*"$' then
			parts[key] = value:sub(2, -2)
		elseif value:match"^'.*'$" then
			parts[key] = value:sub(2, -2)
		elseif value:match"^%d+$" then
			parts[key] = tonumber(value)
		elseif value:match"^%d+%.%d+$" then
			parts[key] = tonumber(value)
		elseif value == "true" then
			parts[key] = true
		elseif value == "false" then
			parts[key] = false
		else
			parts[key] = value
		end
	end
	return parts
end

local function encode_document(doc)
	local parts = {}
	for key, value in pairs(doc) do
		if type(value) == "string" then
			table.insert(parts, string.format('%s="%s"', key, value:gsub('"', '\\"')))
		elseif type(value) == "boolean" then
			table.insert(parts, string.format("%s=%s", key, tostring(value)))
		elseif type(value) == "number" then
			table.insert(parts, string.format("%s=%s", key, tostring(value)))
		elseif type(value) == "table" then
			if #value > 0 then
				local arr = {}
				for i, item in ipairs(value) do
					if type(item) == "string" then
						table.insert(arr, string.format('"%s"', item))
					else
						table.insert(arr, tostring(item))
					end
				end
				table.insert(parts, string.format("%s=[%s]", key, table.concat(arr, ",")))
			end
		end
	end

	return table.concat(parts, ";")
end

local KV = {}
KV.__index = KV

function KV:new(filename)
	local obj = setmetatable({
			filename = filename or "kv_store.db",
			collections = {}
		}, self)
	obj:load()
	return obj
end

function KV:load()
	local file = io.open(self.filename, "r")
	if file then
		for line in file:lines() do
			local splited = split(line, "|")
			local collection, uuid, data = splited[1], splited[2], splited[3]
			if not collection or not uuid or not data then
				print"[ERROR]: not collection or not uuid or not data found!"
				os.exit(1)
			end
			if not self.collections[collection] then
				self.collections[collection] = {}
			end
			self.collections[collection][uuid] = decode_document(data)
		end
		file:close()
	else
		return false, "[WARNING]: Couldnt load object of '"..self.filename.."'"
	end
	return true
end

function KV:save()
	local file = io.open(self.filename, "w")
	if file then
		for collname, collection in pairs(self.collections) do
			for id, doc in pairs(collection) do
				file:write(string.format("%s|%s|%s\n", collname, id, encode_document(doc)))
			end
		end
		file:close()
	else
		return false, "[WARNING]: Couldnt save object of '"..self.filename.."'"
	end
	return true
end

function KV:collection(name)
	if not self.collections[name] then
		self.collections[name] = {}
	end
	return setmetatable({
			db = self,
			name = name,
			data = self.collections[name]
		}, Collection)
end

return KV
