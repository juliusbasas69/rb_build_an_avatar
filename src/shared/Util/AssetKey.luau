
local AssetKey = {}

function AssetKey:Create(assetId, grade, mutation)
	return string.format("%s_%s_%s", tostring(assetId), grade, mutation)
end

function AssetKey:Parse(key)
	local assetId, grade, mutation = key:match("^(.-)_(.-)_(.+)$")

	return {
		AssetId = assetId,
		Grade = grade,
		Mutation = mutation
	}
end

function AssetKey:Equals(key1, key2)
	return key1 == key2
end

return AssetKey