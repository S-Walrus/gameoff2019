local function Color(hex, value, scale)
	if scale == true then
		return {tonumber(string.sub(hex, 2, 3), 16)/256*value, tonumber(string.sub(hex, 4, 5), 16)/256*value, tonumber(string.sub(hex, 6, 7), 16)/256*value, 1}
	else
		return {tonumber(string.sub(hex, 2, 3), 16)/256, tonumber(string.sub(hex, 4, 5), 16)/256, tonumber(string.sub(hex, 6, 7), 16)/256, value or 1}
	end
end
return Color