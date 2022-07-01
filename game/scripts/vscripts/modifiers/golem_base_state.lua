modifier_golem_base_state = class({})

function modifier_golem_base_state:IsHidden() return true end
function modifier_golem_base_state:IsDebuff() return false end
function modifier_golem_base_state:IsPurgable() return false end

function modifier_golem_base_state:OnCreated(keys)
	if IsClient() then return end

	self:StartIntervalThink(60)
end

function modifier_golem_base_state:OnIntervalThink()
	self:IncrementStackCount()
end

function modifier_golem_base_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
end

function modifier_golem_base_state:GetModifierPreAttack_BonusDamage()
	return 10 * self:GetStackCount()
end

function modifier_golem_base_state:GetModifierAttackSpeedBonus_Constant()
	return 5 * self:GetStackCount()
end

function modifier_golem_base_state:GetModifierTurnRate_Percentage()
	return 1000
end

function modifier_golem_base_state:GetModifierModelScale()
	return 20
end

function modifier_golem_base_state:GetModifierDisableTurning()
	return 0
end