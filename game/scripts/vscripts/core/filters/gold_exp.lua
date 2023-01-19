function Filters:GoldFilter(keys)
	keys.gold = 1 * keys.gold

	return true
end

function Filters:ExpFilter(keys)
	keys.experience = 1 * keys.experience

	return true
end