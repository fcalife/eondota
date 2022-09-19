modifier_cart_state = class({})

function modifier_cart_state:IsHidden() return true end
function modifier_cart_state:IsDebuff() return false end
function modifier_cart_state:IsPurgable() return false end

function modifier_cart_state:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end

function modifier_cart_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}
end

function modifier_cart_state:GetModifierMoveSpeed_Absolute()
	return 0.01 * self:GetStackCount()
end

function modifier_cart_state:GetModifierMoveSpeed_AbsoluteMin()
	return 0.01 * self:GetStackCount()
end

function modifier_cart_state:GetModifierMoveSpeed_AbsoluteMax()
	return 0.01 * self:GetStackCount()
end

function modifier_cart_state:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_cart_state:GetModifierMoveSpeed_Limit()
	return 0.01 * self:GetStackCount()
end