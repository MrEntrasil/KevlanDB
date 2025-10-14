local io = require"io"
local FileReader = {}
FileReader.__index = FileReader

local function split(str, delimiter)
	delimiter = delimiter or " "
	local result = {}

	for part in str:gmatch("([^" .. delimiter .. "]+)") do
		table.insert(result, part)
	end
	return result
end

function FileReader:new(filename)
	local obj = setmetatable({
			filename = filename,
			lines = {}
		}, FileReader)
	obj:load()
	return obj
end

function FileReader:load()
	local file = io.open(self.filename, "r")
	if not file then
		return false, "[KevlanDB][FileReader]: Couldnt load object of '"..self.filename.."'"
	end
	self.lines = {}
	for line in file:lines() do
		table.insert(self.lines, line)
	end
	file:close()
	return true
end

function FileReader:parse()
	local actualpos = ""
	local headers, datas = {}, {}
	local current_section = ""

	for _, line in ipairs(self.lines) do
		line = line:gsub("^%s*(.-)%s*$", "%1")
		if line == "[HEADER]" then
			current_section = "header"
		elseif line == "[DATA]" then
			current_section = "data"
		elseif current_section == "header" and line ~= "" then
			local splited = split(line, ":")
			local key, value = splited[1], splited[2]
			headers[key] = value
		elseif current_section == "data" and line ~= "" then
			table.insert(datas, split(line, "|"))
		end
	end
	return {
		data = datas,
		headers = headers
	}
end

return FileReader
