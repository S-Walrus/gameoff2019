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

utils.remove = remove
return utils