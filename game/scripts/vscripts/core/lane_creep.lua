_G.LaneCreeps = LaneCreeps or {}

LANE_CREEP_FIRST_SPAWN = 0
LANE_CREEP_RESPAWN_DELAY = 30
LANE_CREEP_MELEE_COUNT = 5
LANE_CREEP_RANGED_COUNT = 2
LANE_CREEP_MELEE_OFFSET = -450
LANE_CREEP_RANGED_OFFSET = -700
LANE_CREEP_SIEGE_OFFSET = -975
LANE_CREEP_MELEE_SPAWN_DISTANCE = 550
LANE_CREEP_RANGED_SPAWN_DISTANCE = 225

function LaneCreeps:Init()
	local good_nexus = Entities:FindByName(nil, "radiant_nexus"):GetAbsOrigin()
	local bad_nexus = Entities:FindByName(nil, "dire_nexus"):GetAbsOrigin()
	local lane_center = Vector(0, 0, 128)

	local good_direction = (lane_center - good_nexus):Normalized()
	local bad_direction = (lane_center - bad_nexus):Normalized()

	local good_normal = RotatePosition(Vector(0, 0, 0), QAngle(0, 90, 0), Vector(0, 0, 0) + 100 * good_direction):Normalized()
	local bad_normal = RotatePosition(Vector(0, 0, 0), QAngle(0, 90, 0), Vector(0, 0, 0) + 100 * bad_direction):Normalized()

	self.good_path = {}

	table.insert(self.good_path, good_nexus)
	table.insert(self.good_path, lane_center)
	table.insert(self.good_path, bad_nexus)

	self.bad_path = {}

	table.insert(self.bad_path, bad_nexus)
	table.insert(self.bad_path, lane_center)
	table.insert(self.bad_path, good_nexus)

	self.spawn_points = {}

	self.spawn_points[DOTA_TEAM_GOODGUYS] = {}
	self.spawn_points[DOTA_TEAM_GOODGUYS].melee = {}
	self.spawn_points[DOTA_TEAM_GOODGUYS].ranged = {}
	self.spawn_points[DOTA_TEAM_GOODGUYS].siege = {}

	if LANE_CREEP_RANGED_COUNT > 1 then
		for i = 1, LANE_CREEP_RANGED_COUNT do
			self.spawn_points[DOTA_TEAM_GOODGUYS].ranged[i] = good_nexus + good_direction * LANE_CREEP_RANGED_OFFSET + (-0.5 + (i - 1) / (LANE_CREEP_RANGED_COUNT - 1)) * good_normal * LANE_CREEP_RANGED_SPAWN_DISTANCE
		end
	else
		self.spawn_points[DOTA_TEAM_GOODGUYS].ranged[1] = good_nexus + good_direction * LANE_CREEP_RANGED_OFFSET
	end

	if LANE_CREEP_MELEE_COUNT > 1 then
		for i = 1, LANE_CREEP_MELEE_COUNT do
			self.spawn_points[DOTA_TEAM_GOODGUYS].melee[i] = good_nexus + good_direction * LANE_CREEP_MELEE_OFFSET + (-0.5 + (i - 1) / (LANE_CREEP_MELEE_COUNT - 1)) * good_normal * LANE_CREEP_MELEE_SPAWN_DISTANCE
		end
	else
		self.spawn_points[DOTA_TEAM_GOODGUYS].ranged[1] = good_nexus + good_direction * LANE_CREEP_MELEE_OFFSET
	end

	self.spawn_points[DOTA_TEAM_GOODGUYS].siege[1] = good_nexus + good_direction * LANE_CREEP_SIEGE_OFFSET


	self.spawn_points[DOTA_TEAM_BADGUYS] = {}
	self.spawn_points[DOTA_TEAM_BADGUYS].melee = {}
	self.spawn_points[DOTA_TEAM_BADGUYS].ranged = {}
	self.spawn_points[DOTA_TEAM_BADGUYS].siege = {}

	if LANE_CREEP_RANGED_COUNT > 1 then
		for i = 1, LANE_CREEP_RANGED_COUNT do
			self.spawn_points[DOTA_TEAM_BADGUYS].ranged[i] = bad_nexus + bad_direction * LANE_CREEP_RANGED_OFFSET + (-0.5 + (i - 1) / (LANE_CREEP_RANGED_COUNT - 1)) * bad_normal * LANE_CREEP_RANGED_SPAWN_DISTANCE
		end
	else
		self.spawn_points[DOTA_TEAM_BADGUYS].ranged[1] = bad_nexus + bad_direction * LANE_CREEP_RANGED_OFFSET
	end

	if LANE_CREEP_MELEE_COUNT > 1 then
		for i = 1, LANE_CREEP_MELEE_COUNT do
			self.spawn_points[DOTA_TEAM_BADGUYS].melee[i] = bad_nexus + bad_direction * LANE_CREEP_MELEE_OFFSET + (-0.5 + (i - 1) / (LANE_CREEP_MELEE_COUNT - 1)) * bad_normal * LANE_CREEP_MELEE_SPAWN_DISTANCE
		end
	else
		self.spawn_points[DOTA_TEAM_BADGUYS].ranged[1] = bad_nexus + bad_direction * LANE_CREEP_MELEE_OFFSET
	end

	self.spawn_points[DOTA_TEAM_BADGUYS].siege[1] = bad_nexus + bad_direction * LANE_CREEP_SIEGE_OFFSET

	self.creep_names = {}
	self.creep_names[DOTA_TEAM_GOODGUYS] = {}
	self.creep_names[DOTA_TEAM_GOODGUYS].melee = "npc_dota_creep_goodguys_melee"
	self.creep_names[DOTA_TEAM_GOODGUYS].ranged = "npc_dota_creep_goodguys_ranged"
	self.creep_names[DOTA_TEAM_GOODGUYS].siege = "npc_dota_goodguys_siege"

	self.creep_names[DOTA_TEAM_BADGUYS] = {}
	self.creep_names[DOTA_TEAM_BADGUYS].melee = "npc_dota_creep_badguys_melee"
	self.creep_names[DOTA_TEAM_BADGUYS].ranged = "npc_dota_creep_badguys_ranged"
	self.creep_names[DOTA_TEAM_BADGUYS].siege = "npc_dota_badguys_siege"
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
		for _, spawn_point in pairs(spawn_points.siege) do
			if team == DOTA_TEAM_GOODGUYS then LaneCreep(team, self.good_path, spawn_point, self.creep_names[team].siege) end
			if team == DOTA_TEAM_BADGUYS then LaneCreep(team, self.bad_path, spawn_point, self.creep_names[team].siege) end
		end
	end
end

function LaneCreeps:SpawnNeutralForTeam(team, unit_name)
	local creep = LaneCreep(team, (team == DOTA_TEAM_GOODGUYS) and self.good_path or self.bad_path, self.spawn_points[team].siege[1], unit_name)
	creep.unit:AddNewModifier(creep.unit, nil, "modifier_nexus_attacker", {})
end



if LaneCreep == nil then LaneCreep = class({}) end

function LaneCreep:constructor(team, path, location, unit_name)
	self.team = team
	self.path = path
	self.location = location
	self.unit_name = unit_name

	self.unit = CreateUnitByName(self.unit_name, self.location, true, nil, nil, self.team)
	ResolveNPCPositions(self.location, 200)
	self.unit:SetForwardVector((Vector(0, 0, 128) - self.location):Normalized())

	self.unit:AddNewModifier(self.unit, nil, "modifier_lane_creep_state", {})

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