_G.Minerals = Minerals or {}

function Minerals:Spawn()
	local good_location = Entities:FindByName(nil, "good_minerals"):GetAbsOrigin()
	local bad_location = Entities:FindByName(nil, "bad_minerals"):GetAbsOrigin()

	self.good_patch = MineralPatch(DOTA_TEAM_BADGUYS, good_location)
	self.bad_patch = MineralPatch(DOTA_TEAM_GOODGUYS, bad_location)
end

function Minerals:GetMineralPatch(team)
	if team == DOTA_TEAM_GOODGUYS then
		return self.good_patch
	elseif team == DOTA_TEAM_BADGUYS then
		return self.bad_patch
	end

	return nil
end



if MineralPatch == nil then MineralPatch = class({}) end

function MineralPatch:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_eon_minerals", self.location, true, nil, nil, self.team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_minerals_state", {})

	self.unit.is_minerals = true
end