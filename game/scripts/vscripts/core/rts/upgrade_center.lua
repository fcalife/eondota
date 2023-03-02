_G.UpgradeCenters = UpgradeCenters or {}

CustomGameEventManager:RegisterListener("player_attempted_upgrade", function(_, event)
	UpgradeCenters:OnPlayerAttemptUpgrade(event)
end)

UPGRADE_CENTER_DISABLE_DURATION = 45

UPGRADE_SPHERE_COSTS = {}

UPGRADE_SPHERE_COSTS.economy_1 = 300
UPGRADE_SPHERE_COSTS.creeps_1 = 300
UPGRADE_SPHERE_COSTS.nexus_1 = 400
UPGRADE_SPHERE_COSTS.tech_1 = 500
UPGRADE_SPHERE_COSTS.economy_2 = 400
UPGRADE_SPHERE_COSTS.creeps_2 = 600
UPGRADE_SPHERE_COSTS.nexus_2 = 700
UPGRADE_SPHERE_COSTS.tech_2 = 1000
UPGRADE_SPHERE_COSTS.creeps_3 = 800

function UpgradeCenters:Spawn()
	self.upgrade_centers = {}

	self.upgrade_centers[DOTA_TEAM_GOODGUYS] = UpgradeCenter(DOTA_TEAM_GOODGUYS, Entities:FindByName(nil, "good_upgrade_center"):GetAbsOrigin())
	self.upgrade_centers[DOTA_TEAM_BADGUYS] = UpgradeCenter(DOTA_TEAM_BADGUYS, Entities:FindByName(nil, "bad_upgrade_center"):GetAbsOrigin())
end

function UpgradeCenters:GetUpgradeCenter(team)
	return self.upgrade_centers[team] or nil
end

function UpgradeCenters:OnGameStart()
	-- for _, upgrade_center in pairs(self.upgrade_centers) do
	-- 	local player_id = GameManager:GetTeamPlayerID(upgrade_center.team)

	-- 	if player_id then
	-- 		local hero = PlayerResource:GetSelectedHeroEntity(player_id)

	-- 		upgrade_center.unit:SetOwner(hero)
	-- 		upgrade_center.unit:SetControllableByPlayer(player_id, true)
	-- 	end
	-- end
end

function UpgradeCenters:OnPlayerAttemptUpgrade(event)
	if EonSpheres:SpendPlayerSpheres(event.PlayerID, UPGRADE_SPHERE_COSTS[event.upgrade]) then
		self:PerformUpgradeForTeam(event.upgrade, PlayerResource:GetTeam(event.PlayerID))
	else
		EmitAnnouncerSoundForPlayer("upgrade_fail", event.PlayerID)
	end
end

function UpgradeCenters:PerformUpgradeForTeam(upgrade, team)
	EmitAnnouncerSoundForTeam("upgrade_success", team)

	local upgrade_center = self:GetUpgradeCenter(team)
	local ability = upgrade_center.unit:FindAbilityByName("upgrade_"..upgrade)

	if ability then
		ability:OnSpellStart()
		ability:SetActivated(false)
		ability:SetHidden(true)
	end

	EonSpheres:RemoveTeamUpgradeOption(team, upgrade)
end



if UpgradeCenter == nil then UpgradeCenter = class({}) end

function UpgradeCenter:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_eon_upgrade_center", self.location, true, nil, nil, self.team)
	self.unit.is_upgrade_center = true
	self.unit.upgrade_center = self
end

function UpgradeCenter:GetHarvesterCount()
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

function UpgradeCenter:ShouldBeSpawningHarvesters()
	return (self:GetHarvesterCount() < self.max_harvesters)
end

function UpgradeCenter:SpawnHarvester()
	local harvester = CreateUnitByName("npc_eon_harvester", self.location + RandomVector(200), true, nil, nil, self.team)
	harvester.is_harvester = true

	local harvester_ability = harvester:FindAbilityByName("harvester_harvest")
	if harvester_ability then harvester_ability:SetLevel(1) end
end