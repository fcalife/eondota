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
	local unit = CreateUnitByName(unit_name, self.location + RandomVector(200), true, nil, nil, self.team)
	unit:AddNewModifier(unit, nil, "modifier_kill", {duration = BARRACKS_UNIT_DURATION})
	unit.is_barracks_unit = true

	local player_id = GameManager:GetTeamPlayerID(self.team)

	if player_id then
		local hero = PlayerResource:GetSelectedHeroEntity(player_id)

		unit:SetOwner(hero)
		unit:SetControllableByPlayer(player_id, true)
	end

	unit:EmitSound("Barracks.Summon")
end