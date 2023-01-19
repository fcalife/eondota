_G.RespawnManager = RespawnManager or {}

SHRINE_UPDATE_RATE = 0.03
SHRINE_CAPTURE_TIME = 7

SHRINE_PROGRESS_TICK = SHRINE_UPDATE_RATE / SHRINE_CAPTURE_TIME

SHRINE_CAPTURE_ZONE_RADIUS = 350

SHRINE_STATE_GUARDIANS_ALIVE = 1
SHRINE_STATE_NEUTRAL = 2
SHRINE_STATE_DISPUTED = 3
SHRINE_STATE_CAPTURED = 4

SHRINE_BASE_COLOR = Vector(50, 50, 50)

SHRINE_TEAM_COLOR = {
	[DOTA_TEAM_GOODGUYS] = Vector(140, 140, 400),
	[DOTA_TEAM_BADGUYS]  = Vector(400, 140, 140),
	[DOTA_TEAM_CUSTOM_1]  = Vector(140, 400, 140),
	[DOTA_TEAM_CUSTOM_2]  = Vector(400, 140, 400),
	[DOTA_TEAM_CUSTOM_3] = Vector(50, 50, 50)
}

CRYSTAL_TEAM_COLOR = {
	[DOTA_TEAM_GOODGUYS] = Vector(0, 0, 1),
	[DOTA_TEAM_BADGUYS]  = Vector(1, 0, 0),
	[DOTA_TEAM_CUSTOM_1]  = Vector(0, 1, 0),
	[DOTA_TEAM_CUSTOM_2]  = Vector(1, 0, 1),
	[DOTA_TEAM_CUSTOM_3]  = Vector(0.5, 0.5, 0.5),
}

local PLAYER_TEAMS = {
	DOTA_TEAM_GOODGUYS,
	DOTA_TEAM_BADGUYS,
	DOTA_TEAM_CUSTOM_1,
	DOTA_TEAM_CUSTOM_2
}

function RespawnManager:Init()
	local initial_respawn_points = Entities:FindAllByName("spawn_outpost")

	for key, respawn_point in pairs(initial_respawn_points) do
		initial_respawn_points[key] = respawn_point:GetAbsOrigin()
	end

	local shuffled_respawns = table.shuffled(initial_respawn_points)

	self.all_outposts = {}

	table.insert(self.all_outposts, SpawnOutpost(DOTA_TEAM_GOODGUYS, table.remove(shuffled_respawns)))
	table.insert(self.all_outposts, SpawnOutpost(DOTA_TEAM_BADGUYS, table.remove(shuffled_respawns)))
	table.insert(self.all_outposts, SpawnOutpost(DOTA_TEAM_CUSTOM_1, table.remove(shuffled_respawns)))
	table.insert(self.all_outposts, SpawnOutpost(DOTA_TEAM_CUSTOM_2, table.remove(shuffled_respawns)))

	for _, spawn_point in pairs(Entities:FindAllByName("neutral_outpost")) do
		table.insert(self.all_outposts, NeutralOutpost(spawn_point:GetAbsOrigin()))
	end

	self:UpdateRespawnForTeam(DOTA_TEAM_GOODGUYS)
	self:UpdateRespawnForTeam(DOTA_TEAM_BADGUYS)
	self:UpdateRespawnForTeam(DOTA_TEAM_CUSTOM_1)
	self:UpdateRespawnForTeam(DOTA_TEAM_CUSTOM_2)
end

function RespawnManager:FindTeamRespawnPosition(team)
	local current_outpost = nil
	local current_distance = 99999

	for _, outpost in pairs(self.all_outposts) do
		if outpost:GetTeam() == team then
			local outpost_distance = outpost:GetCenterDistance()

			if outpost_distance < current_distance then
				current_outpost = outpost
				current_distance = outpost_distance
			end
		end
	end

	if current_outpost then return current_outpost:GetPosition() end
end

function RespawnManager:UpdateRespawnForTeam(team)
	local team_respawn_position = self:FindTeamRespawnPosition(team)

	GridNav:DestroyTreesAroundPoint(team_respawn_position, 250, true)

	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		if hero:GetTeam() == team then
			hero:SetRespawnPosition(team_respawn_position)
		end
	end
end

function RespawnManager:RespawnAllHeroes()
	self:UpdateRespawnForTeam(DOTA_TEAM_GOODGUYS)
	self:UpdateRespawnForTeam(DOTA_TEAM_BADGUYS)
	self:UpdateRespawnForTeam(DOTA_TEAM_CUSTOM_1)
	self:UpdateRespawnForTeam(DOTA_TEAM_CUSTOM_2)

	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		hero:RespawnHero(false, false)
		CenterPlayerCameraOnHero(hero)
		ResolveNPCPositions(hero:GetAbsOrigin(), 128)
		hero:InterruptChannel()
	end
end

