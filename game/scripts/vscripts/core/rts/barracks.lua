_G.BarracksManager = BarracksManager or {}

CustomGameEventManager:RegisterListener("player_attempted_summon", function(_, event)
	BarracksManager:OnPlayerAttemptSummon(event)
end)

BARRACKS_UNIT_DURATION = 60
BARRACKS_UNIT_TELEPORT_DURATION = 5

UNIT_SPHERE_COSTS = {}

UNIT_SPHERE_COSTS.footman = 100
UNIT_SPHERE_COSTS.archer = 100
UNIT_SPHERE_COSTS.marauder = 200
UNIT_SPHERE_COSTS.reaper = 250
UNIT_SPHERE_COSTS.knight = 500
UNIT_SPHERE_COSTS.golem = 500

BARRACKS_MID = 1
BARRACKS_LEFT = 2
BARRACKS_RIGHT = 3

function BarracksManager:Spawn()
	self.barracks = {}

	self.barracks[DOTA_TEAM_GOODGUYS] = {}
	self.barracks[DOTA_TEAM_BADGUYS] = {}

	self.barracks[DOTA_TEAM_GOODGUYS][BARRACKS_MID] = Barracks(DOTA_TEAM_GOODGUYS, GameManager:GetMapLocation("good_barracks_mid"), BARRACKS_MID)
	self.barracks[DOTA_TEAM_BADGUYS][BARRACKS_MID] = Barracks(DOTA_TEAM_BADGUYS, GameManager:GetMapLocation("bad_barracks_mid"), BARRACKS_MID)

	self.barracks[DOTA_TEAM_GOODGUYS][BARRACKS_LEFT] = Barracks(DOTA_TEAM_GOODGUYS, GameManager:GetMapLocation("good_barracks_left"), BARRACKS_LEFT)
	self.barracks[DOTA_TEAM_BADGUYS][BARRACKS_LEFT] = Barracks(DOTA_TEAM_BADGUYS, GameManager:GetMapLocation("bad_barracks_right"), BARRACKS_LEFT)

	self.barracks[DOTA_TEAM_GOODGUYS][BARRACKS_RIGHT] = Barracks(DOTA_TEAM_GOODGUYS, GameManager:GetMapLocation("good_barracks_right"), BARRACKS_RIGHT)
	self.barracks[DOTA_TEAM_BADGUYS][BARRACKS_RIGHT] = Barracks(DOTA_TEAM_BADGUYS, GameManager:GetMapLocation("bad_barracks_left"), BARRACKS_RIGHT)
end

function BarracksManager:GetBarracks(team, position)
	if self.barracks[team] and self.barracks[team][position] then
		return self.barracks[team][position]
	end

	return nil
end

function BarracksManager:OnGameStart()
	-- for _, team_barracks in pairs(self.barracks) do
	-- 	for _, barracks in pairs(team_barracks) do
	-- 		local player_id = GameManager:GetTeamPlayerID(barracks.team)

	-- 		if player_id then
	-- 			local hero = PlayerResource:GetSelectedHeroEntity(player_id)

	-- 			barracks.unit:SetOwner(hero)
	-- 			barracks.unit:SetControllableByPlayer(player_id, true)
	-- 		end
	-- 	end
	-- end
end

function BarracksManager:OnPlayerAttemptSummon(event)
	if self:IsSummonOnCooldownForPlayer(event.PlayerID, event.unit) then return end

	if EonSpheres:SpendPlayerSpheres(event.PlayerID, UNIT_SPHERE_COSTS[event.unit]) then
		self:SummonUnitForPlayer(event.PlayerID, event.unit)
	else
		EmitAnnouncerSoundForPlayer("upgrade_fail", event.PlayerID)
	end
end

function BarracksManager:IsSummonOnCooldownForPlayer(id, unit)
	return (EonSpheres.cooldowns[id] and EonSpheres.cooldowns[id][unit]) or false
end

function BarracksManager:SummonUnitForPlayer(id, unit)
	local team = PlayerResource:GetTeam(id)
	local hero = PlayerResource:GetSelectedHeroEntity(id)

	local modifier = hero:FindModifierByName("modifier_barracks_state_aura")

	if modifier then
		local barracks_unit = modifier:GetCaster()

		if barracks_unit.barracks then barracks_unit.barracks:SpawnUnitForPlayer(id, unit) end
	end

	EonSpheres:StartUnitCooldownForPlayer(id, unit)
end

function BarracksManager:RefundBarracksUnitCostForPlayer(id, unit)
	EonSpheres:GivePlayerSpheres(id, UNIT_SPHERE_COSTS[unit])
end



if Barracks == nil then Barracks = class({}) end

function Barracks:constructor(team, location, position)
	self.location = location
	self.team = team
	self.position = position

	self.unit = CreateUnitByName("npc_eon_barracks", self.location, true, nil, nil, self.team)
	self.unit.is_barracks = true
	self.unit.barracks = self
end

function Barracks:SpawnUnitForPlayer(id, unit)
	local unit_name = "npc_eon_"..unit
	local lane = LaneCreeps:GetLane(self.team, self.position)
	local spawn_location = lane.spawn_points.ranged + RandomVector(100)

	local lane_creep = LaneCreep(self.team, lane.path, spawn_location, unit_name)

	lane_creep.unit:AddNewModifier(lane_creep.unit, nil, "modifier_kill", {duration = BARRACKS_UNIT_DURATION})
	lane_creep.unit:AddNewModifier(lane_creep.unit, nil, "modifier_barracks_creep_spawn_state", {duration = 0.1})
	lane_creep.unit:AddNewModifier(lane_creep.unit, nil, "modifier_barracks_creep_teleport_wait", {duration = BARRACKS_UNIT_DURATION - BARRACKS_UNIT_TELEPORT_DURATION - 0.1})
	lane_creep.unit:AddNewModifier(lane_creep.unit, nil, "modifier_phased", {duration = 0.1})
	lane_creep.unit.is_barracks_unit = true
	lane_creep.unit.barracks_name = unit

	lane_creep.unit:EmitSound("Barracks.Summon")

	local hero = PlayerResource:GetSelectedHeroEntity(id)

	lane_creep.unit:SetOwner(hero)
	lane_creep.unit:SetControllableByPlayer(id, true)
end

function Barracks:IsDisabled()
	return (self.unit and self.unit:HasModifier("modifier_upgrade_center_disabled")) or false
end