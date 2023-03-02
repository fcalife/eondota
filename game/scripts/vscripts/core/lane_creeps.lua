_G.LaneCreeps = LaneCreeps or {}

LANE_CREEP_FIRST_SPAWN = 0
LANE_CREEP_SPAWN_DELAY = 30
LANE_CREEP_MELEE_COUNT = 3
LANE_CREEP_RANGED_COUNT = 1
LANE_CREEP_MELEE_OFFSET = 450
LANE_CREEP_RANGED_OFFSET = 200
LANE_CREEP_RANGED_SPAWN_LENGTH = 400
LANE_CREEP_MELEE_SPAWN_LENGTH = 500

LANE_MID = 1
LANE_LEFT = 2
LANE_RIGHT = 3

function LaneCreeps:Init()
	self.special_wave = 0

	self.creep_names = {}
	self.creep_names[DOTA_TEAM_GOODGUYS] = {}
	self.creep_names[DOTA_TEAM_GOODGUYS].melee = "npc_dota_creep_goodguys_melee"
	self.creep_names[DOTA_TEAM_GOODGUYS].ranged = "npc_dota_creep_goodguys_ranged"
	self.creep_names[DOTA_TEAM_GOODGUYS].magic = "npc_eon_creep_goodguys_magic"
	self.creep_names[DOTA_TEAM_GOODGUYS].sapper = "npc_eon_creep_sapper"

	self.creep_names[DOTA_TEAM_BADGUYS] = {}
	self.creep_names[DOTA_TEAM_BADGUYS].melee = "npc_dota_creep_badguys_melee"
	self.creep_names[DOTA_TEAM_BADGUYS].ranged = "npc_dota_creep_badguys_ranged"
	self.creep_names[DOTA_TEAM_BADGUYS].magic = "npc_eon_creep_badguys_magic"
	self.creep_names[DOTA_TEAM_BADGUYS].sapper = "npc_eon_creep_sapper"

	self.magic_creep_research = {}
	self.magic_creep_research[DOTA_TEAM_GOODGUYS] = false
	self.magic_creep_research[DOTA_TEAM_BADGUYS] = false

	self.sapper_research = {}
	self.sapper_research[DOTA_TEAM_GOODGUYS] = false
	self.sapper_research[DOTA_TEAM_BADGUYS] = false



	self.lanes = {}

	self.lanes[DOTA_TEAM_GOODGUYS] = {}
	self.lanes[DOTA_TEAM_BADGUYS] = {}

	local mid_lane = {}

	mid_lane.good_barracks = GameManager:GetMapLocation("good_barracks_mid")
	mid_lane.bad_barracks = GameManager:GetMapLocation("bad_barracks_mid")
	mid_lane.good_tower_t2 = GameManager:GetMapLocation("good_tower_mid_t2")
	mid_lane.bad_tower_t2 = GameManager:GetMapLocation("bad_tower_mid_t2")
	mid_lane.good_tower_t1 = GameManager:GetMapLocation("good_tower_mid_t1")
	mid_lane.bad_tower_t1 = GameManager:GetMapLocation("bad_tower_mid_t1")

	mid_lane.good_nexus = GameManager:GetMapLocation("good_nexus")
	mid_lane.bad_nexus = GameManager:GetMapLocation("bad_nexus")

	self.lanes[DOTA_TEAM_GOODGUYS][LANE_MID] = CreepLane(mid_lane.good_barracks, mid_lane.bad_barracks, {
		Vector(0, 0, 128),
		mid_lane.bad_tower_t1,
		mid_lane.bad_tower_t2,
		mid_lane.bad_barracks,
		mid_lane.bad_nexus,
	}, DOTA_TEAM_GOODGUYS, LANE_MID)

	self.lanes[DOTA_TEAM_BADGUYS][LANE_MID] = CreepLane(mid_lane.bad_barracks, mid_lane.good_barracks, {
		Vector(0, 0, 128),
		mid_lane.good_tower_t1,
		mid_lane.good_tower_t2,
		mid_lane.good_barracks,
		mid_lane.good_nexus,
	}, DOTA_TEAM_BADGUYS, LANE_MID)



	local left_lane = {}

	left_lane.good_barracks = GameManager:GetMapLocation("good_barracks_left")
	left_lane.bad_barracks = GameManager:GetMapLocation("bad_barracks_right")
	left_lane.good_tower = GameManager:GetMapLocation("good_tower_left")
	left_lane.bad_tower = GameManager:GetMapLocation("bad_tower_right")

	left_lane.good_minerals = GameManager:GetMapLocation("good_minerals_left")
	left_lane.good_nexus = GameManager:GetMapLocation("good_nexus")

	left_lane.bad_upgrade_center = GameManager:GetMapLocation("bad_upgrade_center")
	left_lane.bad_mid_tower_t1 = GameManager:GetMapLocation("bad_tower_mid_t1")
	left_lane.bad_mid_tower_t2 = GameManager:GetMapLocation("bad_tower_mid_t2")
	left_lane.bad_barracks_mid = GameManager:GetMapLocation("bad_barracks_mid")
	left_lane.bad_nexus = GameManager:GetMapLocation("bad_nexus")

	self.lanes[DOTA_TEAM_GOODGUYS][LANE_LEFT] = CreepLane(left_lane.good_barracks, left_lane.bad_barracks, {
		left_lane.bad_tower,
		left_lane.bad_barracks,
		left_lane.bad_upgrade_center,
		left_lane.bad_mid_tower_t1,
		left_lane.bad_mid_tower_t2,
		left_lane.bad_barracks_mid,
		left_lane.bad_nexus,
	}, DOTA_TEAM_GOODGUYS, LANE_LEFT)

	self.lanes[DOTA_TEAM_BADGUYS][LANE_LEFT] = CreepLane(left_lane.bad_barracks, left_lane.good_barracks, {
		left_lane.good_tower,
		left_lane.good_barracks,
		left_lane.good_minerals,
		left_lane.good_nexus,
	}, DOTA_TEAM_BADGUYS, LANE_LEFT)



	local right_lane = {}

	right_lane.good_barracks = GameManager:GetMapLocation("good_barracks_right")
	right_lane.bad_barracks = GameManager:GetMapLocation("bad_barracks_left")
	right_lane.good_tower = GameManager:GetMapLocation("good_tower_right")
	right_lane.bad_tower = GameManager:GetMapLocation("bad_tower_left")

	right_lane.bad_minerals = GameManager:GetMapLocation("bad_minerals_left")
	right_lane.bad_nexus = GameManager:GetMapLocation("bad_nexus")

	right_lane.good_upgrade_center = GameManager:GetMapLocation("good_upgrade_center")
	right_lane.good_mid_tower_t1 = GameManager:GetMapLocation("good_tower_mid_t1")
	right_lane.good_mid_tower_t2 = GameManager:GetMapLocation("good_tower_mid_t2")
	right_lane.good_barracks_mid = GameManager:GetMapLocation("good_barracks_mid")
	right_lane.good_nexus = GameManager:GetMapLocation("good_nexus")

	self.lanes[DOTA_TEAM_GOODGUYS][LANE_RIGHT] = CreepLane(right_lane.good_barracks, right_lane.bad_barracks, {
		right_lane.bad_tower,
		right_lane.bad_barracks,
		right_lane.bad_minerals,
		right_lane.bad_nexus,
	}, DOTA_TEAM_GOODGUYS, LANE_RIGHT)

	self.lanes[DOTA_TEAM_BADGUYS][LANE_RIGHT] = CreepLane(right_lane.bad_barracks, right_lane.good_barracks, {
		right_lane.good_tower,
		right_lane.good_barracks,
		right_lane.good_upgrade_center,
		right_lane.good_mid_tower_t1,
		right_lane.good_mid_tower_t2,
		right_lane.good_barracks_mid,
		right_lane.good_nexus,
	}, DOTA_TEAM_BADGUYS, LANE_RIGHT)
