_G.NeutralCamps = NeutralCamps or {}

DRAGON_BUFFS = {
	--"modifier_shrine_buff_arcane",
	--"modifier_shrine_buff_frenzy",
	--"modifier_shrine_buff_catastrophe",
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
	["npc_dota_neutral_kobold"] = 20,
	["npc_dota_neutral_kobold_taskmaster"] = 34,
	["npc_dota_neutral_giant_wolf"] = 118,
	["npc_dota_neutral_alpha_wolf"] = 146,
	["npc_dota_neutral_wildkin"] = 60,
	["npc_dota_neutral_enraged_wildkin"] = 159,
	["npc_dota_neutral_prowler_shaman"] = 400,
	["npc_eon_speed_beast"] = 400,
	["npc_eon_treasure_goblin"] = 400,
	["npc_dota_neutral_black_drake"] = 290,
	["npc_dota_neutral_black_dragon"] = 584,
	["npc_eon_knight"] = 400,
	["npc_eon_samurai_knight"] = 400,
	["npc_eon_trio_knight"] = 400,
	["npc_eon_roshan"] = 0,
}

GOBLIN_DROPS = {
	"item_goblin_bkb",
	"item_goblin_sheepstick",
	"item_goblin_blink",
	"item_goblin_dagon",
	"item_goblin_cyclone"
}

