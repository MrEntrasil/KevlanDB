local os = require"os"
local io = require"io"
local Collection = require"storage.collection"
local FileReader = require"storage.filereader"

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

function KV:new(filename, options)
	local obj = setmetatable({
			version = "1.0",
			filename = filename or "kv_store.db",
			collections = {},
			reader = FileReader:new(filename or "kv_store.db")
		}, self)
	obj:load()
	return obj
end

function KV:load()
	local result = self.reader:parse()
	for _, dat in ipairs(result.data) do
		local collection, uuid, data = dat[1], dat[2], dat[3]
		if not self.collections[collection] then
			self.collections[collection] = {}
		end
		self.collections[collection][uuid] = decode_document(data)
	end
	self.created = result.headers.created or os.time()
	return true
end

function KV:save()
	local file = io.open(self.filename, "wb")
	if file then
		file:write"[HEADER]\n"
		file:write("db: KVDB "..self.version.."\n")
		file:write("created: "..self.created.."\n")
		file:write("modified: "..os.time().."\n")
		file:write"[DATA]\n"
		for collname, collection in pairs(self.collections) do
			print("Colecao: "..collname)
			for uuid, doc in pairs(collection) do
				print("UUID: "..uuid, "DOC: "..tostring(doc))
				file:write(string.format("%s|%s|%s\n", collname, uuid, encode_document(doc)))
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