end

function LaneCreeps:ResearchMagicCreep(team)
	self.magic_creep_research[team] = true
end

function LaneCreeps:ResearchSapper(team)
	self.sapper_research[team] = true
end

function LaneCreeps:GetLane(team, position)
	if self.lanes[team] and self.lanes[team][position] then
		return self.lanes[team][position]
	end

	return nil
end

function LaneCreeps:SpawnWaves()
	self.special_wave = (self.special_wave + 1) % 3

	for _, team_lanes in pairs(self.lanes) do
		for _, lane in pairs(team_lanes) do
			lane:SpawnWave(self.special_wave == 0)
		end
	end
end

function LaneCreeps:OnGameStart()
	Timers:CreateTimer(LANE_CREEP_FIRST_SPAWN, function()
		if GameManager:GetGamePhase() == GAME_STATE_BATTLE then
			LaneCreeps:SpawnWaves()

			return LANE_CREEP_SPAWN_DELAY
		end
	end)
end



if CreepLane == nil then CreepLane = class({}) end

function CreepLane:constructor(origin, target, path, team, position)
	self.origin = origin
	self.target = target
	self.path = path
	self.team = team
	self.position = position

	self.direction = (self.target - self.origin):Normalized()
	self.normal = Vector((-1) * self.direction.y, self.direction.x, 0):Normalized()

	self.spawn_points = {}

	self.spawn_points.ranged = self.origin + self.direction * LANE_CREEP_RANGED_OFFSET
	self.spawn_points.magic = self.spawn_points.ranged + 0.5 * self.normal * LANE_CREEP_RANGED_SPAWN_LENGTH
	self.spawn_points.sapper = self.spawn_points.ranged - 0.5 * self.normal * LANE_CREEP_RANGED_SPAWN_LENGTH

	self.spawn_points.melee = {}

	for i = 1, LANE_CREEP_MELEE_COUNT do
		local offset = LANE_CREEP_MELEE_SPAWN_LENGTH * ((i - 1) / (LANE_CREEP_MELEE_COUNT - 1) - 0.5)

		table.insert(self.spawn_points.melee, self.origin + self.direction * LANE_CREEP_MELEE_OFFSET + self.normal * offset)
	end
