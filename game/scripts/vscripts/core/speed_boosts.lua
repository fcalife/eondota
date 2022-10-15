_G.SpeedBoosts = SpeedBoosts or {}

function SpeedBoosts:Init()
	--for _, speed_boost in pairs(Entities:FindAllByName("speed_boost")) do
	--	self:SpawnSpeedBoost(speed_boost:GetAbsOrigin())
	--end
end

function SpeedBoosts:SpawnSpeedBoost(position)
	MapTrigger(position, TRIGGER_TYPE_CIRCLE, {
		radius = 225
	}, {
		trigger_team = DOTA_TEAM_NEUTRALS,
		team_filter = DOTA_UNIT_TARGET_TEAM_BOTH,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	}, function(units)
		for _, unit in pairs(units) do
			unit:AddNewModifier(unit, nil, "modifier_speed_bonus", {duration = 6})
		end
	end,
	{})
end



if SpeedLane == nil then SpeedLane = class({}) end

function SpeedLane:constructor(team)
	self.start_position = GameManager.eon_stone_spawn_points[1]
	self.direction  = (TEAM_GOALS[team].location - self.start_position):Normalized()
	self.length = (TEAM_GOALS[team].location - self.start_position):Length2D() - EON_STONE_GOAL_RADIUS - 200
	self.end_position = self.start_position + self.length * self.direction
	self.width = 400

	self.speed = 250
	self.movement_tick = 0.03 * self.speed * self.direction

	self.lane_pfx = ParticleManager:CreateParticle("particles/speed_lane.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.lane_pfx, 0, self.start_position)
	ParticleManager:SetParticleControl(self.lane_pfx, 1, self.end_position)

	local cleaned_distance = 0
	while cleaned_distance < self.length do
		cleaned_distance = cleaned_distance + 0.5 * self.width
		GridNav:DestroyTreesAroundPoint(self.start_position + cleaned_distance * self.direction, 0.75 * self.width, true)
	end

	self.trigger = MapTrigger(self.start_position * 0.5 * self.length * self.direction, TRIGGER_TYPE_RECTANGLE, {
		start_pos = self.start_position,
		end_pos = self.end_position,
		height = self.width,
	}, {
		trigger_team = team,
		team_filter = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_NONE,
	}, function(units)
		self:OnUnitsInAuraRange(units)
	end, {
		tick_when_empty = false,
	})
end

function SpeedLane:OnUnitsInAuraRange(units)
	for _, unit in pairs(units) do
		local unit_position = unit:GetAbsOrigin()
		local new_position = unit_position + self.movement_tick

		if (not unit:HasModifier("modifier_knockback")) then
			GridNav:DestroyTreesAroundPoint(new_position, 200, false)
			FindClearSpaceForUnit(unit, new_position, true)
		end
	end
end