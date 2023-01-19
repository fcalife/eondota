_G.NeutralCamps = NeutralCamps or {}

function NeutralCamps:StartSpawning()
	self.bosses = {}
	self.bosses["temple"] = {
		leader = "boss_spawn_temple",
		min_minions = 0,
		max_minions = 0,
		minimap_dummy = "npc_camp_dummy_4",
		scale = 50,
	}
	self.bosses["bear"] = {
		leader = "boss_spawn_bear",
		min_minions = 0,
		max_minions = 0,
		minimap_dummy = "npc_camp_dummy_4",
		scale = 50,
	}
	self.bosses["dragon"] = {
		leader = "boss_spawn_dragon",
		min_minions = 0,
		max_minions = 0,
		minimap_dummy = "npc_camp_dummy_4",
		scale = 80,
	}
	self.bosses["lava_golem"] = {
		leader = "boss_spawn_lava_golem",
		min_minions = 0,
		max_minions = 0,
		minimap_dummy = "npc_camp_dummy_4",
		scale = 80,
	}
	self.bosses["treant"] = {
		leader = "boss_spawn_treant",
		min_minions = 0,
		max_minions = 0,
		minimap_dummy = "npc_camp_dummy_4",
		scale = 30,
	}
	self.bosses["scorpion"] = {
		leader = "boss_spawn_scorpion",
		min_minions = 0,
		max_minions = 0,
		minimap_dummy = "npc_camp_dummy_4",
		scale = 10,
	}
	self.bosses["revenant"] = {
		leader = "boss_spawn_revenant",
		min_minions = 0,
		max_minions = 0,
		minimap_dummy = "npc_camp_dummy_4",
		scale = 50,
	}
	self.bosses["spider"] = {
		leader = "boss_spawn_spider",
		min_minions = 0,
		max_minions = 0,
		minimap_dummy = "npc_camp_dummy_4",
		scale = 0,
	}

	-- for level = 1, 3 do
	-- 	for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
	-- 		NeutralCamp(camp_location:GetAbsOrigin(), self.camp_data[level])
	-- 	end
	-- end

	local possible_spawns = Entities:FindAllByName("boss_spawn_temple")
	local shuffled_spawns = table.shuffled(possible_spawns)
	BossCamp(shuffled_spawns[1]:GetAbsOrigin(), "temple")

	possible_spawns = Entities:FindAllByName("boss_spawn_bear")
	shuffled_spawns = table.shuffled(possible_spawns)
	BossCamp(shuffled_spawns[1]:GetAbsOrigin(), "bear")

	possible_spawns = Entities:FindAllByName("boss_spawn_treant")
	shuffled_spawns = table.shuffled(possible_spawns)
	BossCamp(shuffled_spawns[1]:GetAbsOrigin(), "treant")

	possible_spawns = Entities:FindAllByName("boss_spawn_revenant")
	shuffled_spawns = table.shuffled(possible_spawns)
	BossCamp(shuffled_spawns[1]:GetAbsOrigin(), "revenant")

	BossCamp(Entities:FindByName(nil, "boss_spawn_dragon"):GetAbsOrigin(), "dragon")

	Timers:CreateTimer(900, function()
		BossCamp(Entities:FindByName(nil, "boss_spawn_lava_golem"):GetAbsOrigin(), "lava_golem")
		GlobalMessages:Send("The Volcano has erupted!")
		EmitGlobalSound("dire.round")
	end)

	possible_spawns = Entities:FindAllByName("boss_spawn_scorpion")
	RoamingBoss(possible_spawns[1]:GetAbsOrigin(), "scorpion", possible_spawns)

	possible_spawns = Entities:FindAllByName("boss_spawn_spider")
	RoamingBoss(possible_spawns[1]:GetAbsOrigin(), "spider", possible_spawns)
end



if NeutralCamp == nil then NeutralCamp = class({}) end

function NeutralCamp:constructor(location, data)
	self.location = location
	self.leader = data.leader
	self.minimap_dummy = data.minimap_dummy
	self.scale = data.scale

	self.creeps = {}

	self:Spawn()
end

function NeutralCamp:Spawn()
	self.creeps = {}

	local creep_name = self.leader

	local creep = CreateUnitByName(creep_name, self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	--creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
	--creep:SetForwardVector((Vector(0, 0, 128) - self.location):Normalized())
	creep.camp = self

	table.insert(self.creeps, creep)
end

function NeutralCamp:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	for _, creep in pairs(self.creeps) do
		if creep and (not creep:IsNull()) and creep:IsAlive() then
			camp_clear = false
		end
	end

	if (not camp_clear) then return end

	Timers:CreateTimer(30, function() self:Spawn() end)

	GoldRewards:LevelupPlayersInTeam(team)
end



if BossCamp == nil then BossCamp = class({}) end

function BossCamp:constructor(location, boss_name)
	self.location = location
	self.leader = NeutralCamps.bosses[boss_name].leader

	self:Spawn()
end

function BossCamp:Spawn()
	local creep_name = self.leader

	local creep = CreateUnitByName(creep_name, self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
	creep:AddNewModifier(creep, nil, "modifier_boss_state_thinker", {})
	creep:AddNewModifier(creep, nil, "modifier_boss_toughness", {})
	creep.boss = self
end

function BossCamp:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	ScoreManager:OnBossKilled(team, killed_unit:GetUnitName())
end



if RoamingBoss == nil then RoamingBoss = class({}) end

function RoamingBoss:constructor(location, boss_name, path)
	self.location = location
	self.leader = NeutralCamps.bosses[boss_name].leader
	self.path = {}

	for _, path_point in pairs(path) do
		table.insert(self.path, GetGroundPosition(path_point:GetAbsOrigin(), nil))
	end

	self:Spawn()
end

function RoamingBoss:Spawn()
	local creep_name = self.leader

	local creep = CreateUnitByName(creep_name, self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
	creep:AddNewModifier(creep, nil, "modifier_boss_toughness", {})

	creep.boss = self
	creep:AddNewModifier(creep, nil, "modifier_boss_state_roaming_thinker", {})
end

function RoamingBoss:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	ScoreManager:OnBossKilled(team, killed_unit:GetUnitName())
end