_G.Towers = Towers or {}

function Towers:Init()
	self.towers = {}

	for _, spawn_point in pairs(Entities:FindAllByName("good_tower_lane")) do
		LaneTower(spawn_point:GetAbsOrigin(), DOTA_TEAM_GOODGUYS)
	end

	for _, spawn_point in pairs(Entities:FindAllByName("bad_tower_lane")) do
		LaneTower(spawn_point:GetAbsOrigin(), DOTA_TEAM_BADGUYS)
	end
end

function Towers:GetTeamTowers(team)
	return self.towers[team] or nil
end



if LaneTower == nil then LaneTower = class({}) end

function LaneTower:constructor(location, team)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_dota_goodguys_tower1_mid", self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})

	if self.team == DOTA_TEAM_BADGUYS then self.unit:SetRenderColor(65, 78, 63) end
end