DRAGON_KILLS = {}
DRAGON_KILLS[DOTA_TEAM_GOODGUYS] = 0
DRAGON_KILLS[DOTA_TEAM_BADGUYS] = 0

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
		[6] = {
			leader = "npc_eon_samurai_knight",
			min_leaders = 1,
			max_leaders = 1,
			respawn_time = DRAGON_RESPAWN_TIME,
			minimap_dummy = "npc_camp_dummy_4",
			scale = 0,
		},
		[7] = {
			leader = "npc_eon_trio_knight",
			min_leaders = 3,
			max_leaders = 3,
			respawn_time = DRAGON_RESPAWN_TIME,
			minimap_dummy = "npc_camp_dummy_5",
			scale = 0,
		},
		[8] = {
			leader = "npc_eon_knight",
			min_leaders = 3,
			max_leaders = 3,
			respawn_time = DRAGON_RESPAWN_TIME,
			minimap_dummy = "npc_camp_dummy_5",
			scale = 0,
		},
		[9] = {
			leader = "npc_eon_treasure_goblin",
			min_leaders = 1,
			max_leaders = 1,
			minimap_dummy = "npc_camp_dummy_4",
			scale = 3,
		}
	}

	Timers:CreateTimer(NEUTRAL_CREEP_FIRST_SPAWN_TIME, function()
		for level = 1, 4 do
			for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
				NeutralCamp(camp_location:GetAbsOrigin(), false, false, false, self.camp_data[level])
			end
		end

		for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_9")) do
			NeutralCamp(camp_location:GetAbsOrigin(), false, false, false, self.camp_data[9])
		end
	end)

	self.dragon_camps = {}

	Timers:CreateTimer(DRAGON_SPAWN_TIME, function()
		for level = 5, 8 do
			for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
				if level == 5 then
					table.insert(self.dragon_camps, NeutralCamp(camp_location:GetAbsOrigin(), true, false, false, self.camp_data[level]))
				else
					NeutralCamp(camp_location:GetAbsOrigin(), false, true, false, self.camp_data[level])
				end
			end
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

function NeutralCamp:constructor(location, is_dragon, is_knight, is_roshan, data)
	self.location = location
	self.is_dragon = is_dragon
	self.is_knight = is_knight
	self.is_samurai = data.leader == "npc_eon_samurai_knight"
	self.is_trio_knight = data.leader == "npc_eon_trio_knight"
	self.is_roshan = is_roshan
	self.is_demon = data.leader == "npc_eon_treasure_goblin"
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
	local minion_count = self.min_minions + math.floor((self.max_minions - self.min_minions) * math.min(1, GameClock:GetActualGameTime() / (60 * NEUTRAL_CREEP_SCALING_LIMIT)))

	if self.is_dragon then
		self.dragon_buff = DRAGON_BUFFS[RandomInt(1, 1)]
	end

	for i = 1, leader_count do
		local creep = CreateUnitByName(self.leader, self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
		creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
		creep.camp = self

		if self.is_demon then creep:AddNewModifier(creep, nil, "modifier_treasure_goblin_state", {time = GameClock:GetActualGameTime()}) end

		table.insert(self.creeps, creep)
	end

	if minion_count > 0 then
		local direction = self.location + RandomVector(110)

		for i = 1, minion_count do
			local minion_loc = RotatePosition(self.location, QAngle( 0, (i - 1) * 360 / minion_count, 0 ), direction)
			local creep = CreateUnitByName(self.minion, minion_loc, true, nil, nil, DOTA_TEAM_NEUTRALS)
			creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
			creep.camp = self

			table.insert(self.creeps, creep)
		end
	end
end

function NeutralCamp:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	for _, creep in pairs(self.creeps) do
		if creep and (not creep:IsNull()) and creep:IsAlive() then
			camp_clear = false
		end
	end

	if camp_clear then
		if self.is_roshan then
			local roshan_drop = CreateItem("item_ultimate_scepter_roshan", nil, nil)
			CreateItemOnPositionForLaunch(killed_unit:GetAbsOrigin(), roshan_drop)
			PassiveGold:GiveGoldToPlayersInTeam(team, ROSHAN_GOLD_BOUNTY, 0)
		end

		if self.is_dragon then
			GlobalMessages:NotifyDragon(team)
			DRAGON_KILLS[team] = DRAGON_KILLS[team] + 1
			DragonCoin(killed_unit:GetAbsOrigin(), self.dragon_buff)
		end

		if self.is_knight or self.is_samurai or self.is_trio_knight then
			self:SpawnKnightsForTeam(team)
		end

		if self.is_demon then
			killer:AddNewModifier(killer, nil, "modifier_shrine_buff_catastrophe", {duration = CATASTROPHE_BUFF_DURATION})
			-- local random_item = GOBLIN_DROPS[RandomInt(1, 5)]

			-- if random_item == "item_goblin_blink" then
			-- 	if killer:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
			-- 		random_item = "item_goblin_blink_str"
			-- 	elseif killer:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
			-- 		random_item = "item_goblin_blink_agi"
			-- 	elseif killer:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
			-- 		random_item = "item_goblin_blink_int"
			-- 	end
			-- end

			-- if random_item == "item_goblin_dagon" then
			-- 	local dagon_level = math.min(5, math.floor(1 + GameClock:GetActualGameTime() / 180))
			-- 	random_item = "item_goblin_dagon_"..dagon_level
			-- end

			-- local goblin_drop = CreateItem(random_item, nil, nil)
			-- CreateItemOnPositionForLaunch(killed_unit:GetAbsOrigin(), goblin_drop)
			-- goblin_drop:LaunchLootInitialHeight(false, 0, 300, 0.3, killer:GetAbsOrigin())
			-- goblin_drop.is_goblin_item = true
		end

		if self.is_samurai then
			local item_drop = CreateItem("item_knight_blink", nil, nil)
			local drop = CreateItemOnPositionForLaunch(killed_unit:GetAbsOrigin(), item_drop)
			drop:SetModelScale(2.25)
			item_drop:LaunchLootInitialHeight(false, 0, 300, 0.3, killer:GetAbsOrigin())
		end

		self.dummy:AddNewModifier(self.dummy, nil, "modifier_not_on_minimap", {})

		if self.is_dragon and (DRAGON_KILLS[DOTA_TEAM_GOODGUYS] >= 2 or DRAGON_KILLS[DOTA_TEAM_BADGUYS] >= 2) then
			for _, dragon_camp in pairs(NeutralCamps.dragon_camps) do
				dragon_camp:ConvertToRoshanCamp()

				if self == dragon_camp then
					Timers:CreateTimer(self.respawn_time, function()
						self:Spawn()
					end)
				else
					dragon_camp:Spawn()
				end
			end
		else
			Timers:CreateTimer(self.respawn_time, function()
				self:Spawn()
			end)
		end
	end

	local bounty = NEUTRAL_GOLD_BOUNTY[killed_unit:GetUnitName()]

	if bounty > 0 then PassiveGold:GiveGoldFromPickup(killer, bounty) end
end

function NeutralCamp:SpawnKnightsForTeam(team)
	if self.is_samurai then
		GlobalMessages:NotifySamurai(team)
		LaneCreeps:SpawnKnightWave(team, 1, "npc_eon_samurai_knight_ally")
	elseif self.is_trio_knight then
		GlobalMessages:NotifyKnights(team)
		LaneCreeps:SpawnKnightWave(team, 3, "npc_eon_trio_knight_ally")
	else
		GlobalMessages:NotifyKnights(team)
		LaneCreeps:SpawnKnightWave(team, 3, "npc_eon_knight_ally")
	end
end

function NeutralCamp:ConvertToRoshanCamp()
	self.is_roshan = true
	self.is_dragon = false
	self.leader = "npc_eon_roshan"
	self.minion = nil
	self.min_minions = 0
	self.max_minions = 0
	self.min_leaders = 1
	self.max_leaders = 1

	self.dummy:AddNewModifier(self.dummy, nil, "modifier_not_on_minimap", {})

	for _, creep in pairs(self.creeps) do
		if creep and (not creep:IsNull()) and creep:IsAlive() then
			creep:Destroy()
			UTIL_Remove(creep)
		end
	end
end



if NeutralCoin == nil then NeutralCoin = class({
	value = 0,
}) end

function NeutralCoin:constructor(location, value)
	self.gold_drop = CreateItem("item_neutral_gold", nil, nil)
	self.value = value

	self.location = location
	self.drop = CreateItemOnPositionForLaunch(location, self.gold_drop)

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

	Timers:CreateTimer(GOLD_COIN_DURATION, function()
		if self.gold_drop and self.drop and (not (self.drop:IsNull() or self.gold_drop:IsNull())) then
			self.gold_drop:Destroy()
			self.drop:Destroy()
			self.trigger:Stop()
		end
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

	self.location = location + RandomVector(RandomFloat(400, 500))
	self.drop = CreateItemOnPositionForLaunch(location, self.gold_drop)
	self.drop:SetModelScale(2.0)
	self.gold_drop:LaunchLootInitialHeight(false, 0, 550, 0.75, self.location)

	Timers:CreateTimer(0.75, function()
		GridNav:DestroyTreesAroundPoint(self.location, 175, true)

		self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
			radius = 175
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
		self:ApplyDragonBuff(units[1])

		self.gold_drop:Destroy()
		self.drop:Destroy()
		self.trigger:Stop()
	end
end

function DragonCoin:ApplyDragonBuff(unit)
	local team = unit:GetTeam()
	local stacks = 1

	if DRAGON_KILLS[team] >= 2 then stacks = 2 end

	unit:EmitSound("Shrine.Capture")

	local shockwave_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(shockwave_pfx, 0, unit:GetAbsOrigin())
	ParticleManager:SetParticleControl(shockwave_pfx, 1, Vector(50, 50, 225))
	ParticleManager:ReleaseParticleIndex(shockwave_pfx)

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:GetTeam() == team then
			hero:RemoveModifierByName(self.buff_name)
			hero:AddNewModifier(hero, nil, self.buff_name, {duration = DRAGON_BUFF_DURATION, stacks = stacks})
		end
	end
end