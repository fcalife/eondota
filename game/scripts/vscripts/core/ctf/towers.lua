_G.Towers = Towers or {}

function Towers:Init()
	self.towers = {}
	self.towers[DOTA_TEAM_GOODGUYS] = {}
	self.towers[DOTA_TEAM_BADGUYS] = {}

	for _, spawn_point in pairs(Entities:FindAllByName("good_tower_lane")) do
		if LIVING_BUILDINGS_ENABLED then
			table.insert(self.towers[DOTA_TEAM_GOODGUYS], LivingTower(spawn_point:GetAbsOrigin(), DOTA_TEAM_GOODGUYS))
		elseif CHARGE_TOWERS_ENABLED then
			table.insert(self.towers[DOTA_TEAM_GOODGUYS], ChargeTower(spawn_point:GetAbsOrigin(), DOTA_TEAM_GOODGUYS))
		else
			table.insert(self.towers[DOTA_TEAM_GOODGUYS], LaneTower(spawn_point:GetAbsOrigin(), DOTA_TEAM_GOODGUYS))
		end
	end

	for _, spawn_point in pairs(Entities:FindAllByName("bad_tower_lane")) do
		if LIVING_BUILDINGS_ENABLED then
			table.insert(self.towers[DOTA_TEAM_BADGUYS], LivingTower(spawn_point:GetAbsOrigin(), DOTA_TEAM_BADGUYS))
		elseif CHARGE_TOWERS_ENABLED then
			table.insert(self.towers[DOTA_TEAM_BADGUYS], ChargeTower(spawn_point:GetAbsOrigin(), DOTA_TEAM_BADGUYS))
		else
			table.insert(self.towers[DOTA_TEAM_BADGUYS], LaneTower(spawn_point:GetAbsOrigin(), DOTA_TEAM_BADGUYS))
		end
	end
end

function Towers:GetTeamTowers(team)
	return self.towers[team] or nil
end



if LaneTower == nil then LaneTower = class({}) end

function LaneTower:constructor(location, team)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName(team == DOTA_TEAM_GOODGUYS and "npc_dota_goodguys_tower1_mid" or "npc_dota_badguys_tower1_mid", self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})

	if self.team == DOTA_TEAM_BADGUYS then self.unit:SetRenderColor(65, 78, 63) end
end



if LivingTower == nil then LivingTower = class({}) end

function LivingTower:constructor(location, team)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName(team == DOTA_TEAM_GOODGUYS and "npc_eon_living_tower_good" or "npc_eon_living_tower_bad", self.location, false, nil, nil, self.team)

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_rooted", {duration = LIVING_NEXUS_AWAKENING_TIME})

	Timers:CreateTimer(0.5, function()
		local unit_id = self.unit:entindex()

		ExecuteOrderFromTable({
			unitIndex = unit_id,
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = Vector(0, 0, 128),
			Queue = true
		})
	end)
end



if ChargeTower == nil then ChargeTower = class({}) end

function ChargeTower:constructor(location, team)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName(team == DOTA_TEAM_GOODGUYS and "npc_dota_goodguys_tower1_mid" or "npc_dota_badguys_tower1_mid", self.location, false, nil, nil, self.team)
	self.unit:RemoveModifierByName("modifier_invulnerable")

	self.unit:AddNewModifier(self.unit, nil, "modifier_tower_state", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_disarmed", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_invulnerable", {})

	if self.team == DOTA_TEAM_BADGUYS then self.unit:SetRenderColor(65, 78, 63) end
end

function ChargeTower:Activate()
	self.unit:RemoveModifierByName("modifier_invulnerable")
	self.unit:RemoveModifierByName("modifier_disarmed")
	self.unit:AddNewModifier(self.unit, nil, "modifier_fountain_glyph", {duration = CHARGE_TOWER_ACTIVATION_TIME})
	self.unit:AddNewModifier(self.unit, nil, "modifier_invulnerable", {})

	Timers:CreateTimer(CHARGE_TOWER_ACTIVATION_TIME, function()
		self.unit:RemoveModifierByName("modifier_fountain_glyph")
		self.unit:RemoveModifierByName("modifier_invulnerable")
		self.unit:AddNewModifier(self.unit, nil, "modifier_disarmed", {})
		self.unit:AddNewModifier(self.unit, nil, "modifier_invulnerable", {})
	end)
end