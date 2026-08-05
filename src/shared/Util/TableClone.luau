local TableClone = {}

function TableClone:Shallow(tbl)
	return table.clone(tbl)
end

function TableClone:Deep(tbl)
	local clone = {}

	for key, value in pairs(tbl) do
		if type(value) == "table" then
			clone[key] = self:Deep(value)
		else
			clone[key] = value
		end
	end

	return clone
end

return TableClone