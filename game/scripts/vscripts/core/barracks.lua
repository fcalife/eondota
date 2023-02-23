_G.BarracksManager = BarracksManager or {}

BARRACKS_UNIT_DURATION = 60

function BarracksManager:Spawn()
	self.barracks = {}

	self.barracks[DOTA_TEAM_GOODGUYS] = Barracks(DOTA_TEAM_GOODGUYS, Entities:FindByName(nil, "good_barracks"):GetAbsOrigin())
	self.barracks[DOTA_TEAM_BADGUYS] = Barracks(DOTA_TEAM_BADGUYS, Entities:FindByName(nil, "bad_barracks"):GetAbsOrigin())
end

function BarracksManager:GetBarracks(team)
	return self.barracks[team] or nil
end

function BarracksManager:OnGameStart()
	for _, barracks in pairs(self.barracks) do
		local player_id = GameManager:GetTeamPlayerID(barracks.team)

		if player_id then
			local hero = PlayerResource:GetSelectedHeroEntity(player_id)

			barracks.unit:SetOwner(hero)
			barracks.unit:SetControllableByPlayer(player_id, true)
		end
	end
end



if Barracks == nil then Barracks = class({}) end

function Barracks:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_eon_barracks", self.location, true, nil, nil, self.team)
	self.unit.is_barracks = true
	self.unit.barracks = self
end

function Barracks:SpawnUnit(unit_name)
	local spawn_location = LaneCreeps.spawn_points[self.team].ranged[1]

	local lane_creep = LaneCreep:constructor(self.team, LaneCreeps.creep_paths[self.team], spawn_location, unit_name)
	lane_creep:AddNewModifier(lane_creep, nil, "modifier_kill", {duration = BARRACKS_UNIT_DURATION})
	lane_creep:AddNewModifier(lane_creep, nil, "modifier_barracks_creep_spawn_state", {duration = 0.1})
	lane_creep:AddNewModifier(lane_creep, nil, "modifier_phased", {duration = 0.1})
	lane_creep.is_barracks_unit = true

	local player_id = GameManager:GetTeamPlayerID(self.team)

	if player_id then
		local hero = PlayerResource:GetSelectedHeroEntity(player_id)

		lane_creep:SetOwner(hero)
		lane_creep:SetControllableByPlayer(player_id, true)
	end

	lane_creep:EmitSound("Barracks.Summon")
end