modifier_nexus_state = class({})

function modifier_nexus_state:IsHidden() return true end
function modifier_nexus_state:IsDebuff() return false end
function modifier_nexus_state:IsPurgable() return false end

function modifier_nexus_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_nexus_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		MODIFIER_PROPERTY_DISABLE_HEALING
	}
end

function modifier_nexus_state:GetModifierProvidesFOWVision()
	return 1
end

function modifier_nexus_state:GetOverrideAnimation()
	return ACT_DOTA_CAPTURE
end

function modifier_nexus_state:GetDisableHealing()
	return 1
end