_G.NeutralCamps = NeutralCamps or {}

function NeutralCamps:StartSpawning()
	self.camp_data = {
		[1] = {
			leader = "npc_dota_neutral_kobold_taskmaster",
			minion = "npc_dota_neutral_kobold",
			min_minions = 4,
			max_minions = 4,
			minimap_dummy = "npc_camp_dummy_1",
			scale = 15,
		},
		[2] = {
			leader = "npc_dota_neutral_alpha_wolf",
			minion = "npc_dota_neutral_giant_wolf",
			min_minions = 2,
			max_minions = 2,
			minimap_dummy = "npc_camp_dummy_2",
			scale = 25,
		},
		[3] = {
			leader = "npc_dota_neutral_enraged_wildkin",
			minion = "npc_dota_neutral_wildkin",
			min_minions = 1,
			max_minions = 1,
			minimap_dummy = "npc_camp_dummy_3",
			scale = 35,
		},
	}

	Timers:CreateTimer(NEUTRAL_CREEP_FIRST_SPAWN_TIME, function()
		for level = 1, 3 do
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

	for i = 1, leader_count do
		local creep = CreateUnitByName(self.leader, self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
		creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
		creep:SetForwardVector((Vector(0, 0, 128) - self.location):Normalized())
		creep.camp = self

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
		self.dummy:AddNewModifier(self.dummy, nil, "modifier_not_on_minimap", {})

		Timers:CreateTimer(self.respawn_time, function()
			self:Spawn()
		end)
	end
end



-- function FireCamp:OnNeutralCreepDied(killer, killed_unit)
-- 	local team = killer:GetTeam()
-- 	local camp_clear = true

-- 	for _, creep in pairs(self.creeps) do
-- 		if creep and (not creep:IsNull()) and creep:IsAlive() then
-- 			camp_clear = false
-- 		end
-- 	end

-- 	if (not camp_clear) then return end

-- 	self.busy = false

-- 	local is_upgraded = killed_unit:GetUnitName() == "npc_fire_golem"

-- 	if is_upgraded then
-- 		LaneCreeps:SpawnNeutralForTeam(team, "npc_fire_golem_lane")
-- 		GlobalMessages:NotifyTeamKilledGolem(team)
-- 	end

-- 	EmitSoundOnLocationWithCaster(killed_unit:GetAbsOrigin(), "Drop.EonStone", killed_unit)

-- 	for i = 1, ((is_upgraded and 3) or 2) do
-- 		local essence_drop = CreateItem("item_fire_essence", nil, nil)
-- 		local drop = CreateItemOnPositionForLaunch(killed_unit:GetAbsOrigin(), essence_drop)
-- 		drop:SetModelScale(1.2)
-- 		essence_drop:LaunchLoot(false, RandomInt(175, 300), 0.4, killed_unit:GetAbsOrigin() + RandomVector(120))
-- 	end

-- 	GoldRewards:GiveGoldToPlayersInTeam(team, (is_upgraded and FIRE_SPIRIT_UPGRADED_GOLD) or FIRE_SPIRIT_GOLD_BOUNTY, 0)
-- 	GoldRewards:LevelupPlayersInTeam(team)

-- 	LaneCreeps:SpawnNeutralForTeam(team, killed_unit:GetUnitName().."_lane")
-- end

-- function FireCamp:SpawnWarning()
-- 	EmitGlobalSound("stone.shortwarning")

-- 	local minimap_dummy = CreateUnitByName("npc_stone_dummy", self.location, false, nil, nil, DOTA_TEAM_NEUTRALS)
-- 	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_dummy_state", {})
-- 	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_not_on_minimap", {})

-- 	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
-- 		MinimapEvent(team, minimap_dummy, self.location.x, self.location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, FIRE_SPIRIT_PRESPAWN_WARNING)
-- 	end

-- 	local warning_pfx = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
-- 	ParticleManager:SetParticleControl(warning_pfx, 0, self.location)
-- 	ParticleManager:SetParticleControl(warning_pfx, 2, Vector(1, 0.6, 0))

-- 	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.location, 400, FIRE_SPIRIT_PRESPAWN_WARNING, false)
-- 	AddFOWViewer(DOTA_TEAM_BADGUYS, self.location, 400, FIRE_SPIRIT_PRESPAWN_WARNING, false)

-- 	EmitGlobalSound("stone.countdown")

-- 	Timers:CreateTimer(FIRE_SPIRIT_PRESPAWN_WARNING, function()
-- 		ParticleManager:DestroyParticle(warning_pfx, false)
-- 		ParticleManager:ReleaseParticleIndex(warning_pfx)

-- 		StopGlobalSound("stone.countdown")
-- 		EmitGlobalSound("stone.spawn")

-- 		minimap_dummy:Destroy()

-- 		self:Spawn()
-- 	end)
-- end