_G.LaneCreeps = LaneCreeps or {}

LANE_CREEP_FIRST_SPAWN = 0
LANE_CREEP_SPAWN_DELAY = 30
LANE_CREEP_MELEE_COUNT = 3
LANE_CREEP_RANGED_COUNT = 1
LANE_CREEP_MELEE_OFFSET = -300
LANE_CREEP_RANGED_OFFSET = -650

LANE_CREEP_GOLD_BOUNTY = {
	["npc_dota_creep_goodguys_melee"] = 42,
	["npc_dota_creep_goodguys_ranged"] = 55,
	["npc_dota_creep_badguys_melee"] = 42,
	["npc_dota_creep_badguys_ranged"] = 55,
	["npc_eon_knight_ally"] = 0,
}

function LaneCreeps:Init()
	local good_chest = Entities:FindByName(nil, "treasure_spawn_good"):GetAbsOrigin()
	local good_tower = Entities:FindByName(nil, "good_tower_lane"):GetAbsOrigin()
	local bad_tower = Entities:FindByName(nil, "bad_tower_lane"):GetAbsOrigin()
	local bad_chest = Entities:FindByName(nil, "treasure_spawn_bad"):GetAbsOrigin()
	local lane_center = Entities:FindByName(nil, "eon_stone_spawn"):GetAbsOrigin()

	local good_direction = (good_tower - good_chest):Normalized()
	local bad_direction = (bad_tower - bad_chest):Normalized()

	self.good_path = {}

	table.insert(self.good_path, good_chest)
	table.insert(self.good_path, good_tower)
	table.insert(self.good_path, lane_center)
	table.insert(self.good_path, bad_tower)
	table.insert(self.good_path, bad_chest)

	self.bad_path = {}

	table.insert(self.bad_path, bad_chest)
	table.insert(self.bad_path, bad_tower)
	table.insert(self.bad_path, lane_center)
	table.insert(self.bad_path, good_tower)
	table.insert(self.bad_path, good_chest)

	self.spawn_points = {}

	self.spawn_points[DOTA_TEAM_GOODGUYS] = {}
	self.spawn_points[DOTA_TEAM_GOODGUYS].melee = {}
	self.spawn_points[DOTA_TEAM_GOODGUYS].ranged = {}

	self.spawn_points[DOTA_TEAM_GOODGUYS].ranged[1] = good_chest + good_direction * LANE_CREEP_RANGED_OFFSET

	for i = 1, LANE_CREEP_MELEE_COUNT do
		local angle = -4 + 8 * (i - 1) / (LANE_CREEP_MELEE_COUNT - 1)
		table.insert(self.spawn_points[DOTA_TEAM_GOODGUYS].melee, RotatePosition(good_chest, QAngle(0, angle, 0), good_chest + good_direction * LANE_CREEP_MELEE_OFFSET))
	end

	self.spawn_points[DOTA_TEAM_BADGUYS] = {}
	self.spawn_points[DOTA_TEAM_BADGUYS].melee = {}
	self.spawn_points[DOTA_TEAM_BADGUYS].ranged = {}

	self.spawn_points[DOTA_TEAM_BADGUYS].ranged[1] = bad_chest + bad_direction * LANE_CREEP_RANGED_OFFSET

	for i = 1, LANE_CREEP_MELEE_COUNT do
		local angle = -4 + 8 * (i - 1) / (LANE_CREEP_MELEE_COUNT - 1)
		table.insert(self.spawn_points[DOTA_TEAM_BADGUYS].melee, RotatePosition(bad_chest, QAngle(0, angle, 0), bad_chest + bad_direction * LANE_CREEP_MELEE_OFFSET))
	end

	self.creep_names = {}
	self.creep_names[DOTA_TEAM_GOODGUYS] = {}
	self.creep_names[DOTA_TEAM_GOODGUYS].melee = "npc_dota_creep_goodguys_melee"
	self.creep_names[DOTA_TEAM_GOODGUYS].ranged = "npc_dota_creep_goodguys_ranged"

	self.creep_names[DOTA_TEAM_BADGUYS] = {}
	self.creep_names[DOTA_TEAM_BADGUYS].melee = "npc_dota_creep_badguys_melee"
	self.creep_names[DOTA_TEAM_BADGUYS].ranged = "npc_dota_creep_badguys_ranged"
