_G.Objectives = Objectives or {}

OBJECTIVE_STATE_INACTIVE = 0
OBJECTIVE_STATE_IN_PROGRESS = 1

OBJECTIVE_PROGRESS_TICK = SHRINE_UPDATE_RATE / 8

function Objectives:Init()
	for _, radiant_goal in pairs(Entities:FindAllByName("radiant_goal")) do
		Objective(radiant_goal:GetAbsOrigin(), DOTA_TEAM_GOODGUYS)
	end

	for _, dire_goal in pairs(Entities:FindAllByName("dire_goal")) do
		Objective(dire_goal:GetAbsOrigin(), DOTA_TEAM_BADGUYS)
	end
end



if Objective == nil then Objective = class({
	state = OBJECTIVE_STATE_INACTIVE,
	radius = EON_STONE_GOAL_RADIUS,
	current_color = SHRINE_BASE_COLOR,
	progress = 0,
}) end

function Objective:constructor(location, team)
	self.team = team
	self.current_color = SHRINE_TEAM_COLOR[team]
	self.location = location

	self.trigger = MapTrigger(location, TRIGGER_TYPE_CIRCLE, {
		radius = self.radius
	}, {
		trigger_team = team,
		team_filter = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_NONE,
	}, function(units)
		self:OnUnitsInRange(units)
	end, {
		tick_when_empty = true,
	})
end

function Objective:OnUnitsInRange(units)
	if self.state == OBJECTIVE_STATE_INACTIVE then
		self:OnStartCapture(units)
	end

	if self.state == OBJECTIVE_STATE_IN_PROGRESS then
		self:OnCaptureThink(units)

		if self.progress >= 1 then
			self:OnCaptureSuccess(units)
		end
	end
end

function Objective:OnStartCapture(units)
	local valid_units = false

	if #units > 0 then
		for _, unit in pairs(units) do
			local stone = unit:FindItemInInventory("item_eon_stone")
			if stone and stone:IsActivated() then valid_units = true end
		end
	end

	if (not valid_units) then return end

	self.capture_ring_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.capture_ring_pfx, 0, self.location)
	ParticleManager:SetParticleControl(self.capture_ring_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capture_ring_pfx, 9, Vector(self.radius, 0, 0))

	self.capturing_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring_capturing.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.capturing_pfx, 0, self.location)
	ParticleManager:SetParticleControl(self.capturing_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capturing_pfx, 9, Vector(self.radius, 0, 0))

	self.capture_progress_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_ring_clock.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 0, self.location)
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 3, self.current_color)
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 9, Vector(self.radius, 0, 0))
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 11, Vector(0, 0, 1))
	ParticleManager:SetParticleControl(self.capture_progress_pfx, 17, Vector(0, 0, 0))

	self.state = OBJECTIVE_STATE_IN_PROGRESS
end

function Objective:OnCaptureThink(units)
	local valid_units = false

	if #units > 0 then
		for _, unit in pairs(units) do
			local stone = unit:FindItemInInventory("item_eon_stone")
			if stone and stone:IsActivated() then valid_units = true end
		end
	end

	if valid_units then
		self.progress = math.min(1, self.progress + SHRINE_PROGRESS_TICK)
	else
		self.progress = math.max(0, self.progress - SHRINE_PROGRESS_TICK)
	end

	if self.capture_progress_pfx then
		ParticleManager:SetParticleControl(self.capture_progress_pfx, 17, Vector(self.progress, 0, 0))
	end
end

function Objective:OnCaptureSuccess(units)
	self.progress = 0
	self.state = OBJECTIVE_STATE_INACTIVE

	local shockwave_pfx = ParticleManager:CreateParticle("particles/control_zone/capture_point_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(shockwave_pfx, 0, self.location)
	ParticleManager:SetParticleControl(shockwave_pfx, 1, self.current_color)
	ParticleManager:ReleaseParticleIndex(shockwave_pfx)

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

	local unit = units[1]

	if unit then
		local scored = false

		for _, this_unit in pairs(units) do
			if (not scored) then
				local stone = this_unit:FindItemInInventory("item_eon_stone")

				if stone then
					ScoreManager:Score(self.team, EON_STONE_SCORE)
					scored = true
					stone:Destroy()
				end
			end
		end
	end
end