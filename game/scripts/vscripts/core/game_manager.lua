_G.GameManager = GameManager or {}

function GameManager:Init()
	self.eon_stone_count = self:SpawnEonStones()
end

function GameManager:SpawnEonStones()
	local spawn_locations = Entities:FindAllByName("eon_stone_spawn")

	for _, spawn_location in pairs(spawn_locations) do
		CreateItemOnPositionForLaunch(spawn_location:GetAbsOrigin(), CreateItem("item_eon_stone", nil, nil))
	end

	return #spawn_locations
end

function GameManager:GetEonStoneCount()
	return self.eon_stone_count or nil
end

function GameManager:ConsumeEonStone()
	self.eon_stone_count = self.eon_stone_count - 1

	if self.eon_stone_count <= 0 then
		self:ResetPlayerPositions()
		self.eon_stone_count = self:SpawnEonStones()
	end
end

function GameManager:ResetPlayerPositions()
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		hero:RespawnHero(false, false)
		hero:Stop()
	end
end