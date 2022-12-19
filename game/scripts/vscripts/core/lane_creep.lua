_G.LaneCreeps = LaneCreeps or {}

LANE_CREEP_FIRST_SPAWN = 0
LANE_CREEP_RESPAWN_DELAY = 30
LANE_CREEP_MELEE_COUNT = 3
LANE_CREEP_RANGED_COUNT = 1
LANE_CREEP_RANGED_OFFSET = -250
LANE_CREEP_SIEGE_OFFSET = -500
LANE_CREEP_MELEE_SPAWN_DISTANCE = 350
LANE_CREEP_RANGED_SPAWN_DISTANCE = 250

function LaneCreeps:Init()
	local good_nexus = Entities:FindByName(nil, "radiant_nexus"):GetAbsOrigin()
	local bad_nexus = Entities:FindByName(nil, "dire_nexus"):GetAbsOrigin()

	local bottom_waypoints = {}
	table.insert(bottom_waypoints, Entities:FindByName(nil, "radiant_creep_waypoint_a1"):GetAbsOrigin())
	table.insert(bottom_waypoints, Entities:FindByName(nil, "creep_waypoint_a2"):GetAbsOrigin())
	table.insert(bottom_waypoints, Entities:FindByName(nil, "dire_creep_waypoint_a1"):GetAbsOrigin())

	local top_waypoints = {}
	table.insert(top_waypoints, Entities:FindByName(nil, "radiant_creep_waypoint_b1"):GetAbsOrigin())
	table.insert(top_waypoints, Entities:FindByName(nil, "creep_waypoint_b2"):GetAbsOrigin())
	table.insert(top_waypoints, Entities:FindByName(nil, "dire_creep_waypoint_b1"):GetAbsOrigin())

	self.bottom_path = {}
	self.bottom_path[DOTA_TEAM_GOODGUYS] = {}
	self.bottom_path[DOTA_TEAM_BADGUYS] = {}

	table.insert(self.bottom_path[DOTA_TEAM_GOODGUYS], bottom_waypoints[1])
	table.insert(self.bottom_path[DOTA_TEAM_GOODGUYS], bottom_waypoints[2])
	table.insert(self.bottom_path[DOTA_TEAM_GOODGUYS], bottom_waypoints[3])
	table.insert(self.bottom_path[DOTA_TEAM_GOODGUYS], bad_nexus)

	table.insert(self.bottom_path[DOTA_TEAM_BADGUYS], bottom_waypoints[3])
	table.insert(self.bottom_path[DOTA_TEAM_BADGUYS], bottom_waypoints[2])
	table.insert(self.bottom_path[DOTA_TEAM_BADGUYS], bottom_waypoints[1])
	table.insert(self.bottom_path[DOTA_TEAM_BADGUYS], good_nexus)

	self.top_path = {}
	self.top_path[DOTA_TEAM_GOODGUYS] = {}
	self.top_path[DOTA_TEAM_BADGUYS] = {}

	table.insert(self.top_path[DOTA_TEAM_GOODGUYS], top_waypoints[1])
	table.insert(self.top_path[DOTA_TEAM_GOODGUYS], top_waypoints[2])
	table.insert(self.top_path[DOTA_TEAM_GOODGUYS], top_waypoints[3])
	table.insert(self.top_path[DOTA_TEAM_GOODGUYS], bad_nexus)

	table.insert(self.top_path[DOTA_TEAM_BADGUYS], top_waypoints[3])
	table.insert(self.top_path[DOTA_TEAM_BADGUYS], top_waypoints[2])
	table.insert(self.top_path[DOTA_TEAM_BADGUYS], top_waypoints[1])
	table.insert(self.top_path[DOTA_TEAM_BADGUYS], good_nexus)



	local bottom_spawn = Entities:FindByName(nil, "radiant_creep_spawn_a"):GetAbsOrigin()
	local top_spawn = Entities:FindByName(nil, "radiant_creep_spawn_b"):GetAbsOrigin()
	local bottom_end = Entities:FindByName(nil, "dire_creep_spawn_a"):GetAbsOrigin()
	local top_end = Entities:FindByName(nil, "dire_creep_spawn_b"):GetAbsOrigin()

	local bottom_direction = (bottom_spawn - good_nexus):Normalized()
	local top_direction = (top_spawn - good_nexus):Normalized()

	local spawn_normal = Vector(1, 1, 0):Normalized()

	self.bottom_spawns = {}

	self.bottom_spawns[DOTA_TEAM_GOODGUYS] = {}
	self.bottom_spawns[DOTA_TEAM_GOODGUYS].melee = {}
	self.bottom_spawns[DOTA_TEAM_GOODGUYS].ranged = {}
	self.bottom_spawns[DOTA_TEAM_GOODGUYS].siege = {}

	self.top_spawns = {}

	self.top_spawns[DOTA_TEAM_GOODGUYS] = {}
	self.top_spawns[DOTA_TEAM_GOODGUYS].melee = {}
	self.top_spawns[DOTA_TEAM_GOODGUYS].ranged = {}
	self.top_spawns[DOTA_TEAM_GOODGUYS].siege = {}

	for i = 1, LANE_CREEP_MELEE_COUNT do
		self.bottom_spawns[DOTA_TEAM_GOODGUYS].melee[i] = bottom_spawn + (-0.5 + (i - 1) / (LANE_CREEP_MELEE_COUNT - 1)) * spawn_normal * LANE_CREEP_MELEE_SPAWN_DISTANCE
	end

	self.bottom_spawns[DOTA_TEAM_GOODGUYS].ranged[1] = bottom_spawn + bottom_direction * LANE_CREEP_RANGED_OFFSET
	self.bottom_spawns[DOTA_TEAM_GOODGUYS].siege[1] = bottom_spawn + bottom_direction * LANE_CREEP_SIEGE_OFFSET

	for i = 1, LANE_CREEP_MELEE_COUNT do
		self.top_spawns[DOTA_TEAM_GOODGUYS].melee[i] = top_spawn + (-0.5 + (i - 1) / (LANE_CREEP_MELEE_COUNT - 1)) * spawn_normal * LANE_CREEP_MELEE_SPAWN_DISTANCE
	end

	self.top_spawns[DOTA_TEAM_GOODGUYS].ranged[1] = top_spawn + top_direction * LANE_CREEP_RANGED_OFFSET
	self.top_spawns[DOTA_TEAM_GOODGUYS].siege[1] = top_spawn + top_direction * LANE_CREEP_SIEGE_OFFSET



	self.bottom_spawns[DOTA_TEAM_BADGUYS] = {}
	self.bottom_spawns[DOTA_TEAM_BADGUYS].melee = {}
	self.bottom_spawns[DOTA_TEAM_BADGUYS].ranged = {}
	self.bottom_spawns[DOTA_TEAM_BADGUYS].siege = {}

	self.top_spawns[DOTA_TEAM_BADGUYS] = {}
	self.top_spawns[DOTA_TEAM_BADGUYS].melee = {}
	self.top_spawns[DOTA_TEAM_BADGUYS].ranged = {}
	self.top_spawns[DOTA_TEAM_BADGUYS].siege = {}

	for i = 1, LANE_CREEP_MELEE_COUNT do
		self.bottom_spawns[DOTA_TEAM_BADGUYS].melee[i] = bottom_end + (-0.5 + (i - 1) / (LANE_CREEP_MELEE_COUNT - 1)) * spawn_normal * LANE_CREEP_MELEE_SPAWN_DISTANCE
	end

	self.bottom_spawns[DOTA_TEAM_BADGUYS].ranged[1] = bottom_end + bottom_direction * LANE_CREEP_RANGED_OFFSET
	self.bottom_spawns[DOTA_TEAM_BADGUYS].siege[1] = bottom_end + bottom_direction * LANE_CREEP_SIEGE_OFFSET

	for i = 1, LANE_CREEP_MELEE_COUNT do
		self.top_spawns[DOTA_TEAM_BADGUYS].melee[i] = top_end + (-0.5 + (i - 1) / (LANE_CREEP_MELEE_COUNT - 1)) * spawn_normal * LANE_CREEP_MELEE_SPAWN_DISTANCE
	end

	self.top_spawns[DOTA_TEAM_BADGUYS].ranged[1] = top_end + top_direction * LANE_CREEP_RANGED_OFFSET
	self.top_spawns[DOTA_TEAM_BADGUYS].siege[1] = top_end + top_direction * LANE_CREEP_SIEGE_OFFSET



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

