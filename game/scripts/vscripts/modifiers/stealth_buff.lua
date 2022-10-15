modifier_stealth_prevention = class({})

function modifier_stealth_prevention:IsHidden() return false end
function modifier_stealth_prevention:IsDebuff() return true end
function modifier_stealth_prevention:IsPurgable() return false end



modifier_minor_stealth_buff = class({})

function modifier_minor_stealth_buff:IsHidden() return false end
function modifier_minor_stealth_buff:IsDebuff() return false end
function modifier_minor_stealth_buff:IsPurgable() return false end

function modifier_minor_stealth_buff:GetTexture()
	return "riki_permanent_invisibility"
end

function modifier_minor_stealth_buff:OnCreated()
	if IsClient() then return end

	self:StartIntervalThink(0.1)

	self:OnIntervalThink()
end

function modifier_minor_stealth_buff:OnIntervalThink()
	local parent = self:GetParent()

	local enemies = FindUnitsInRadius(
		parent:GetTeam(),
		parent:GetAbsOrigin(),
		nil,
		1000,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false
	)

	if #enemies > 0 then self:Destroy() end
end

function modifier_minor_stealth_buff:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

function modifier_minor_stealth_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}
end

function modifier_minor_stealth_buff:GetModifierProcAttack_Feedback(keys)
	if IsClient() then return end

	self:Destroy()
end

function modifier_minor_stealth_buff:OnAbilityExecuted(keys)
	if IsClient() then return end

	if keys.unit and keys.unit == self:GetParent() and (not keys.unit:IsNull()) then
		if keys.ability and keys.ability:GetName() ~= "abyssal_underlord_portal_warp" then self:Destroy() end
	end
end

function modifier_minor_stealth_buff:GetModifierMoveSpeedBonus_Percentage()
	return 15
end

function modifier_minor_stealth_buff:GetModifierInvisibilityLevel()
	return 1
end



modifier_major_stealth_buff = class({})

function modifier_major_stealth_buff:IsHidden() return false end
function modifier_major_stealth_buff:IsDebuff() return false end
function modifier_major_stealth_buff:IsPurgable() return false end

function modifier_major_stealth_buff:IsAura() return true end
function modifier_major_stealth_buff:GetModifierAura() return "modifier_major_stealth_buff_detect" end
function modifier_major_stealth_buff:GetAuraRadius() return 25000 end
function modifier_major_stealth_buff:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_major_stealth_buff:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_major_stealth_buff:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS end

function modifier_major_stealth_buff:GetTexture()
	return "riki_permanent_invisibility"
end

function modifier_major_stealth_buff:CheckState()
	local states = {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return states
end

function modifier_major_stealth_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
	}
end

function modifier_major_stealth_buff:GetModifierProcAttack_Feedback(keys)
	if IsClient() then return end

	if keys.target and keys.attacker and (not keys.target:IsNull()) and (not keys.attacker:IsNull()) then
		local target_facing = keys.target:GetForwardVector()
		local attacker_facing = (keys.target:GetAbsOrigin() - keys.attacker:GetAbsOrigin())

		local target_angle = math.deg(math.atan2(target_facing.x, target_facing.y))
		local attacker_angle = math.deg(math.atan2(attacker_facing.x, attacker_facing.y))

		if math.abs(target_angle - attacker_angle) <= 70 or (360 - math.abs(target_angle - attacker_angle) <= 70) then
			keys.target:AddNewModifier(keys.attacker, nil, "modifier_stunned", {duration = 1.0})
		end
	end

	self:Destroy()
end

function modifier_major_stealth_buff:OnAbilityExecuted(keys)
	if IsClient() then return end

	if keys.unit and keys.unit == self:GetParent() and (not keys.unit:IsNull()) then
		if keys.ability and keys.ability:GetName() ~= "abyssal_underlord_portal_warp" then self:Destroy() end
	end
end

function modifier_major_stealth_buff:GetModifierMoveSpeedBonus_Percentage()
	return 50
end

function modifier_major_stealth_buff:GetModifierInvisibilityLevel()
	return 1
end

function modifier_major_stealth_buff:GetModifierPreAttack_CriticalStrike()
	return 250
end



modifier_major_stealth_buff_detect = class({})

function modifier_major_stealth_buff_detect:IsHidden() return true end
function modifier_major_stealth_buff_detect:IsDebuff() return true end
function modifier_major_stealth_buff_detect:IsPurgable() return false end

function modifier_major_stealth_buff_detect:DeclareFunctions()
	return { MODIFIER_PROPERTY_PROVIDES_FOW_POSITION }
end

function modifier_major_stealth_buff_detect:GetModifierProvidesFOWVision()
	return 1
end