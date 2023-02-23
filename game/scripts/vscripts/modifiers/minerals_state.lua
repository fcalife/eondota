modifier_minerals_state = class({})

function modifier_minerals_state:IsHidden() return true end
function modifier_minerals_state:IsDebuff() return false end
function modifier_minerals_state:IsPurgable() return false end

function modifier_minerals_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		--[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_minerals_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
end

function modifier_minerals_state:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_minerals_state:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_minerals_state:GetAbsoluteNoDamagePure()
	return 1
end