_G.Towers = Towers or {}

TOWER_UNIT_NAME = {}
TOWER_UNIT_NAME[DOTA_TEAM_GOODGUYS] = "npc_dota_goodguys_tower1_mid"
TOWER_UNIT_NAME[DOTA_TEAM_BADGUYS] = "npc_dota_badguys_tower1_mid"

function Towers:Init()
	self.towers = {}

	self.towers[DOTA_TEAM_GOODGUYS] = {}
	self.towers[DOTA_TEAM_BADGUYS] = {}

	table.insert(self.towers[DOTA_TEAM_GOODGUYS], LaneTower(GameManager:GetMapLocation("good_tower_mid_t2"), DOTA_TEAM_GOODGUYS))
	table.insert(self.towers[DOTA_TEAM_GOODGUYS], LaneTower(GameManager:GetMapLocation("good_tower_mid_t1"), DOTA_TEAM_GOODGUYS))
	table.insert(self.towers[DOTA_TEAM_GOODGUYS], LaneTower(GameManager:GetMapLocation("good_tower_left"), DOTA_TEAM_GOODGUYS))
	table.insert(self.towers[DOTA_TEAM_GOODGUYS], LaneTower(GameManager:GetMapLocation("good_tower_right"), DOTA_TEAM_GOODGUYS))

	table.insert(self.towers[DOTA_TEAM_BADGUYS], LaneTower(GameManager:GetMapLocation("bad_tower_mid_t2"), DOTA_TEAM_BADGUYS))
	table.insert(self.towers[DOTA_TEAM_BADGUYS], LaneTower(GameManager:GetMapLocation("bad_tower_mid_t1"), DOTA_TEAM_BADGUYS))
	table.insert(self.towers[DOTA_TEAM_BADGUYS], LaneTower(GameManager:GetMapLocation("bad_tower_left"), DOTA_TEAM_BADGUYS))
	table.insert(self.towers[DOTA_TEAM_BADGUYS], LaneTower(GameManager:GetMapLocation("bad_tower_right"), DOTA_TEAM_BADGUYS))
end

function Towers:GetTeamTowers(team)
	return self.towers[team] or nil
end



if LaneTower == nil then LaneTower = class({}) end

function LaneTower:constructor(location, team)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName(TOWER_UNIT_NAME[self.team], self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})

	if self.team == DOTA_TEAM_BADGUYS then self.unit:SetRenderColor(65, 78, 63) end
end