function RespawnManager:DestroyUnusedOutposts()
	local all_heroes = HeroList:GetAllHeroes()
	local team_is_present = {
		[DOTA_TEAM_GOODGUYS] = false,
		[DOTA_TEAM_BADGUYS] = false,
		[DOTA_TEAM_CUSTOM_1] = false,
		[DOTA_TEAM_CUSTOM_2] = false
	}

	for _, hero in pairs(all_heroes) do
		team_is_present[hero:GetTeam()] = true
	end

	for _, outpost in pairs(self.all_outposts) do
		if outpost:IsTeamBase() and (not team_is_present[outpost:GetTeam()]) then
			outpost:Destroy()
		else
			if (not outpost:IsTeamBase()) then
				outpost:SpawnGuardians()
			end

			outpost:ActivateVisuals()
		end
	end
end





if SpawnOutpost == nil then SpawnOutpost = class({}) end

function SpawnOutpost:constructor(team, location)
	self.location = GetGroundPosition(location, nil)
	self.team = team

	self.unit = CreateUnitByName("npc_base_outpost", self.location, false, nil, nil, team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_not_on_minimap_for_enemies", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_outpost_state", {})

	self.unit:FindAbilityByName("ability_outpost_defense"):SetLevel(1)

	self.unit:SetRenderColor(SHRINE_TEAM_COLOR[team].x, SHRINE_TEAM_COLOR[team].y, SHRINE_TEAM_COLOR[team].z)

	self.thinker = CreateModifierThinker(nil, nil, "modifier_fountain_outpost_thinker", {}, self.location, team, false)
	self.defense_thinker = CreateModifierThinker(nil, nil, "modifier_fountain_outpost_thinker", {}, self.location, team, false)
end

function SpawnOutpost:ActivateVisuals()
	self.crystal_pfx = ParticleManager:CreateParticle("particles/neutral_outpost_crystal.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.crystal_pfx, 0, self.location)

	self.vision = AddFOWViewer(self.team, self.location, 1800, 9999, false)
end

function SpawnOutpost:GetTeam()
	return self.team
end

function SpawnOutpost:GetCenterDistance()
	return (self.location - Vector(0, 0, 0)):Length2D()
end

function SpawnOutpost:GetPosition()
	return self.location
end

function SpawnOutpost:IsTeamBase()
	return true
end

function SpawnOutpost:Destroy()
	if self.unit then self.unit:Destroy() end

	if self.thinker then self.thinker:Destroy() end

	if self.vision then RemoveFOWViewer(self.team, self.vision) end
end



if NeutralOutpost == nil then NeutralOutpost = class({
	state = SHRINE_STATE_GUARDIANS_ALIVE,
	radius = SHRINE_CAPTURE_ZONE_RADIUS,
	current_team = DOTA_TEAM_CUSTOM_3,
	current_color = SHRINE_TEAM_COLOR[DOTA_TEAM_CUSTOM_3],
	progress = 0,
}) end

function NeutralOutpost:constructor(location)
	self.location = GetGroundPosition(location, nil)

	self.unit = CreateUnitByName("npc_neutral_outpost", self.location, false, nil, nil, DOTA_TEAM_CUSTOM_3)
	self.unit:AddNewModifier(self.unit, nil, "modifier_not_on_minimap_for_enemies", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_outpost_state", {})

	self.unit:FindAbilityByName("ability_outpost_defense"):SetLevel(1)

	self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
		radius = self.radius
	}, {
		trigger_team = DOTA_TEAM_CUSTOM_3,
		team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	}, function(units)
		self:OnUnitsInRange(units)
	end,
	{})
end

function NeutralOutpost:ActivateVisuals()
	self.crystal_pfx = ParticleManager:CreateParticle("particles/base_outpost_crystal.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.crystal_pfx, 0, self.location)
	ParticleManager:SetParticleControl(self.crystal_pfx, 1, CRYSTAL_TEAM_COLOR[self.current_team])
end

function NeutralOutpost:GetTeam()
	return self.current_team
end

function NeutralOutpost:GetCenterDistance()
	return (self.location - Vector(0, 0, 0)):Length2D()
end

function NeutralOutpost:GetPosition()
	return self.location
end

function NeutralOutpost:IsTeamBase()
	return false
end

function NeutralOutpost:SpawnGuardians()
	local biome = BIOME_LIST[RandomInt(1, 3)]
	local tier = 1

	if self:GetCenterDistance() < 10000 then tier = 2 end
	if self:GetCenterDistance() < 5000 then tier = 3 end

	self.creeps = {}

	self:SpawnGuardian("enemy_"..biome.."_"..tier.."_leader")

	for i = 1, 5 do self:SpawnGuardian("enemy_"..biome.."_"..tier.."_minion") end

	ResolveNPCPositions(self.location, 400)

	self.state = SHRINE_STATE_GUARDIANS_ALIVE
end

function NeutralOutpost:SpawnGuardian(unit_name)
	local creep = CreateUnitByName(unit_name, self.location + RandomVector(RandomInt(200, 350)), true, nil, nil, DOTA_TEAM_CUSTOM_3)
	creep:AddNewModifier(creep, nil, "modifier_outpost_guardian_thinker", {x = self.location.x, y = self.location.y})
	creep.outpost = self
	table.insert(self.creeps, creep)
end

function NeutralOutpost:OnCreepDied()
	for _, creep in pairs(self.creeps) do
		if creep and (not creep:IsNull()) and creep:IsAlive() then return end
	end

	self.state = SHRINE_STATE_NEUTRAL
end

function NeutralOutpost:OnUnitsInRange(units)
	if self.state == SHRINE_STATE_NEUTRAL then
		self:EndNeutralState()
		self.state = SHRINE_STATE_DISPUTED
	end

	if self.state >= SHRINE_STATE_DISPUTED then
		self:OnDisputedThink(units)
	end
end

function NeutralOutpost:EndNeutralState()
	self.capture_ring_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
	ParticleManager:SetParticleControl(self.capture_ring_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capture_ring_pfx, 9, Vector(self.radius, 0, 0))

	self.capturing_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring_capturing.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
	ParticleManager:SetParticleControl(self.capturing_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capturing_pfx, 9, Vector(self.radius, 0, 0))

	self.capture_progress_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring_clock.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 9, Vector(self.radius, 0, 0))
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 11, Vector(0, 0, 1))
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 17, Vector(0, 0, 0))
end

