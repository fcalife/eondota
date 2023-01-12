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

	-- for level = 1, 3 do
	-- 	for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
	-- 		NeutralCamp(camp_location:GetAbsOrigin(), self.camp_data[level])
	-- 	end
	-- end

	BossCamp(Entities:FindByName(nil, "boss_spawn_temple"):GetAbsOrigin(), "temple")
	BossCamp(Entities:FindByName(nil, "boss_spawn_bear"):GetAbsOrigin(), "bear")
	BossCamp(Entities:FindByName(nil, "boss_spawn_dragon"):GetAbsOrigin(), "dragon")
	BossCamp(Entities:FindByName(nil, "boss_spawn_lava_golem"):GetAbsOrigin(), "lava_golem")
	BossCamp(Entities:FindByName(nil, "boss_spawn_treant"):GetAbsOrigin(), "treant")
	BossCamp(Entities:FindByName(nil, "boss_spawn_scorpion"):GetAbsOrigin(), "scorpion")
	BossCamp(Entities:FindByName(nil, "boss_spawn_revenant"):GetAbsOrigin(), "revenant")
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

	self.creeps = {}

	self:Spawn()
end

function BossCamp:Spawn()
	self.creeps = {}

	local creep_name = self.leader

	local creep = CreateUnitByName(creep_name, self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
	creep.boss = self

	table.insert(self.creeps, creep)
end

function BossCamp:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	ScoreManager:Score(team)
end