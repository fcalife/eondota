_G.BrushManager = BrushManager or {}

BRUSH_WIDTH = 300

function BrushManager:Init()
	local found_brush = true
	local i = 1

	while found_brush do
		local brush_start = Entities:FindByName(nil, "brush_"..i.."_start")
		local brush_end = Entities:FindByName(nil, "brush_"..i.."_end")

		if brush_start and brush_end then
			Brush(brush_start:GetAbsOrigin(), brush_end:GetAbsOrigin())
			i = i + 1
		else
			found_brush = false
		end
	end
end



if Brush == nil then Brush = class({}) end

function Brush:constructor(start_position, end_position)
	self.start_position = start_position
	self.end_position = end_position
	self.direction  = (self.end_position - self.start_position):Normalized()
	self.length = (self.end_position - self.start_position):Length2D() - BRUSH_WIDTH

	self.trigger = MapTrigger(0.5 * (self.start_position + self.end_position), TRIGGER_TYPE_RECTANGLE, {
		start_pos = self.start_position,
		end_pos = self.end_position,
		height = self.width,
	}, {
		trigger_team = DOTA_TEAM_NEUTRALS,
		team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
		unit_filter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		flag_filter = DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	}, function(units)
		self:OnUnitsInBrush(units)
	end, {
		tick_when_empty = false,
	})
end

function Brush:OnUnitsInBrush(units)
	local radiant_present = false
	local dire_present = false

	for _, unit in pairs(units) do
		if unit:GetTeam() == DOTA_TEAM_GOODGUYS then radiant_present = true end
		if unit:GetTeam() == DOTA_TEAM_BADGUYS then dire_present = true end
	end

	for _, unit in pairs(units) do
		unit:AddNewModifier(unit, nil, "modifier_brush_transparency", {duration = 0.1})

		if radiant_present and dire_present then
			unit:RemoveModifierByName("modifier_brush_invisibility")
		else
			unit:AddNewModifier(unit, nil, "modifier_brush_invisibility", {duration = 0.1})
		end
	end
end