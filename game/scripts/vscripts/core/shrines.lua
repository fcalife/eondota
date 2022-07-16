_G.Shrines = Shrines or {}

SHRINE_UPDATE_RATE = 0.03

SHRINE_STATE_INACTIVE = 0
SHRINE_STATE_READY = 1
SHRINE_STATE_DISPUTED = 2
SHRINE_STATE_CAPTURED = 3
SHRINE_STATE_COOLDOWN = 4

SHRINE_ARCANE = 1
SHRINE_FRENZY = 2
SHRINE_CATASTROPHE = 3
SHRINE_ULTIMATE = 4

SHRINE_PROGRESS_TICK = SHRINE_UPDATE_RATE / SHRINE_CAPTURE_TIME

SHRINE_TYPES = {}
table.insert(SHRINE_TYPES, {
	tower_color = Vector(220, 50, 220),
	active_buff = "modifier_shrine_buff_arcane"
})
table.insert(SHRINE_TYPES, {
	tower_color = Vector(220, 50, 50),
	active_buff = "modifier_shrine_buff_frenzy"
})
table.insert(SHRINE_TYPES, {
	tower_color = Vector(220, 220, 50),
	active_buff = "modifier_shrine_buff_catastrophe"
})
table.insert(SHRINE_TYPES, {
	tower_color = Vector(50, 50, 220),
	active_buff = "modifier_shrine_buff_ultimate"
})

SHRINE_BASE_COLOR = Vector(50, 50, 50)
SHRINE_TEAM_COLOR = {
	[DOTA_TEAM_GOODGUYS] = Vector(140, 140, 400),
	[DOTA_TEAM_BADGUYS]  = Vector(400, 140, 140)
}

function Shrines:Init()
	for _, spawn_point in pairs(Entities:FindAllByName("shrine_spawn")) do
		Shrine(spawn_point:GetAbsOrigin())
	end
end



if Shrine == nil then Shrine = class({
	state = SHRINE_STATE_INACTIVE,
	radius = SHRINE_CAPTURE_ZONE_RADIUS,
	current_color = SHRINE_BASE_COLOR,
	progress = 0,
}) end

function Shrine:constructor(location)
	self.tower = CreateUnitByName("npc_control_shrine", location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	self.tower:AddNewModifier(self.tower, nil, "modifier_shrine_base_state", {})

	self.trigger = MapTrigger(location, TRIGGER_TYPE_CIRCLE, {
		radius = self.radius
	}, {
		trigger_team = DOTA_TEAM_NEUTRALS,
		team_filter = DOTA_UNIT_TARGET_TEAM_BOTH,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	}, function(units)
		self:OnUnitsInRange(units)
	end)
end

function Shrine:OnUnitsInRange(units)
	if self.state == SHRINE_STATE_INACTIVE then
		self:OnGetReady()
	end

	if self.state == SHRINE_STATE_READY then
		self:OnStartCapture(units)
	end

	if self.state == SHRINE_STATE_DISPUTED then
		self:OnDisputedThink(units)

		if self.progress >= 1 then
			self:OnTeamFinishCapture(DOTA_TEAM_GOODGUYS)
		elseif self.progress <= -1 then
			self:OnTeamFinishCapture(DOTA_TEAM_BADGUYS)
		end
	end
end

function Shrine:OnGetReady()
	self.tower:AddNewModifier(self.tower, nil, "modifier_shrine_active", {})

	self.progress = 0

	self.state = SHRINE_STATE_READY
end

function Shrine:OnStartCapture(units)
	local unit_count = {}
	unit_count[DOTA_TEAM_GOODGUYS] = 0
	unit_count[DOTA_TEAM_BADGUYS] = 0

	for _, unit in pairs(units) do
		local team = unit:GetTeam()
		unit_count[team] = (unit_count[team] and unit_count[team] + 1) or 1
	end

	if self.tower:GetTeam() == DOTA_TEAM_GOODGUYS and unit_count[DOTA_TEAM_BADGUYS] <= 0 then
		return
	elseif self.tower:GetTeam() == DOTA_TEAM_BADGUYS and unit_count[DOTA_TEAM_GOODGUYS] <= 0 then
		return
	end

	self.tower:EmitSound("Shrine.Activation")

	self.capture_ring_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.tower)
	ParticleManager:SetParticleControl(self.capture_ring_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capture_ring_pfx, 9, Vector(self.radius, 0, 0))

	self.capturing_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring_capturing.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.tower)
	ParticleManager:SetParticleControl(self.capturing_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capturing_pfx, 9, Vector(self.radius, 0, 0))

	self.capture_progress_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring_clock.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.tower)
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 9, Vector(self.radius, 0, 0))
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 11, Vector(0, 0, 1))
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 17, Vector(0, 0, 0))

	self.state = SHRINE_STATE_DISPUTED