function NeutralOutpost:OnDisputedThink(units)
	if self.state < SHRINE_STATE_DISPUTED then return end

	local unit_count = {}

	unit_count[DOTA_TEAM_GOODGUYS] = 0
	unit_count[DOTA_TEAM_BADGUYS] = 0
	unit_count[DOTA_TEAM_CUSTOM_1] = 0
	unit_count[DOTA_TEAM_CUSTOM_2] = 0

	for _, unit in pairs(units) do
		local team = unit:GetTeam()
		unit_count[team] = (unit_count[team] and unit_count[team] + 1) or 1
	end

	local dominating_team = nil
	local at_least_one_team = false

	for _, team in pairs(PLAYER_TEAMS) do
		if unit_count[team] > 0 then
			if at_least_one_team then
				dominating_team = nil
			else
				dominating_team = team
				at_least_one_team = true
			end
		end
	end

	if (not dominating_team) then return end

	-- Progress calculation
	if self.current_team == dominating_team then
		if self.state < SHRINE_STATE_CAPTURED then
			self.progress = math.min(1, self.progress + SHRINE_PROGRESS_TICK)

			if self.progress >= 1 then
				self:OnTeamFinishCapture()
			end
		end
	else
		self.progress = math.max(0, self.progress - SHRINE_PROGRESS_TICK)

		if self.progress <= 0 then
			if self.state >= SHRINE_STATE_CAPTURED then self:OnTeamLoseShrine() end
			self.current_team = dominating_team
		end
	end

	-- Particle adjustment
	if self.progress > 0 then
		self.current_color = SHRINE_BASE_COLOR + self.progress * (SHRINE_TEAM_COLOR[self.current_team] - SHRINE_BASE_COLOR)
	else
		self.current_color = SHRINE_BASE_COLOR
	end

	if self.capture_ring_pfx then ParticleManager:SetParticleControl(self.capture_ring_pfx, 3, self.current_color) end
	if self.capturing_pfx then ParticleManager:SetParticleControl(self.capturing_pfx, 3, self.current_color) end
	if self.capture_progress_pfx then
		ParticleManager:SetParticleControl(self.capture_progress_pfx, 3, self.current_color)
		ParticleManager:SetParticleControl(self.capture_progress_pfx, 17, Vector(self.progress, 0, 0))
	end
end

function NeutralOutpost:OnTeamFinishCapture()
	self.state = SHRINE_STATE_CAPTURED

	self.unit:EmitSound("Shrine.Capture")

	self.unit:SetRenderColor(SHRINE_TEAM_COLOR[self.current_team].x, SHRINE_TEAM_COLOR[self.current_team].y, SHRINE_TEAM_COLOR[self.current_team].z)

	if self.crystal_pfx then ParticleManager:SetParticleControl(self.crystal_pfx, 1, CRYSTAL_TEAM_COLOR[self.current_team]) end

	self.unit:SetTeam(self.current_team)

	local shockwave_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(shockwave_pfx, 0, self.location)
	ParticleManager:SetParticleControl(shockwave_pfx, 1, SHRINE_TEAM_COLOR[self.current_team])
	ParticleManager:ReleaseParticleIndex(shockwave_pfx)

	self.thinker = CreateModifierThinker(nil, nil, "modifier_fountain_outpost_thinker", {}, self.location, self.current_team, false)
	self.vision = AddFOWViewer(self.current_team, self.location, 1800, 9999, false)
end

function NeutralOutpost:OnTeamLoseShrine()
	self.state = SHRINE_STATE_DISPUTED

	self.unit:EmitSound("Shrine.Capture")

	self.unit:SetRenderColor(255, 255, 255)

	self.unit:SetTeam(DOTA_TEAM_CUSTOM_3)

	if self.thinker then self.thinker:Destroy() end

	if self.vision then RemoveFOWViewer(self.current_team, self.vision) end

	if self.crystal_pfx then ParticleManager:SetParticleControl(self.crystal_pfx, 1, CRYSTAL_TEAM_COLOR[DOTA_TEAM_CUSTOM_3]) end
end