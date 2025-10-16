return function()
	local base = "xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx"
	local chars = "0123456789abcdef"
	return string.gsub(base, "[xy]", function(c)
		math.randomseed(os.time()+os.clock()*1000000)
		if c == "x" then
			return chars:sub(math.random(1, 16), math.random(1, 16))
		else
			return chars:sub(math.random(9, 12), math.random(9, 12))
		end
	end)
end
