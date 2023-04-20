_G.Refineries = Refineries or {}

HARVESTER_COUNT = {}
HARVESTER_COUNT[1] = 3
HARVESTER_COUNT[2] = 5
HARVESTER_COUNT[3] = 7

EON_SPHERES_PER_HIT = (IsInToolsMode() and 100) or 1

function Refineries:Spawn()
	self.refineries = {}

	self.refineries[DOTA_TEAM_GOODGUYS] = Refinery(DOTA_TEAM_GOODGUYS, Entities:FindByName(nil, "good_refinery"):GetAbsOrigin())
	self.refineries[DOTA_TEAM_BADGUYS] = Refinery(DOTA_TEAM_BADGUYS, Entities:FindByName(nil, "bad_refinery"):GetAbsOrigin())
end

function Refineries:GetRefinery(team)
	return self.refineries[team] or nil
end

function Refineries:OnGameStart()
	for _, refinery in pairs(self.refineries) do
		for i = 1, HARVESTER_COUNT[1] do
			refinery:SpawnHarvester()
		end
	end
end



if Refinery == nil then Refinery = class({}) end

function Refinery:constructor(team, location)
	self.location = location
	self.team = team
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
		if ally.is_harvester then harvester_count = harvester_count + 1 end
	end

	return harvester_count
end

function Refinery:ShouldBeSpawningHarvesters()
	return (self:GetHarvesterCount() < self.max_harvesters)
end

function Refinery:SpawnHarvester()
	local harvester = CreateUnitByName("npc_eon_harvester", self.location + RandomVector(200), true, nil, nil, self.team)
	harvester.is_harvester = true

	local harvester_ability = harvester:FindAbilityByName("harvester_harvest")
	if harvester_ability then harvester_ability:SetLevel(1) end
end

function Refinery:UpgradeHarvesters(level)
	self.max_harvesters = HARVESTER_COUNT[level]
end