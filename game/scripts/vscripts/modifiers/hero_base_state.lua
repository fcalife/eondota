modifier_hero_base_state = class({})

function modifier_hero_base_state:IsHidden() return true end
function modifier_hero_base_state:IsDebuff() return false end
function modifier_hero_base_state:IsPurgable() return false end
function modifier_hero_base_state:RemoveOnDeath() return false end
function modifier_hero_base_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_base_state:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if (not IsInToolsMode()) then parent:AddNewModifier(parent, nil, "modifier_stunned", {duration = 12}) end
end

function modifier_hero_base_state:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_hero_base_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE
	}
end

function modifier_hero_base_state:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_hero_base_state:GetModifierPercentageRespawnTime()
	return (0.4 + 0.3 * (self:GetParent():GetLevel()) / 30)
end