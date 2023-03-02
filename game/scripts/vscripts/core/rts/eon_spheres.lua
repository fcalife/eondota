_G.EonSpheres = EonSpheres or {}

function EonSpheres:Init()
	self.access = {}

	self.cooldowns = {}

	self.spheres = {}

	self:UpdateCount()

	self.team_access = {}

	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		self.team_access[team] = {}

		self.team_access[team].t2_access = false
		self.team_access[team].t3_access = false

		self.team_access[team].economy_1 = true
		self.team_access[team].creeps_1 = true
		self.team_access[team].nexus_1 = true
		self.team_access[team].tech_1 = true
		self.team_access[team].economy_2 = false
		self.team_access[team].creeps_2 = false
		self.team_access[team].nexus_2 = false
		self.team_access[team].tech_2 = false
		self.team_access[team].creeps_3 = false
	end
end

function EonSpheres:GiveTeamSpheres(team, amount)
	for id = 0, 24 do
		if PlayerResource:IsValidPlayerID(id) and PlayerResource:GetTeam(id) == team then
			self:GivePlayerSpheres(id, amount)
		end
	end

	self:UpdateCount()
end

function EonSpheres:GivePlayerSpheres(id, amount)
	self.spheres[id] = (self.spheres[id] and self.spheres[id] + amount) or amount
end

function EonSpheres:InitializePlayerAccessStats(id)
	local team = PlayerResource:GetTeam(id)

	self.access[id] = {}

	self.access[id].unit_access = false
	self.access[id].upgrade_access = false

	self.access[id].t2_access = self.team_access[team].t2_access
	self.access[id].t3_access = self.team_access[team].t3_access
	self.access[id].economy_1 = self.team_access[team].economy_1
	self.access[id].creeps_1 = self.team_access[team].creeps_1
	self.access[id].nexus_1 = self.team_access[team].nexus_1
	self.access[id].tech_1 = self.team_access[team].tech_1
	self.access[id].economy_2 = self.team_access[team].economy_2
	self.access[id].creeps_2 = self.team_access[team].creeps_2
	self.access[id].nexus_2 = self.team_access[team].nexus_2
	self.access[id].tech_2 = self.team_access[team].tech_2
	self.access[id].creeps_3 = self.team_access[team].creeps_3
end

function EonSpheres:InitializePlayerCooldownStats(id)
	self.cooldowns[id] = {}

	self.cooldowns[id].footman = false
	self.cooldowns[id].archer = false
	self.cooldowns[id].marauder = false
	self.cooldowns[id].reaper = false
	self.cooldowns[id].knight = false
	self.cooldowns[id].golem = false
end

function EonSpheres:StartUnitCooldownForPlayer(id, unit)
	if (not self.cooldowns[id]) then self:InitializePlayerCooldownStats(id) end

	self.cooldowns[id][unit] = true

	self:UpdateCooldowns()
end

function EonSpheres:EndUnitCooldownForPlayer(id, unit)
	if (not self.cooldowns[id]) then self:InitializePlayerCooldownStats(id) end

	self.cooldowns[id][unit] = false

	self:UpdateCooldowns()
end

function EonSpheres:GivePlayerBarracksAccess(id)
	if (not self.access[id]) then self:InitializePlayerAccessStats(id) end

	self.access[id].unit_access = true

	self:UpdateAccess()
end

function EonSpheres:RemovePlayerBarracksAccess(id)
	if (not self.access[id]) then self:InitializePlayerAccessStats(id) end

	self.access[id].unit_access = false

	self:UpdateAccess()
end

function EonSpheres:GivePlayerUpgradeAccess(id)
	if (not self.access[id]) then self:InitializePlayerAccessStats(id) end

	self.access[id].upgrade_access = true

	self:UpdateAccess()
end

function EonSpheres:RemovePlayerUpgradeAccess(id)
	if (not self.access[id]) then self:InitializePlayerAccessStats(id) end

	self.access[id].upgrade_access = false

	self:UpdateAccess()
end

function EonSpheres:GiveTeamTierTwoAccess(team)
	self.team_access[team].t2_access = true

	for id = 0, 24 do
		if PlayerResource:IsValidPlayerID(id) and PlayerResource:GetTeam(id) == team then
			self:GivePlayerTierTwoAccess(id)
		end
	end

	self:UpdateAccess()
end

function EonSpheres:GiveTeamTierThreeAccess(team)
	self.team_access[team].t3_access = true

	for id = 0, 24 do
		if PlayerResource:IsValidPlayerID(id) and PlayerResource:GetTeam(id) == team then
			self:GivePlayerTierThreeAccess(id)
		end
	end

	self:UpdateAccess()
end

function EonSpheres:RemoveTeamUpgradeOption(team, upgrade)
	self.team_access[team][upgrade] = false

	for id = 0, 24 do
		if PlayerResource:IsValidPlayerID(id) and PlayerResource:GetTeam(id) == team then
			self:RemovePlayerUpgradeOption(id, upgrade)
		end
	end

	self:UpdateAccess()
end

function EonSpheres:RemovePlayerUpgradeOption(id, upgrade)
	if (not self.access[id]) then self:InitializePlayerAccessStats(id) end

	self.access[id][upgrade] = false
end

function EonSpheres:GivePlayerTierTwoAccess(id)
	if (not self.access[id]) then self:InitializePlayerAccessStats(id) end

	self.access[id].t2_access = true
	self.access[id].economy_2 = true
	self.access[id].creeps_2 = true
	self.access[id].nexus_2 = true
	self.access[id].tech_2 = true
end

function EonSpheres:GivePlayerTierThreeAccess(id)
	if (not self.access[id]) then self:InitializePlayerAccessStats(id) end

	self.access[id].t3_access = true
	self.access[id].creeps_3 = true
end

function EonSpheres:SpendPlayerSpheres(id, amount)
	if self.spheres[id] and self.spheres[id] >= amount then
		self.spheres[id] = self.spheres[id] - amount

		self:UpdateCount()

		return true
	else
		return false
	end
end

function EonSpheres:UpdateCount()
	CustomNetTables:SetTableValue("score", "player_spheres", self.spheres)
end

function EonSpheres:UpdateAccess()
	CustomNetTables:SetTableValue("score", "menu_access", self.access)
end

function EonSpheres:UpdateCooldowns()
	CustomNetTables:SetTableValue("score", "menu_cooldowns", self.cooldowns)
end