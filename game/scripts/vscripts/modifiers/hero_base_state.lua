modifier_hero_base_state = class({})

function modifier_hero_base_state:IsHidden() return true end
function modifier_hero_base_state:IsDebuff() return false end
function modifier_hero_base_state:IsPurgable() return false end
function modifier_hero_base_state:RemoveOnDeath() return false end
function modifier_hero_base_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_base_state:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if (not IsInToolsMode()) then parent:AddNewModifier(parent, nil, "modifier_stunned", {duration = 10}) end

	if IS_EXPERIMENTAL_MAP then
		self:SetStackCount(parent:IsRangedAttacker() and 80 or 100)
	else
		self:SetStackCount(parent:IsRangedAttacker() and 80 or 100)
	end
end

function modifier_hero_base_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
			MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE,
			MODIFIER_PROPERTY_MODEL_SCALE,
			MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
		} else return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
			MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE,
			MODIFIER_PROPERTY_MODEL_SCALE,
			MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
		}
	end
end

function modifier_hero_base_state:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end

function modifier_hero_base_state:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_hero_base_state:GetModifierMoveSpeed_Limit()
	return 1200
end

function modifier_hero_base_state:GetModifierTurnRate_Percentage()
	return 1000
end

function modifier_hero_base_state:GetModifierPercentageRespawnTime()
	local level = self:GetParent():GetLevel()

	return math.min(0.65, 0.5 + math.max(0, 0.01 * (level - 10)))
end

function modifier_hero_base_state:GetModifierModelScale()
	return 30
end

function modifier_hero_base_state:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_hero_base_state:GetModifierPhysicalArmorBonus()
	return 3.5
end

function modifier_hero_base_state:GetModifierStatusResistanceStacking()
	return 20
end

function modifier_hero_base_state:OnTakeDamage(keys)
	if keys.unit and keys.unit == self:GetParent() and keys.unit:IsAlive() then
		if keys.attacker and keys.attacker:GetTeam() ~= keys.unit:GetTeam() then
			keys.unit:AddNewModifier(keys.unit, nil, "modifier_damage_taken", {duration = 5})
		end
	end
end