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

DRAGON_BUFF_DROPS = {
	["modifier_shrine_buff_arcane"] = "item_dragon_drop_arcane",
	["modifier_shrine_buff_frenzy"] = "item_dragon_drop_frenzy",
	["modifier_shrine_buff_catastrophe"] = "item_dragon_drop_catastrophe",
	["modifier_shrine_buff_ultimate"] = "item_dragon_drop_ultimate",
}

NEUTRAL_GOLD_BOUNTY = {
	["npc_dota_neutral_kobold"] = 11,
	["npc_dota_neutral_kobold_taskmaster"] = 34,
	["npc_dota_neutral_giant_wolf"] = 73,
	["npc_dota_neutral_alpha_wolf"] = 118,
	["npc_dota_neutral_wildkin"] = 45,
	["npc_dota_neutral_enraged_wildkin"] = 159,
	["npc_dota_neutral_prowler_shaman"] = 325,
	["npc_dota_neutral_black_drake"] = 195,
	["npc_dota_neutral_black_dragon"] = 584,
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

function NeutralCamp:OnNeutralCreepDied(killer, killed_unit)
	local camp_clear = true

	for _, creep in pairs(self.creeps) do
		if creep and (not creep:IsNull()) and creep:IsAlive() then
			camp_clear = false
		end
	end

	if camp_clear then
		if self.is_dragon then
			DragonCoin(killed_unit:GetAbsOrigin(), self.dragon_buff)
		end

		self.dummy:AddNewModifier(self.dummy, nil, "modifier_not_on_minimap", {})

		Timers:CreateTimer(self.respawn_time, function()
			self:Spawn()
		end)
	end

	NeutralCoin(killed_unit:GetAbsOrigin(), NEUTRAL_GOLD_BOUNTY[killed_unit:GetUnitName()])
end



if NeutralCoin == nil then NeutralCoin = class({
	value = 0,
}) end

function NeutralCoin:constructor(location, value)
	self.gold_drop = CreateItem("item_neutral_gold", nil, nil)
	self.value = value

	self.location = location + RandomVector(RandomFloat(150, 200))
	self.drop = CreateItemOnPositionForLaunch(location, self.gold_drop)
	self.gold_drop:LaunchLootInitialHeight(false, 0, 300, 0.4, self.location)

	Timers:CreateTimer(0.4, function()
		self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
			radius = 128
		}, {
			trigger_team = DOTA_TEAM_NEUTRALS,
			team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
			unit_filter = DOTA_UNIT_TARGET_HERO,
			flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		}, function(units)
			self:OnHeroInRange(units)
		end, {})
	end)
end

function NeutralCoin:OnHeroInRange(units)
	if units[1] then
		PassiveGold:GiveGoldFromPickup(units[1], self.value)

		self.gold_drop:Destroy()
		self.drop:Destroy()
		self.trigger:Stop()
	end
end



if DragonCoin == nil then DragonCoin = class({
	buff_name = "modifier_shrine_buff_arcane",
}) end

function DragonCoin:constructor(location, buff_name)
	self.buff_name = buff_name
	self.gold_drop = CreateItem(DRAGON_BUFF_DROPS[self.buff_name], nil, nil)

	self.location = location + RandomVector(RandomFloat(150, 200))
	self.drop = CreateItemOnPositionForLaunch(location, self.gold_drop)
	self.gold_drop:LaunchLootInitialHeight(false, 0, 300, 0.4, self.location)

	Timers:CreateTimer(0.4, function()
		self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
			radius = 128
		}, {
			trigger_team = DOTA_TEAM_NEUTRALS,
			team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
			unit_filter = DOTA_UNIT_TARGET_HERO,
			flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		}, function(units)
			self:OnHeroInRange(units)
		end, {})
	end)
end

function DragonCoin:OnHeroInRange(units)
	if units[1] then
		self:ApplyDragonBuff(units[1]:GetTeam())

		self.gold_drop:Destroy()
		self.drop:Destroy()
		self.trigger:Stop()
	end
end

function DragonCoin:ApplyDragonBuff(team)
	local handicap = ScoreManager:GetHandicap(team)

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:GetTeam() == team then
			hero:AddNewModifier(hero, nil, self.buff_name, {duration = DRAGON_BUFF_DURATION, handicap = handicap})
		end
	end
end