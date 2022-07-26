function Filters:GoldFilter(keys)
	keys.gold = 1.0 * keys.gold

	return true
end

function Filters:ExpFilter(keys)
	keys.experience = 1.0 * keys.experience

	return true
end