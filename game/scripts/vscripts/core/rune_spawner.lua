_G.RuneSpawner = RuneSpawner or {}

function RuneSpawner:Init()
	self.bounty_rune_spots = {}

	for _, bounty_rune_spawner in pairs(Entities:FindAllByName("bounty_rune_spawner")) do
		table.insert(self.bounty_rune_spots, bounty_rune_spawner:GetAbsOrigin())
	end
end

function RuneSpawner:SpawnAllBountyRunes()
	for _, spot in pairs(self.bounty_rune_spots) do
		CreateItemOnPositionForLaunch(spot, CreateItem("item_bounty_rune", nil, nil))
	end
end

function RuneSpawner:SpawnBountyRune(location)
	CreateItemOnPositionForLaunch(location, CreateItem("item_bounty_rune", nil, nil))
end