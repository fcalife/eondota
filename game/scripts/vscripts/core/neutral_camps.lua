_G.NeutralCamps = NeutralCamps or {}

DRAGON_BUFFS = {
	"modifier_shrine_buff_arcane",
	"modifier_shrine_buff_frenzy",
	"modifier_shrine_buff_catastrophe",
	"modifier_shrine_buff_ultimate"
}

DRAGON_BUFF_COLORS = {
	["modifier_shrine_buff_arcane"] = Vector(180, 0, 180),
	["modifier_shrine_buff_frenzy"] = Vector(255, 0, 0),
	["modifier_shrine_buff_catastrophe"] = Vector(0, 255, 0),
	["modifier_shrine_buff_ultimate"] = Vector(0, 0, 255),	
}

function NeutralCamps:StartSpawning()
	self.camp_data = {
		[1] = {
			leader = "npc_dota_neutral_kobold_taskmaster",
			minion = "npc_dota_neutral_kobold",
			min_minions = 3,
			max_minions = 8,
			minimap_dummy = "npc_camp_dummy_1",
			scale = 0,
		},
		[2] = {
			leader = "npc_dota_neutral_alpha_wolf",
			minion = "npc_dota_neutral_giant_wolf",
			min_minions = 1,
			max_minions = 3,
			minimap_dummy = "npc_camp_dummy_2",
			scale = 15,
		},
		[3] = {
			leader = "npc_dota_neutral_enraged_wildkin",
			minion = "npc_dota_neutral_wildkin",
			min_minions = 3,
			max_minions = 5,
			minimap_dummy = "npc_camp_dummy_3",
			scale = 30,
		},
		[4] = {
			leader = "npc_dota_neutral_prowler_shaman",
			min_leaders = 1,
			max_leaders = 3,
			minimap_dummy = "npc_camp_dummy_4",
			scale = 45,
		},
		[5] = {
			leader = "npc_dota_neutral_black_dragon",
			minion = "npc_dota_neutral_black_drake",
			min_minions = 2,
			max_minions = 4,
			respawn_time = DRAGON_RESPAWN_TIME,
			minimap_dummy = "npc_camp_dummy_5",
			scale = 60,
		},
	}

	Timers:CreateTimer(NEUTRAL_CREEP_FIRST_SPAWN_TIME, function()
		for level = 1, 4 do
			for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
				NeutralCamp(camp_location:GetAbsOrigin(), false, self.camp_data[level])
			end
		end
	end)

	Timers:CreateTimer(DRAGON_SPAWN_TIME, function()
		for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_5")) do
			NeutralCamp(camp_location:GetAbsOrigin(), true, self.camp_data[5])
		end
	end)
end



if NeutralCamp == nil then NeutralCamp = class({
	min_leaders = 1,
	max_leaders = 1,
	min_minions = 0,
	max_minions = 0,
	respawn_time = NEUTRAL_CREEP_RESPAWN_TIME
}) end

function NeutralCamp:constructor(location, is_dragon, data)
	self.location = location
	self.is_dragon = is_dragon
	self.leader = data.leader
	self.minion = data.minion
	self.minimap_dummy = data.minimap_dummy
	self.scale = data.scale
	self.min_leaders = data.min_leaders or self.min_leaders
	self.max_leaders = data.max_leaders or self.max_leaders
	self.min_minions = data.min_minions or self.min_minions
	self.max_minions = data.max_minions or self.max_minions
	self.respawn_time = data.respawn_time or self.respawn_time
	self.creeps = {}

	self.dummy = CreateUnitByName(self.minimap_dummy, self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
	self.dummy:AddNewModifier(self.dummy, nil, "modifier_dummy_state", {})

	self:Spawn()
end

function NeutralCamp:Spawn()
	self.creeps = {}

	self.dummy:RemoveModifierByName("modifier_not_on_minimap")

	local leader_count = RandomInt(self.min_leaders, self.max_leaders)
	local minion_count = RandomInt(self.min_minions, self.max_minions)

	if self.is_dragon then
		self.dragon_buff = DRAGON_BUFFS[RandomInt(1, 4)]
		self.dragon_color = DRAGON_BUFF_COLORS[self.dragon_buff]
	end

	for i = 1, leader_count do
		local creep = CreateUnitByName(self.leader, self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
		creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
		creep.camp = self

		table.insert(self.creeps, creep)

		if self.dragon_color then creep:SetRenderColor(self.dragon_color.x, self.dragon_color.y, self.dragon_color.z) end 
	end

	if minion_count > 0 then
		local direction = self.location + RandomVector(110)

		for i = 1, minion_count do
			local minion_loc = RotatePosition(self.location, QAngle( 0, (i - 1) * 360 / minion_count, 0 ), direction)
			local creep = CreateUnitByName(self.minion, minion_loc, true, nil, nil, DOTA_TEAM_NEUTRALS)
			creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
			creep.camp = self

			table.insert(self.creeps, creep)

			if self.dragon_color then creep:SetRenderColor(self.dragon_color.x, self.dragon_color.y, self.dragon_color.z) end 
		end
	end
end

function NeutralCamp:OnCreepDied(killer)
	local camp_clear = true

	for _, creep in pairs(self.creeps) do
		if creep and (not creep:IsNull()) and creep:IsAlive() then
			camp_clear = false
		end
	end

	if camp_clear then
		if self.is_dragon then
			self:ApplyDragonBuff(killer:GetTeam())
		end

		self.dummy:AddNewModifier(self.dummy, nil, "modifier_not_on_minimap", {})

		Timers:CreateTimer(self.respawn_time, function()
			self:Spawn()
		end)
	end
end

function NeutralCamp:ApplyDragonBuff(team)
	local handicap = ScoreManager:GetHandicap(team)

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:GetTeam() == team then
			hero:AddNewModifier(hero, nil, self.dragon_buff, {duration = DRAGON_BUFF_DURATION, handicap = handicap})
		end
	end
end