end

function Shrine:OnDisputedThink(units)
	local unit_count = {}
	unit_count[DOTA_TEAM_GOODGUYS] = 0
	unit_count[DOTA_TEAM_BADGUYS] = 0

	for _, unit in pairs(units) do
		local team = unit:GetTeam()
		unit_count[team] = (unit_count[team] and unit_count[team] + 1) or 1
	end

	if unit_count[DOTA_TEAM_GOODGUYS] > unit_count[DOTA_TEAM_BADGUYS] then
		self.progress = math.min(1, self.progress + SHRINE_PROGRESS_TICK)
	elseif unit_count[DOTA_TEAM_BADGUYS] > unit_count[DOTA_TEAM_GOODGUYS] then
		self.progress = math.max(-1, self.progress - SHRINE_PROGRESS_TICK)
	end

	if self.progress >= 0 then
		self.current_color = SHRINE_BASE_COLOR + self.progress * (SHRINE_TEAM_COLOR[DOTA_TEAM_GOODGUYS] - SHRINE_BASE_COLOR)
	else
		self.current_color = SHRINE_BASE_COLOR - self.progress * (SHRINE_TEAM_COLOR[DOTA_TEAM_BADGUYS] - SHRINE_BASE_COLOR)
	end

	if self.capture_ring_pfx then ParticleManager:SetParticleControl(self.capture_ring_pfx, 3, self.current_color) end
	if self.capturing_pfx then ParticleManager:SetParticleControl(self.capturing_pfx, 3, self.current_color) end
	if self.capture_progress_pfx then
		ParticleManager:SetParticleControl(self.capture_progress_pfx, 3, self.current_color)
		if self.progress >= 0 then
			ParticleManager:SetParticleControl(self.capture_progress_pfx, 17, Vector(self.progress, 0, 0))
		else
			ParticleManager:SetParticleControl(self.capture_progress_pfx, 17, Vector(2 + self.progress, 0, 0))
		end
	end
end

function Shrine:OnTeamFinishCapture(team)
	self.progress = 0
	self.state = SHRINE_STATE_CAPTURED

	self.tower:EmitSound("Shrine.Capture")

	self.tower:SetRenderColor(SHRINE_TEAM_COLOR[team].x, SHRINE_TEAM_COLOR[team].y, SHRINE_TEAM_COLOR[team].z)

	self.active_pfx = ParticleManager:CreateParticle("particles/world_tower/tower_upgrade/ti7_radiant_tower_lvl11_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, self.tower)

	local shockwave_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(shockwave_pfx, 0, self.tower:GetAbsOrigin())
	ParticleManager:SetParticleControl(shockwave_pfx, 1, SHRINE_TEAM_COLOR[team])
	ParticleManager:ReleaseParticleIndex(shockwave_pfx)

	self.tower:SetTeam(team)

	if self.capture_ring_pfx then
		ParticleManager:DestroyParticle(self.capture_ring_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.capture_ring_pfx)
	end

	if self.capturing_pfx then
		ParticleManager:DestroyParticle(self.capturing_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.capturing_pfx)
	end

	if self.capture_progress_pfx then
		ParticleManager:DestroyParticle(self.capture_progress_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.capture_progress_pfx)
	end

	Timers:CreateTimer(SHRINE_COOLDOWN_TIME, function()
		self:OnCaptureCooldownExpire()
	end)

	-- local handicap = ScoreManager:GetHandicap(team)
	-- local allies = FindUnitsInRadius(team, self.tower:GetAbsOrigin(), nil, SHRINE_BUFF_EFFECT_RADIUS, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	-- for _, ally in pairs(allies) do
	-- 	local hit_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_shockwave_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
	-- 	ParticleManager:SetParticleControl(hit_pfx, 1, SHRINE_TEAM_COLOR[team])
	-- 	ParticleManager:ReleaseParticleIndex(hit_pfx)
	-- end
end

function Shrine:OnCaptureCooldownExpire()
	if self.active_pfx then
		ParticleManager:DestroyParticle(self.active_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.active_pfx)
	end

	self:OnGetReady()
end