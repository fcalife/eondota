function Filters:GoldFilter(keys)
	keys.gold = 1.8 * keys.gold

	return true
end

function Filters:ExpFilter(keys)
	keys.experience = 1.8 * keys.experience

	return true
end