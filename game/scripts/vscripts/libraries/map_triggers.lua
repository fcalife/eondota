if MapTrigger == nil then MapTrigger = class({
	center = Vector(0, 0, 0),
	trigger_type = TRIGGER_TYPE_CIRCLE,
	dimensions = (trigger_type == TRIGGER_TYPE_CIRCLE) and {radius = 0} or {width = 0, height = 0},
	trigger_team = DOTA_TEAM_NEUTRALS,
	team_filter = DOTA_UNIT_TARGET_TEAM_BOTH,
	unit_filter = DOTA_UNIT_TARGET_BASIC,
	flag_filter = DOTA_UNIT_TARGET_FLAG_NONE,
	find_order = FIND_ANY_ORDER,
	callback = function() end
}) end

TRIGGER_TYPE_CIRCLE = 0
TRIGGER_TYPE_RECTANGLE = 1

function MapTrigger:constructor(center, trigger_type, dimensions, filters, callback, options)
	self.center = center or self.center
	self.trigger_type = trigger_type or self.trigger_type
	self.dimensions = dimensions or self.dimensions
	self.trigger_team = filters.trigger_team or self.trigger_team
	self.team_filter = filters.team_filter or self.team_filter
	self.unit_filter = filters.unit_filter or self.unit_filter
	self.flag_filter = filters.flag_filter or self.flag_filter
	self.find_order = filters.find_order or self.find_order
	self.callback = callback or self.callback
	self.options = options or {}

	if self.trigger_type == TRIGGER_TYPE_RECTANGLE then
		self.start_pos = self.dimensions.start_pos or Vector(0, 0, 0)
		self.end_pos = self.dimensions.end_pos or Vector(1, 0, 0)
		self.height = self.dimensions.height or 100
	end

	self:Start()
end

function MapTrigger:Start()
	self.timer = Timers:CreateTimer(0, function()
		self:Tick()
		return 0.03
	end)
end

function MapTrigger:Stop()
	Timers:RemoveTimer(self.timer)
end

function MapTrigger:Tick()
	local units

	if self.trigger_type == TRIGGER_TYPE_CIRCLE then
		units = FindUnitsInRadius(
			self.trigger_team,
			self.center,
			nil,
			self.dimensions.radius,
			self.team_filter,
			self.unit_filter,
			self.flag_filter,
			self.find_order,
			false
		)
	elseif self.trigger_type == TRIGGER_TYPE_RECTANGLE then
		units = FindUnitsInLine(
			self.trigger_team,
			self.start_pos,
			self.end_pos,
			nil,
			self.height,
			self.team_filter,
			self.unit_filter,
			self.flag_filter
		)
	end

	if (#units > 0 or self.options.tick_when_empty) then self.callback(units) end
end

function MapTrigger:MoveTo(position)
	self.center = position
end