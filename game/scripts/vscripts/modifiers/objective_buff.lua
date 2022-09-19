modifier_objective_buff = class({})

function modifier_objective_buff:IsHidden() return true end
function modifier_objective_buff:IsDebuff() return false end
function modifier_objective_buff:IsPurgable() return false end

function modifier_objective_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}
end

function modifier_objective_buff:GetModifierConstantManaRegen()
	return 10
end

function modifier_objective_buff:GetModifierPercentageCooldown()
	return 10
end

function modifier_objective_buff:GetModifierAttackSpeedPercentage()
	return 15
end