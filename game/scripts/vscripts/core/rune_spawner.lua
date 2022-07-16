_G.RuneSpawner = RuneSpawner or {}

function RuneSpawner:Init()
	self.bounty_rune_spots = {}

	for _, bounty_rune_spawner in pairs(Entities:FindAllByName("bounty_rune_spawner")) do
		table.insert(self.bounty_rune_spots, RuneSpot(bounty_rune_spawner:GetAbsOrigin()))
	end
end

function RuneSpawner:SpawnBountyRunes()
	for _, spot in pairs(self.bounty_rune_spots) do
		spot:TrySpawnBountyRune()
	end
end



if RuneSpot == nil then RuneSpot = class({}) end

function RuneSpot:constructor(location)
	self.location = location
end

function RuneSpot:TrySpawnBountyRune()
	if self.rune and (not self.rune:IsNull()) and self.rune.GetContainedItem and self.rune:GetContainedItem() then
		return
	else
		self.rune = CreateItemOnPositionForLaunch(self.location, CreateItem("item_bounty_rune", nil, nil))
	end
end