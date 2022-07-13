function Filters:GoldFilter(keys)
	table.deepprint(keys)
	keys.gold = 1.5 * keys.gold

	return true
end

function Filters:ExpFilter(keys)
	table.deepprint(keys)
	keys.experience = 1.5 * keys.experience

	return true
end