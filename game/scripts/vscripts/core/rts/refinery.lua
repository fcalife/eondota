_G.Refineries = Refineries or {}

HARVESTER_COUNT = {}
HARVESTER_COUNT[1] = 3
HARVESTER_COUNT[2] = 5
HARVESTER_COUNT[3] = 7

REFINERY_LEFT = 1
REFINERY_RIGHT = 2

EON_SPHERES_PER_HIT = (IsInToolsMode() and 50) or 1

function Refineries:Spawn()
	self.refinery_spawn_offset = {}
	self.refinery_spawn_offset[DOTA_TEAM_GOODGUYS] = Vector(0, 200, 0)
	self.refinery_spawn_offset[DOTA_TEAM_BADGUYS] = Vector(0, -200, 0)

	self.refineries = {}

	self.refineries[DOTA_TEAM_GOODGUYS] = {}
	self.refineries[DOTA_TEAM_BADGUYS] = {}

	self.refineries[DOTA_TEAM_GOODGUYS][MINERAL_PATCH_LEFT] = Refinery(DOTA_TEAM_GOODGUYS, REFINERY_LEFT, GameManager:GetMapLocation("good_refinery_left"))
	self.refineries[DOTA_TEAM_GOODGUYS][MINERAL_PATCH_RIGHT] = Refinery(DOTA_TEAM_GOODGUYS, REFINERY_RIGHT, GameManager:GetMapLocation("good_refinery_right"))

	self.refineries[DOTA_TEAM_BADGUYS][MINERAL_PATCH_LEFT] = Refinery(DOTA_TEAM_BADGUYS, REFINERY_LEFT, GameManager:GetMapLocation("bad_refinery_left"))
	self.refineries[DOTA_TEAM_BADGUYS][MINERAL_PATCH_RIGHT] = Refinery(DOTA_TEAM_BADGUYS, REFINERY_RIGHT, GameManager:GetMapLocation("bad_refinery_right"))
end

function Refineries:GetRefinery(team, location)
	if self.refineries[team] and self.refineries[team][location] then
		return self.refineries[team][location]
	end

	return nil
end

function Refineries:OnGameStart()
	for _, team_refineries in pairs(self.refineries) do
		for _, refinery in pairs(team_refineries) do
			for i = 1, HARVESTER_COUNT[1] do
				refinery:SpawnHarvester()
			end
		end
	end
end



if Refinery == nil then Refinery = class({}) end

function Refinery:constructor(team, side, location)
	self.location = location
	self.team = team
	self.side = side
	self.spawn_position = self.location + Refineries.refinery_spawn_offset[team]
	self.max_harvesters = HARVESTER_COUNT[1]

	self.unit = CreateUnitByName("npc_eon_refinery", self.location, true, nil, nil, self.team)
	self.unit.is_refinery = true
	self.unit.refinery = self
end

function Refinery:GetHarvesterCount()
	local allies = FindUnitsInRadius(
		self.team,
		self.location,
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	local harvester_count = 0

	for _, ally in pairs(allies) do
		if ally.is_harvester and ally.refinery_side == self.side then harvester_count = harvester_count + 1 end
	end

	return harvester_count
end

function Refinery:ShouldBeSpawningHarvesters()
	return (self:GetHarvesterCount() < self.max_harvesters)
end

function Refinery:SpawnHarvester()
	local harvester = CreateUnitByName("npc_eon_harvester", self.spawn_position, true, nil, nil, self.team)
	harvester.is_harvester = true
	harvester.refinery_side = self.side

	local harvester_ability = harvester:FindAbilityByName("harvester_harvest")
	if harvester_ability then harvester_ability:SetLevel(1) end
end

function Refinery:UpgradeHarvesters(level)
	self.max_harvesters = HARVESTER_COUNT[level]
end