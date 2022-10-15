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
	["npc_dota_neutral_kobold_taskmaster"] = 35,
	["npc_dota_neutral_giant_wolf"] = 120,
	["npc_dota_neutral_alpha_wolf"] = 150,
	["npc_dota_neutral_wildkin"] = 100,
	["npc_dota_neutral_enraged_wildkin"] = 250,
	["npc_dota_neutral_prowler_shaman"] = 600,
	["npc_eon_speed_beast"] = 400,
	["npc_eon_treasure_goblin"] = 400,
	["npc_dota_neutral_black_drake"] = 250,
	["npc_dota_neutral_black_dragon"] = 700,
	["npc_eon_knight"] = 300,
	["npc_eon_lesser_samurai"] = 180,
	["npc_eon_samurai_knight"] = 700,
	["npc_eon_trio_knight"] = 300,
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
	self.jungle_attack_routes = {}
	self.jungle_attack_routes[DOTA_TEAM_GOODGUYS] = {}
	self.jungle_attack_routes[DOTA_TEAM_BADGUYS] = {}

	for step = 1, 8 do
		local next_radiant_position = Entities:FindByName(nil, "radiant_jungle_attack_route_"..step)
		local next_dire_position = Entities:FindByName(nil, "dire_jungle_attack_route_"..step)

		if next_radiant_position then table.insert(self.jungle_attack_routes[DOTA_TEAM_GOODGUYS], next_radiant_position:GetAbsOrigin()) end
		if next_dire_position then table.insert(self.jungle_attack_routes[DOTA_TEAM_BADGUYS], next_dire_position:GetAbsOrigin()) end
	end

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
			respawn_time = 80,
			minimap_dummy = "npc_camp_dummy_3",
			scale = 30,
		},
		[4] = {
			leader = "npc_dota_neutral_prowler_shaman",
			min_leaders = 1,
			max_leaders = 1,
			minimap_dummy = "npc_camp_dummy_4",
			scale = 10,
		},
		[5] = {
			leader = "npc_dota_neutral_black_dragon",
			minion = "npc_dota_neutral_black_drake",
			min_minions = 2,
			max_minions = 4,
			respawn_time = DRAGON_RESPAWN_TIME,
			minimap_dummy = "npc_camp_dummy_5",
			scale = 50,
		},
		[6] = {
			leader = "npc_eon_lesser_samurai",
			min_leaders = 3,
			max_leaders = 3,
			respawn_time = 90,
			minimap_dummy = "npc_camp_dummy_4",
			scale = 0,
		},
		[7] = {
			leader = "npc_eon_samurai_knight",
			min_leaders = 1,
			max_leaders = 1,
			respawn_time = DRAGON_RESPAWN_TIME,
			minimap_dummy = "npc_camp_dummy_6",
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
		for level = 1, 6 do
			for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
				NeutralCamp(camp_location:GetAbsOrigin(), self.camp_data[level])
			end
		end
	end)

	self.dragon_camps = {}

	Timers:CreateTimer(DRAGON_SPAWN_TIME, function()
		-- for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_5")) do
		-- 	table.insert(self.dragon_camps, NeutralCamp(camp_location:GetAbsOrigin(), self.camp_data[5]))
		-- end

		for level = 7, 9 do
			for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
				NeutralCamp(camp_location:GetAbsOrigin(), self.camp_data[level])
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

function NeutralCamp:constructor(location, data)
	self.location = location
	self.is_dragon = data.leader == "npc_dota_neutral_black_dragon"
	self.is_knight = data.leader == "npc_eon_knight"
	self.is_samurai = data.leader == "npc_eon_samurai_knight"
	self.is_trio_knight = data.leader == "npc_eon_trio_knight"
	self.is_roshan = is_roshan
	self.is_demon = data.leader == "npc_eon_treasure_goblin"
	self.is_portal = data.leader == "npc_dota_neutral_prowler_shaman"
	self.is_greevil = data.leader == "npc_eon_lesser_samurai"
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
		if self.is_greevil then creep:AddNewModifier(creep, nil, "modifier_treasure_goblin_state", {}) end
		if self.is_portal then creep:AddNewModifier(creep, nil, "modifier_portal_creep_state", {}) end

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

		if self.is_knight or self.is_trio_knight then
			self:SpawnKnightsForTeam(team)

			-- local book_drop = CreateItem("item_knight_book", nil, nil)
			-- local drop = CreateItemOnPositionForLaunch(killed_unit:GetAbsOrigin(), book_drop)
			-- drop:SetModelScale(2.0)
			-- book_drop:LaunchLootInitialHeight(false, 0, 300, 0.4, killer:GetAbsOrigin())
		end

		if self.is_demon then
			if IS_EXPERIMENTAL_MAP then
				local potion_drop = CreateItem("item_catastrophe_potion", nil, nil)
				CreateItemOnPositionForLaunch(killed_unit:GetAbsOrigin(), potion_drop)
				potion_drop:LaunchLootInitialHeight(false, 0, 300, 0.4, killer:GetAbsOrigin())
			else
				killer:AddNewModifier(killer, nil, "modifier_shrine_buff_arcane", {duration = DEMON_BUFF_DURATION})
			end
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

		if self.is_portal then
			self:SpawnPortal()
		end

		if killer:IsRealHero() and self.is_samurai then
			GlobalMessages:NotifySamurai(team)
			Timers:CreateTimer(1.0, function() killer:AddNewModifier(killer, nil, "modifier_major_stealth_buff", {duration = MAJOR_STEALTH_BUFF_DURATION}) end)
		end

		if IS_NEW_EXPERIMENTAL_MAP and self.is_greevil or self.is_samurai then
			local enemy_tower = Towers:GetTeamJungleTower(ENEMY_TEAM[team])

			if enemy_tower and enemy_tower.location and (enemy_tower.location - self.location):Length2D() < 3000 then
				self:SpawnJungleAttackers(team, enemy_tower)
			end
		end

		self.dummy:AddNewModifier(self.dummy, nil, "modifier_not_on_minimap", {})

		if self.is_dragon and (DRAGON_KILLS[DOTA_TEAM_GOODGUYS] >= DRAGON_MAX_KILLS or DRAGON_KILLS[DOTA_TEAM_BADGUYS] >= DRAGON_MAX_KILLS) then
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
		elseif self.is_portal then
			
		else
			Timers:CreateTimer(self.respawn_time, function()
				self:Spawn()
			end)
		end
	end

	local bounty = NEUTRAL_GOLD_BOUNTY[killed_unit:GetUnitName()]

	if bounty > 0 then
		if killer:IsHero() then
			PassiveGold:GiveGoldFromPickup(killer, bounty)
		elseif killer:HasModifier("modifier_jungle_attacker") then
			PassiveGold:GiveGoldToPlayersInTeam(team, bounty / 5, 0)
		end
	end
end

function NeutralCamp:SpawnPortal()
	if self.portal then
		self.portal:ActivateForTeam(self.portal_team)
		self.portal:ActivateForTeam(ENEMY_TEAM[self.portal_team])
	end
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

function NeutralCamp:SpawnJungleAttackers(team, tower)
	for i = 1, self.max_leaders do
		local creep = CreateUnitByName(self.leader.."_attacker", self.location, true, nil, nil, team)

		creep:AddNewModifier(creep, nil, "modifier_jungle_attacker", {})
		creep:AddNewModifier(creep, nil, "modifier_kill", {duration = 90})

		Timers:CreateTimer(i, function()

			local creep_id = creep:entindex()

			if tower and tower.unit and tower.location and (not tower.unit:IsNull()) and tower.unit:IsAlive() then
				ExecuteOrderFromTable({
					unitIndex = creep_id,
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = tower.location,
					Queue = true
				})
			end

			for _, route_step in pairs(NeutralCamps.jungle_attack_routes[team]) do
				ExecuteOrderFromTable({
					unitIndex = creep_id,
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = route_step,
					Queue = true
				})
			end
		end)
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
	local stacks = math.min(DRAGON_KILLS[team], DRAGON_MAX_KILLS)

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