function LaneCreeps:SpawnWave(spawn_siege)
	for team, spawn_points in pairs(self.bottom_spawns) do
		for _, spawn_point in pairs(spawn_points.melee) do
			LaneCreep(team, self.bottom_path[team], spawn_point, self.creep_names[team].melee)
		end
		for _, spawn_point in pairs(spawn_points.ranged) do
			LaneCreep(team, self.bottom_path[team], spawn_point, self.creep_names[team].ranged)
		end
		if spawn_siege then
			for _, spawn_point in pairs(spawn_points.siege) do
				LaneCreep(team, self.bottom_path[team], spawn_point, self.creep_names[team].siege)
			end
		end
	end

	for team, spawn_points in pairs(self.top_spawns) do
		for _, spawn_point in pairs(spawn_points.melee) do
			LaneCreep(team, self.top_path[team], spawn_point, self.creep_names[team].melee)
		end
		for _, spawn_point in pairs(spawn_points.ranged) do
			LaneCreep(team, self.top_path[team], spawn_point, self.creep_names[team].ranged)
		end
		if spawn_siege then
			for _, spawn_point in pairs(spawn_points.siege) do
				LaneCreep(team, self.top_path[team], spawn_point, self.creep_names[team].siege)
			end
		end
	end
end

function LaneCreeps:SpawnNeutralForTeam(team, unit_name, offset)
	local creep = LaneCreep(team, (team == DOTA_TEAM_GOODGUYS) and self.good_path or self.bad_path, self.spawn_points[team].siege[1] + RandomVector(offset), unit_name)
	creep.unit:AddNewModifier(creep.unit, nil, "modifier_nexus_attacker", {})
	creep.unit:AddNewModifier(creep.unit, nil, "modifier_kill", {duration = 45})
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