end

function LaneCreeps:SpawnWave()
	for team, spawn_points in pairs(self.spawn_points) do
		for _, spawn_point in pairs(spawn_points.melee) do
			if team == DOTA_TEAM_GOODGUYS then LaneCreep(team, self.good_path, spawn_point, self.creep_names[team].melee) end
			if team == DOTA_TEAM_BADGUYS then LaneCreep(team, self.bad_path, spawn_point, self.creep_names[team].melee) end
		end
		for _, spawn_point in pairs(spawn_points.ranged) do
			if team == DOTA_TEAM_GOODGUYS then LaneCreep(team, self.good_path, spawn_point, self.creep_names[team].ranged) end
			if team == DOTA_TEAM_BADGUYS then LaneCreep(team, self.bad_path, spawn_point, self.creep_names[team].ranged) end
		end
	end
end

function LaneCreeps:SpawnKnightWave(team)
	for _, spawn_point in pairs(self.spawn_points[team].melee) do
		if team == DOTA_TEAM_GOODGUYS then LaneCreep(team, self.good_path, spawn_point, "npc_eon_knight_ally") end
		if team == DOTA_TEAM_BADGUYS then LaneCreep(team, self.bad_path, spawn_point, "npc_eon_knight_ally") end
	end
end



if LaneCreep == nil then LaneCreep = class({}) end

function LaneCreep:constructor(team, path, location, unit_name)
	self.team = team
	self.path = path
	self.location = location
	self.unit_name = unit_name

	self.unit = CreateUnitByName(self.unit_name, self.location, true, nil, nil, self.team)
	ResolveNPCPositions(self.location, 200)

	self.unit:EmitSound("Creep.Teleport")

	if self.unit_name == "npc_eon_knight_ally" then self.unit:AddNewModifier(self.unit, nil, "modifier_knight_state", {}) end

	self.unit.lane = self

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

function LaneCreep:OnLaneCreepDied(killer, killed_unit)
	local bounty = LANE_CREEP_GOLD_BOUNTY[killed_unit:GetUnitName()]
	if bounty > 0 then LaneCoin(killed_unit:GetAbsOrigin(), bounty, killed_unit:GetTeam()) end
end



if LaneCoin == nil then LaneCoin = class({
	value = 0,
}) end

function LaneCoin:constructor(location, value, team)
	if team == DOTA_TEAM_GOODGUYS then
		self.gold_drop = CreateItem("item_neutral_gold", nil, nil)
	else
		self.gold_drop = CreateItem("item_dragon_drop_arcane", nil, nil)
	end

	self.value = value
	self.team = team

	self.location = location
	self.drop = CreateItemOnPositionForLaunch(location, self.gold_drop)

	if team == DOTA_TEAM_GOODGUYS then
		self.drop:SetRenderColor(50, 255, 50)
		self.drop:SetModelScale(1.4)
	end
	if team == DOTA_TEAM_BADGUYS then
		self.drop:SetRenderColor(255, 50, 50)
		self.drop:SetModelScale(2.5)
	end

	self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
		radius = 170
	}, {
		trigger_team = self.team,
		team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	}, function(units)
		self:OnHeroInRange(units)
	end, {})

	Timers:CreateTimer(GOLD_COIN_DURATION, function()
		if self.gold_drop and self.drop and (not (self.drop:IsNull() or self.gold_drop:IsNull())) then
			self.gold_drop:Destroy()
			self.drop:Destroy()
			self.trigger:Stop()
		end
	end)
end

function LaneCoin:OnHeroInRange(units)
	if units[1] then
		PassiveGold:GiveGoldFromPickup(units[1], self.value)

		self.gold_drop:Destroy()
		self.drop:Destroy()
		self.trigger:Stop()
	end
end