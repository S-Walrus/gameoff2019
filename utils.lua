local utils = {}

local function remove(tbl, element)
	for i, item in ipairs(tbl) do
		if item == element then
			table.remove(tbl, i)
			return true
		end
	end
	return false
end

local function stop_tweens()
	for i, item in ipairs(flux.to({}, 0, {}).parent) do
		item:stop()
	end
end

utils.remove = remove
utils.stop_tweens = stop_tweens
return utils