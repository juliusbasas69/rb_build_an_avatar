local NumberUtil = {}

local SUFFIXES = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"De",
}

function NumberUtil.FormatMoney(amount: number): string
	if amount < 1000 then
		return tostring(math.floor(amount))
	end

	local index = math.floor(math.log(amount, 1000))
	index = math.min(index, #SUFFIXES - 1)

	local value = amount / (1000 ^ index)

	-- Prevent values like 999.999M -> 1000.00M
	value = math.floor(value * 100) / 100

	return string.format("%.2f%s", value, SUFFIXES[index + 1])
		:gsub("%.?0+([A-Za-z]+)$", "%1")
end

return NumberUtil