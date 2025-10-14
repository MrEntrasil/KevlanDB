return function()
	local base = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	math.randomseed(os.time())
	return string.gsub(base, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format("%x", v)
	end)
end
