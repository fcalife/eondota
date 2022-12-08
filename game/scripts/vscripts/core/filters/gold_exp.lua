function Filters:GoldFilter(keys)
	keys.gold = 2 * keys.gold

	return true
end

function Filters:ExpFilter(keys)
	keys.experience = 2 * keys.experience

	return true
end