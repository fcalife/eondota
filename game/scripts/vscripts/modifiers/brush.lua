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



modifier_lives = class({})

function modifier_lives:IsHidden() return false end
function modifier_lives:IsDebuff() return false end
function modifier_lives:IsPurgable() return false end
function modifier_lives:RemoveOnDeath() return false end
function modifier_lives:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end



modifier_just_respawned = class({})

function modifier_just_respawned:IsHidden() return false end
function modifier_just_respawned:IsDebuff() return false end
function modifier_just_respawned:IsPurgable() return false end
function modifier_just_respawned:RemoveOnDeath() return false end
function modifier_just_respawned:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_just_respawned:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function modifier_just_respawned:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
end

function modifier_just_respawned:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_just_respawned:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_SILENCED] = true,
	}
end