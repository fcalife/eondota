_G.Bosses = Bosses or {}

BOSS_SPAWN_INTERVAL = (IsInToolsMode() and 3 or 120)

function Bosses:Init()
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

	self.roaming_bosses = {
		scorpion = true,
		spider = true
	}

	local boss_list = {
		"temple",
		"bear",
		"dragon",
		"lava_golem",
		"treant",
		"scorpion",
		"revenant",
		"spider"
	}

	self.boss_spawn_order = table.shuffled(boss_list)

	self.current_round = 1
end

function Bosses:GetRoundBoss(round)
	return self.boss_spawn_order[round] or nil
end

function Bosses:StartNextRound()
	local boss_to_spawn = self:GetRoundBoss(self.current_round)

	if boss_to_spawn then
		self:SpawnBoss(boss_to_spawn, self.current_round)

		self.current_round = self.current_round + 1

		Timers:CreateTimer(BOSS_SPAWN_INTERVAL, function() self:StartNextRound() end)
	end
end

function Bosses:SpawnBoss(boss_name, round)
	GlobalMessages:NotifyBossSpawned(boss_name)

	CustomNetTables:SetTableValue("bosses", boss_name, {alive = true})

	local upgrades = 5 * (round - 1)

	if self.roaming_bosses[boss_name] then
		local possible_spawns = Entities:FindAllByName("boss_spawn_"..boss_name)

		return RoamingBoss(possible_spawns[1]:GetAbsOrigin(), boss_name, possible_spawns, upgrades)
	else
		local possible_spawns = Entities:FindAllByName("boss_spawn_"..boss_name)
		local shuffled_spawns = table.shuffled(possible_spawns)

		return BossCamp(shuffled_spawns[1]:GetAbsOrigin(), boss_name, upgrades)
	end
end



if BossCamp == nil then BossCamp = class({}) end

function BossCamp:constructor(location, boss_name, level)
	self.location = location
	self.name = boss_name
	self.leader = Bosses.bosses[boss_name].leader

	self:Spawn(level)
end

function BossCamp:Spawn(upgrades)
	local creep_name = self.leader

	local creep = CreateUnitByName(creep_name, self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
	creep:AddNewModifier(creep, nil, "modifier_boss_state_thinker", {})
	creep:AddNewModifier(creep, nil, "modifier_boss_toughness", {})
	creep.boss = self

	if upgrades > 0 then creep:CreatureLevelUp(upgrades) end
end

function BossCamp:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	ScoreManager:OnBossKilled(team, killed_unit:GetUnitName())

	CustomNetTables:SetTableValue("bosses", self.name, {alive = false})
end



if RoamingBoss == nil then RoamingBoss = class({}) end

function RoamingBoss:constructor(location, boss_name, path, level)
	self.location = location
	self.name = boss_name
	self.leader = Bosses.bosses[boss_name].leader
	self.path = {}

	for _, path_point in pairs(path) do
		table.insert(self.path, GetGroundPosition(path_point:GetAbsOrigin(), nil))
	end

	self:Spawn(level)
end

function RoamingBoss:Spawn(upgrades)
	local creep_name = self.leader

	local creep = CreateUnitByName(creep_name, self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
	creep:AddNewModifier(creep, nil, "modifier_boss_toughness", {})

	creep.boss = self
	creep:AddNewModifier(creep, nil, "modifier_boss_state_roaming_thinker", {})

	if upgrades > 0 then creep:CreatureLevelUp(upgrades) end
end

function RoamingBoss:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	ScoreManager:OnBossKilled(team, killed_unit:GetUnitName())

	CustomNetTables:SetTableValue("bosses", self.name, {alive = false})
end