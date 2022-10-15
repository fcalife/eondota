_G.Towers = Towers or {}

function Towers:Spawn()
	self.towers = {}
	self.jungle_towers = {}

	local good_lane_location = Entities:FindByName(nil, "good_tower_lane")
	local bad_lane_location = Entities:FindByName(nil, "bad_tower_lane")

	if good_lane_location then good_lane_location = good_lane_location:GetAbsOrigin() end
	if bad_lane_location then bad_lane_location = bad_lane_location:GetAbsOrigin() end

	if good_lane_location then
		self.towers[DOTA_TEAM_GOODGUYS] = RespawningTower(DOTA_TEAM_GOODGUYS, good_lane_location, "npc_dota_goodguys_tower1_mid")
	end

	if bad_lane_location then
		self.towers[DOTA_TEAM_BADGUYS] = RespawningTower(DOTA_TEAM_BADGUYS, bad_lane_location, "npc_dota_badguys_tower1_mid")
	end

	if IS_NEW_EXPERIMENTAL_MAP then
		self.jungle_towers[DOTA_TEAM_GOODGUYS] = JungleTower(DOTA_TEAM_GOODGUYS, Entities:FindByName(nil, "good_tower_jungle"):GetAbsOrigin(), "npc_dota_goodguys_tower1_top")
		self.jungle_towers[DOTA_TEAM_BADGUYS] = JungleTower(DOTA_TEAM_BADGUYS, Entities:FindByName(nil, "bad_tower_jungle"):GetAbsOrigin(), "npc_dota_badguys_tower1_top")
	end
end

function Towers:GetTeamTower(team)
	return self.towers[team] or nil
end

function Towers:GetTeamJungleTower(team)
	return self.jungle_towers[team] or nil
end



if RespawningTower == nil then RespawningTower = class({}) end

function RespawningTower:constructor(team, location, unit_name)
	self.location = location
	self.team = team
	self.unit_name = unit_name

	self.unit = CreateUnitByName(self.unit_name, self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})

	if self.team == DOTA_TEAM_BADGUYS then self.unit:SetRenderColor(65, 78, 63) end

	self.unit.respawning_tower = self
end

function RespawningTower:Respawn()
	self.unit = CreateUnitByName(self.unit_name, self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_respawning_tower_state", {duration = TOWER_RESPAWN_TIME})
	self.unit:SetHealth(1)

	if self.team == DOTA_TEAM_BADGUYS then self.unit:SetRenderColor(65, 78, 63) end

	self.unit.respawning_tower = self
end

function RespawningTower:OnDeath(keys)
	local scepter_drop = CreateItem("item_ultimate_scepter_roshan", nil, nil)
	CreateItemOnPositionForLaunch(keys.unit:GetAbsOrigin(), scepter_drop)
	scepter_drop:LaunchLootInitialHeight(false, 0, 300, 0.4, keys.attacker:GetAbsOrigin())

	scepter_drop.pickup_team = ENEMY_TEAM[keys.unit:GetTeam()]
end



if JungleTower == nil then JungleTower = class(RespawningTower) end

function JungleTower:constructor(team, location, unit_name)
	self.location = location
	self.team = team
	self.unit_name = unit_name

	self.unit = CreateUnitByName(self.unit_name, self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_jungle_tower_shield", {shield = 250})

	if self.team == DOTA_TEAM_BADGUYS then self.unit:SetRenderColor(65, 78, 63) end

	self.unit.respawning_tower = self
end