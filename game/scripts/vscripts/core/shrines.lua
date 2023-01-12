_G.Shrines = Shrines or {}

SHRINE_UPDATE_RATE = 0.03
SHRINE_CAPTURE_TIME = 7

SHRINE_CAPTURE_ZONE_RADIUS = 350

SHRINE_STATE_NEUTRAL = 1
SHRINE_STATE_DISPUTED = 2
SHRINE_STATE_CAPTURED = 3

SHRINE_TYPE_FOUNTAIN = 1
SHRINE_TYPE_RESPAWN = 2
SHRINE_TYPE_VISION = 3

SHRINE_PROGRESS_TICK = SHRINE_UPDATE_RATE / SHRINE_CAPTURE_TIME

SHRINE_BASE_COLOR = Vector(50, 50, 50)

SHRINE_TEAM_COLOR = {
	[DOTA_TEAM_NEUTRALS] = Vector(50, 50, 50),
	[DOTA_TEAM_GOODGUYS] = Vector(140, 140, 400),
	[DOTA_TEAM_BADGUYS]  = Vector(400, 140, 140),
	[DOTA_TEAM_CUSTOM_1]  = Vector(140, 400, 140),
	[DOTA_TEAM_CUSTOM_2]  = Vector(400, 140, 400)
}

SHRINE_TYPE_MODELS = {
	[SHRINE_TYPE_FOUNTAIN] = "models/items/juggernaut/ward/sinister_shadow_healing_cauldron/sinister_shadow_healing_cauldron.vmdl",
	[SHRINE_TYPE_RESPAWN] = "models/props_structures/radiant_statue002.vmdl",
	[SHRINE_TYPE_VISION] = "maps/reef_assets/models/props/naga_city/darkreef_lamp.vmdl"
}

local PLAYER_TEAMS = {
	DOTA_TEAM_GOODGUYS,
	DOTA_TEAM_BADGUYS,
	DOTA_TEAM_CUSTOM_1,
	DOTA_TEAM_CUSTOM_2
}

function Shrines:Init()
	for _, spawn_point in pairs(Entities:FindAllByName("outpost_fountain")) do
		Shrine(spawn_point:GetAbsOrigin(), SHRINE_TYPE_FOUNTAIN)
	end

	for _, spawn_point in pairs(Entities:FindAllByName("outpost_respawn")) do
		Shrine(spawn_point:GetAbsOrigin(), SHRINE_TYPE_RESPAWN)
	end

	for _, spawn_point in pairs(Entities:FindAllByName("outpost_vision")) do
		Shrine(spawn_point:GetAbsOrigin(), SHRINE_TYPE_VISION)
	end
end



if Shrine == nil then Shrine = class({
	state = SHRINE_STATE_NEUTRAL,
	radius = SHRINE_CAPTURE_ZONE_RADIUS,
	current_team = DOTA_TEAM_NEUTRALS,
	current_color = SHRINE_TEAM_COLOR[DOTA_TEAM_NEUTRALS],
	progress = 0,
}) end

function Shrine:constructor(location, type)
	self.location = location
	self.type = type

	self.unit = self:FetchUnit()

	if self.type == SHRINE_TYPE_FOUNTAIN then
		self.minimap_dummy = CreateUnitByName("npc_camp_dummy_2", self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	elseif self.type == SHRINE_TYPE_RESPAWN then
		self.minimap_dummy = CreateUnitByName("npc_camp_dummy_3", self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	elseif self.type == SHRINE_TYPE_VISION then
		self.minimap_dummy = CreateUnitByName("npc_camp_dummy_1", self.location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	end

	self.minimap_dummy:AddNewModifier(self.minimap_dummy, nil, "modifier_dummy_state", {})
	self.minimap_dummy:AddNewModifier(self.minimap_dummy, nil, "modifier_not_on_minimap", {})

	self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
		radius = self.radius
	}, {
		trigger_team = DOTA_TEAM_NEUTRALS,
		team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	}, function(units)
		self:OnUnitsInRange(units)
	end,
	{})
end

function Shrine:FetchUnit()
	local nearby_entity = Entities:FindByModelWithin(nil, SHRINE_TYPE_MODELS[self.type], self.location, 350)

	return nearby_entity
end

function Shrine:OnUnitsInRange(units)
	if self.state == SHRINE_STATE_NEUTRAL then
		self:EndNeutralState()
		self.state = SHRINE_STATE_DISPUTED
	end

	if self.state >= SHRINE_STATE_DISPUTED then
		self:OnDisputedThink(units)
	end
end

function Shrine:EndNeutralState()
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

function Shrine:OnDisputedThink(units)
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

function Shrine:OnTeamFinishCapture()
	self.state = SHRINE_STATE_CAPTURED

	self.unit:EmitSound("Shrine.Capture")

	self.unit:SetRenderColor(SHRINE_TEAM_COLOR[self.current_team].x, SHRINE_TEAM_COLOR[self.current_team].y, SHRINE_TEAM_COLOR[self.current_team].z)

	local shockwave_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(shockwave_pfx, 0, self.location)
	ParticleManager:SetParticleControl(shockwave_pfx, 1, SHRINE_TEAM_COLOR[self.current_team])
	ParticleManager:ReleaseParticleIndex(shockwave_pfx)

	if self.minimap_dummy then
		self.minimap_dummy:SetTeam(self.current_team)
		self.minimap_dummy:RemoveModifierByName("modifier_not_on_minimap")
	end

	if self.type == SHRINE_TYPE_FOUNTAIN then
		self.thinker = CreateModifierThinker(nil, nil, "modifier_fountain_outpost_thinker", {}, self.location, self.current_team, false)
		self.vision = AddFOWViewer(self.current_team, self.location, 550, 9999, false)
	elseif self.type == SHRINE_TYPE_RESPAWN then
		RespawnManager:SetTeamRespawnOutpost(self.current_team, self)
		self.vision = AddFOWViewer(self.current_team, self.location, 550, 9999, false)
	elseif self.type == SHRINE_TYPE_VISION then
		self.vision = AddFOWViewer(self.current_team, self.location, 1800, 9999, false)
	end
end

function Shrine:OnTeamLoseShrine()
	self.state = SHRINE_STATE_DISPUTED

	self.unit:EmitSound("Shrine.Capture")

	self.unit:SetRenderColor(255, 255, 255)

	if self.thinker then self.thinker:Destroy() end

	if self.vision then RemoveFOWViewer(self.current_team, self.vision) end

	if self.minimap_dummy then
		self.minimap_dummy:AddNewModifier(self.minimap_dummy, nil, "modifier_not_on_minimap", {})
		self.minimap_dummy:SetTeam(DOTA_TEAM_NEUTRALS)
	end

	if self.type == SHRINE_TYPE_RESPAWN then
		RespawnManager:ResetTeamRespawnPosition(self.current_team)
	end
end

function Shrine:Reset()
	if self.state == SHRINE_STATE_CAPTURED then
		self:OnTeamLoseShrine()

		self.progress = 0

		self.current_team = DOTA_TEAM_NEUTRALS

		self.current_color = SHRINE_BASE_COLOR

		if self.capture_ring_pfx then ParticleManager:SetParticleControl(self.capture_ring_pfx, 3, self.current_color) end
		if self.capturing_pfx then ParticleManager:SetParticleControl(self.capturing_pfx, 3, self.current_color) end
		if self.capture_progress_pfx then
			ParticleManager:SetParticleControl(self.capture_progress_pfx, 3, self.current_color)
			ParticleManager:SetParticleControl(self.capture_progress_pfx, 17, Vector(self.progress, 0, 0))
		end
	end
end