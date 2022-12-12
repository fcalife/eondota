_G.RuneSpawners = RuneSpawners or {}

RUNE_TYPE_RED = 1
RUNE_TYPE_GREEN = 2

RUNE_NAME = {}

RUNE_NAME[RUNE_TYPE_RED] = "item_red_rune"
RUNE_NAME[RUNE_TYPE_GREEN] = "item_green_rune"

function RuneSpawners:Init()
	self.rune_spawners = {}

	for _, spawn_point in pairs(Entities:FindAllByName("sphere_spawn")) do
		table.insert(self.rune_spawners, RuneSpawner(spawn_point:GetAbsOrigin(), RUNE_TYPE_RED))
	end
end

function RuneSpawners:OnInitializeRound()
	for _, spawner in pairs(self.rune_spawners) do
		spawner:Spawn()
	end
end



if RuneSpawner == nil then RuneSpawner = class({
	location = Vector(0, 0, 0),
	rune_type = RUNE_TYPE_RED
}) end

function RuneSpawner:constructor(location, rune_type)
	self.location = location or self.location
	self.rune_type = rune_type or self.rune_type
end

function RuneSpawner:Spawn()
	if self.rune and (not self.rune:IsNull()) and self.rune_container and (not self.rune_container:IsNull()) then return end

	self.rune = CreateItem("item_sphere", nil, nil)
	self.rune_container = CreateItemOnPositionForLaunch(self.location, self.rune)
end