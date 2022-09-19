modifier_cart_objective_state = class({})

function modifier_cart_objective_state:IsHidden() return true end
function modifier_cart_objective_state:IsDebuff() return false end
function modifier_cart_objective_state:IsPurgable() return false end

function modifier_cart_objective_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_cart_objective_state:DeclareFunctions()
	return { MODIFIER_PROPERTY_PROVIDES_FOW_POSITION }
end

function modifier_cart_objective_state:GetModifierProvidesFOWVision()
	return 1
end