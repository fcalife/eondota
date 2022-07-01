modifier_hero_base_state = class({})

function modifier_hero_base_state:IsHidden() return true end
function modifier_hero_base_state:IsDebuff() return false end
function modifier_hero_base_state:IsPurgable() return false end
function modifier_hero_base_state:RemoveOnDeath() return false end
function modifier_hero_base_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_base_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE
	}
end

function modifier_hero_base_state:GetModifierMoveSpeedBonus_Constant()
	local parent = self:GetParent()

	return parent and (parent:IsRangedAttacker() and 175 or 200)
end

function modifier_hero_base_state:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_hero_base_state:GetModifierMoveSpeed_Limit()
	return 1100
end

function modifier_hero_base_state:GetModifierTurnRate_Percentage()
	return 1000
end

function modifier_hero_base_state:GetModifierPercentageRespawnTime()
	return 0.5
end

function modifier_hero_base_state:GetModifierModelScale()
	return 30
end

function modifier_hero_base_state:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_hero_base_state:GetModifierPercentageCasttime()
	return 100
end