end

function CreepLane:SpawnWave(special_spawns)
	local barracks = BarracksManager:GetBarracks(self.team, self.position)

	if barracks and barracks.unit and (not barracks:IsDisabled()) then
		barracks.unit:EmitSound("Creep.Teleport")

		if special_spawns then
			if LaneCreeps.magic_creep_research[self.team] then
				LaneCreep(self.team, self.path, self.spawn_points.magic, LaneCreeps.creep_names[self.team].magic)
			end

			if LaneCreeps.sapper_research[self.team] then
				LaneCreep(self.team, self.path, self.spawn_points.sapper, LaneCreeps.creep_names[self.team].sapper)
			end
		end

		LaneCreep(self.team, self.path, self.spawn_points.ranged, LaneCreeps.creep_names[self.team].ranged)

		for _, spawn_point in pairs(self.spawn_points.melee) do
			LaneCreep(self.team, self.path, spawn_point, LaneCreeps.creep_names[self.team].melee)
		end
	end
end



if LaneCreep == nil then LaneCreep = class({}) end

function LaneCreep:constructor(team, path, location, unit_name)
	self.team = team
	self.location = location
	self.unit_name = unit_name

	self.unit = CreateUnitByName(self.unit_name, self.location, true, nil, nil, self.team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_lane_creep_state", {})
	self.unit.is_lane_creep = true
	self.unit.lane_path = path

	for i = 0, 10 do
		if self.unit:GetAbilityByIndex(i) then
			self.unit:GetAbilityByIndex(i):SetLevel(1)
		end
	end
end