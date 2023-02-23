_G.LaneCreeps = LaneCreeps or {}

LANE_CREEP_FIRST_SPAWN = 0
LANE_CREEP_SPAWN_DELAY = 30
LANE_CREEP_MELEE_COUNT = 3
LANE_CREEP_RANGED_COUNT = 1
LANE_CREEP_MELEE_OFFSET = 450
LANE_CREEP_RANGED_OFFSET = 200
LANE_CREEP_MELEE_SPAWN_LENGTH = 500



function LaneCreeps:Init()
	local good_nexus = Entities:FindByName(nil, "good_nexus"):GetAbsOrigin()
	local bad_nexus = Entities:FindByName(nil, "bad_nexus"):GetAbsOrigin()
	local lane_center = Vector(0, 0, 128)

	local good_direction = (lane_center - good_nexus):Normalized()
	local bad_direction = (lane_center - bad_nexus):Normalized()



	self.creep_paths = {}
	self.creep_paths[DOTA_TEAM_GOODGUYS] = {}

	table.insert(self.creep_paths[DOTA_TEAM_GOODGUYS], bad_nexus)

	self.creep_paths[DOTA_TEAM_BADGUYS] = {}

	table.insert(self.creep_paths[DOTA_TEAM_BADGUYS], good_nexus)



	self.spawn_points = {}

	self.spawn_points[DOTA_TEAM_GOODGUYS] = {}
	self.spawn_points[DOTA_TEAM_GOODGUYS].melee = {}
	self.spawn_points[DOTA_TEAM_GOODGUYS].ranged = {}

	self.spawn_points[DOTA_TEAM_GOODGUYS].ranged[1] = good_nexus + good_direction * LANE_CREEP_RANGED_OFFSET

	for i = 1, LANE_CREEP_MELEE_COUNT do
		local offset_x = LANE_CREEP_MELEE_SPAWN_LENGTH * ((i - 1) / (LANE_CREEP_MELEE_COUNT - 1) - 0.5)

		table.insert(self.spawn_points[DOTA_TEAM_GOODGUYS].melee, good_nexus + good_direction * LANE_CREEP_MELEE_OFFSET + Vector(offset_x, 0, 0))
	end

	self.spawn_points[DOTA_TEAM_BADGUYS] = {}
	self.spawn_points[DOTA_TEAM_BADGUYS].melee = {}
	self.spawn_points[DOTA_TEAM_BADGUYS].ranged = {}

	self.spawn_points[DOTA_TEAM_BADGUYS].ranged[1] = bad_nexus + bad_direction * LANE_CREEP_RANGED_OFFSET

	for i = 1, LANE_CREEP_MELEE_COUNT do
		local offset_x = LANE_CREEP_MELEE_SPAWN_LENGTH * ((i - 1) / (LANE_CREEP_MELEE_COUNT - 1) - 0.5)

		table.insert(self.spawn_points[DOTA_TEAM_BADGUYS].melee, bad_nexus + bad_direction * LANE_CREEP_MELEE_OFFSET + Vector(offset_x, 0, 0))
	end

	self.creep_names = {}
	self.creep_names[DOTA_TEAM_GOODGUYS] = {}
	self.creep_names[DOTA_TEAM_GOODGUYS].melee = "npc_dota_creep_goodguys_melee"
	self.creep_names[DOTA_TEAM_GOODGUYS].ranged = "npc_dota_creep_goodguys_ranged"

	self.creep_names[DOTA_TEAM_BADGUYS] = {}
	self.creep_names[DOTA_TEAM_BADGUYS].melee = "npc_dota_creep_badguys_melee"
	self.creep_names[DOTA_TEAM_BADGUYS].ranged = "npc_dota_creep_badguys_ranged"

	self.magic_creep_research = {}
	self.magic_creep_research[DOTA_TEAM_GOODGUYS] = false
	self.magic_creep_research[DOTA_TEAM_BADGUYS] = false
end

function LaneCreeps:ResearchMagicCreep(team)
end

function LaneCreeps:SpawnWave()
	for team, spawn_points in pairs(self.spawn_points) do
		NexusManager:GetNexus(team).unit:EmitSound("Creep.Teleport")

		for _, spawn_point in pairs(spawn_points.ranged) do
			LaneCreep(team, self.creep_paths[team], spawn_point, self.creep_names[team].ranged)
		end
		for _, spawn_point in pairs(spawn_points.melee) do
			LaneCreep(team, self.creep_paths[team], spawn_point, self.creep_names[team].melee)
		end
	end
end

function LaneCreeps:OnGameStart()
	Timers:CreateTimer(LANE_CREEP_FIRST_SPAWN, function()
		if GameManager:GetGamePhase() == GAME_STATE_BATTLE then
			LaneCreeps:SpawnWave()

			return LANE_CREEP_SPAWN_DELAY
		end
	end)
end



if LaneCreep == nil then LaneCreep = class({}) end

function LaneCreep:constructor(team, path, location, unit_name)
	self.team = team
	self.path = path
	self.location = location
	self.unit_name = unit_name

	self.unit = CreateUnitByName(self.unit_name, self.location, true, nil, nil, self.team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_lane_creep_state", {})
	self.unit.is_lane_creep = true

	ResolveNPCPositions(self.location, 300)

	Timers:CreateTimer(0.5, function()
		local unit_id = self.unit:entindex()

		for _, destination in ipairs(self.path) do
			ExecuteOrderFromTable({
				unitIndex = unit_id,
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = destination,
				Queue = true
			})
		end
	end)
end



-- if LaneCoin == nil then LaneCoin = class({
-- 	value = 0,
-- }) end

-- function LaneCoin:constructor(location, value, team)
-- 	if team == DOTA_TEAM_GOODGUYS then
-- 		self.gold_drop = CreateItem("item_neutral_gold", nil, nil)
-- 	else
-- 		self.gold_drop = CreateItem("item_dragon_drop_arcane", nil, nil)
-- 	end

-- 	self.value = value
-- 	self.team = team

-- 	self.location = location
-- 	self.drop = CreateItemOnPositionForLaunch(location, self.gold_drop)

-- 	if team == DOTA_TEAM_GOODGUYS then
-- 		self.drop:SetRenderColor(50, 255, 50)
-- 		self.drop:SetModelScale(1.4)
-- 	end
-- 	if team == DOTA_TEAM_BADGUYS then
-- 		self.drop:SetRenderColor(255, 50, 50)
-- 		self.drop:SetModelScale(2.5)
-- 	end

-- 	self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
-- 		radius = 170
-- 	}, {
-- 		trigger_team = self.team,
-- 		team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
-- 		unit_filter = DOTA_UNIT_TARGET_HERO,
-- 		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
-- 	}, function(units)
-- 		self:OnHeroInRange(units)
-- 	end, {})

-- 	Timers:CreateTimer(GOLD_COIN_DURATION, function()
-- 		if self.gold_drop and self.drop and (not (self.drop:IsNull() or self.gold_drop:IsNull())) then
-- 			self.gold_drop:Destroy()
-- 			self.drop:Destroy()
-- 			self.trigger:Stop()
-- 		end
-- 	end)
-- end

-- function LaneCoin:OnHeroInRange(units)
-- 	if units[1] then
-- 		units[1]:ModifyGold(self.value, false, DOTA_ModifyGold_CreepKill)

-- 		local player = units[1]:GetPlayerOwner()
-- 		if player then SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, units[1], self.value, nil) end

-- 		self.gold_drop:Destroy()
-- 		self.drop:Destroy()
-- 		self.trigger:Stop()
-- 	end
-- end