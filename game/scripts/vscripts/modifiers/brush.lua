modifier_brush_transparency = class({})

function modifier_brush_transparency:IsHidden() return true end
function modifier_brush_transparency:IsDebuff() return false end
function modifier_brush_transparency:IsPurgable() return false end

function modifier_brush_transparency:DeclareFunctions()
	return { MODIFIER_PROPERTY_INVISIBILITY_LEVEL }
end

function modifier_brush_transparency:GetModifierInvisibilityLevel()
	return 1
end



modifier_brush_invisibility = class({})

function modifier_brush_invisibility:IsHidden() return true end
function modifier_brush_invisibility:IsDebuff() return false end
function modifier_brush_invisibility:IsPurgable() return false end

function modifier_brush_invisibility:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end