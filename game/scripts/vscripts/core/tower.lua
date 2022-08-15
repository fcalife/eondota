_G.Towers = Towers or {}

function Towers:Spawn()
	local good_lane_location = Entities:FindByName(nil, "good_tower_lane")
	local bad_lane_location = Entities:FindByName(nil, "bad_tower_lane")
	local good_objective_location = Entities:FindByName(nil, "good_tower_objective")
	local bad_objective_location = Entities:FindByName(nil, "bad_tower_objective")

	if good_lane_location then good_lane_location = good_lane_location:GetAbsOrigin() end
	if bad_lane_location then bad_lane_location = bad_lane_location:GetAbsOrigin() end
	if good_objective_location then good_objective_location = good_objective_location:GetAbsOrigin() end
	if bad_objective_location then bad_objective_location = bad_objective_location:GetAbsOrigin() end

	if good_lane_location then RespawningTower(DOTA_TEAM_GOODGUYS, good_lane_location, "npc_dota_goodguys_tower1_mid") end
	if bad_lane_location then RespawningTower(DOTA_TEAM_BADGUYS, bad_lane_location, "npc_dota_badguys_tower1_mid") end
	if good_objective_location then RespawningTower(DOTA_TEAM_GOODGUYS, good_objective_location, "npc_dota_goodguys_tower1_top") end
	if bad_objective_location then RespawningTower(DOTA_TEAM_BADGUYS, bad_objective_location, "npc_dota_badguys_tower1_top") end
end



if RespawningTower == nil then RespawningTower = class({}) end

function RespawningTower:constructor(team, location, unit_name)
	self.location = location
	self.team = team
	self.unit_name = unit_name

	self.unit = CreateUnitByName(self.unit_name, self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})

	self.unit.respawning_tower = self
end

function RespawningTower:Respawn()
	self.unit = CreateUnitByName(self.unit_name, self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_respawning_tower_state", {duration = TOWER_RESPAWN_TIME})
	self.unit:SetHealth(1)

	self.unit.respawning_tower = self
end