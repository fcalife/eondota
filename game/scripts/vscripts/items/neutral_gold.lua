item_neutral_gold = class({})
item_health_potion = class({})
item_mario_star = class({})
item_power_boots = class({})
item_power_bull = class({})
item_power_shield = class({})
item_power_metal = class({})
item_power_refresh = class({})
item_power_invis = class({})



LinkLuaModifier("modifier_powerup_star", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_bossfight_shield", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_bossfight_movespeed", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_bossfight_regen", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_bossfight_nuke_damage", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_bossfight_ultimate_power", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_powerup_boots", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_bull", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bull_prevention", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_shield", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_metal", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_refresh", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_powerup_invis", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)



modifier_powerup_star = class({})

function modifier_powerup_star:IsHidden() return true end
function modifier_powerup_star:IsDebuff() return false end
function modifier_powerup_star:IsPurgable() return false end

function modifier_powerup_star:OnStackCountChanged(new_stack_count)
	if (not IsServer()) then return end

	if new_stack_count == 0 then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_powerup_bossfight_movespeed", {})
	end

	if new_stack_count == 1 then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_powerup_bossfight_regen", {})
	end

	if new_stack_count == 2 then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_powerup_bossfight_shield", {})
	end

	if new_stack_count == 3 then
		local nuke_ability = self:GetParent():FindAbilityByName("snapfire_scatterblast")

		if nuke_ability then nuke_ability:SetHidden(false) end

		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_powerup_bossfight_nuke_damage", {})
	end

	if new_stack_count == 4 then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_powerup_bossfight_ultimate_power", {})
	end
end

function modifier_powerup_star:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_powerup_star:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end




modifier_powerup_bossfight_shield = class({})

function modifier_powerup_bossfight_shield:IsHidden() return true end
function modifier_powerup_bossfight_shield:IsDebuff() return false end
function modifier_powerup_bossfight_shield:IsPurgable() return false end
function modifier_powerup_bossfight_shield:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_powerup_bossfight_shield:OnCreated(keys)
	if IsServer() then
		self:SetStackCount(SPHERE_SHIELD_AMOUNT)
		self:StartIntervalThink(0.1)
	end
end

function modifier_powerup_bossfight_shield:OnIntervalThink()
	if self.shield_broken then
		self.recharge_time = self.recharge_time - 0.1

		if self.recharge_time <= 0 then
			self.shield_broken = false
			self:SetStackCount(SPHERE_SHIELD_AMOUNT)
			self:SendBuffRefreshToClients()
		end
	end
end

function modifier_powerup_bossfight_shield:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
	}
end

function modifier_powerup_bossfight_shield:GetModifierIncomingDamageConstant(keys)
	if not IsServer() then return self:GetStackCount() end

	if self.shield_broken then return 0 end

	if self:GetStackCount() >= keys.damage then
		self:SetStackCount(self:GetStackCount() - keys.damage)

		return -keys.damage
	else
		local reduction = self:GetStackCount()

		self:SetStackCount(0)

		self.shield_broken = true
		self.recharge_time = SPHERE_SHIELD_DELAY

		return -reduction
	end
end





modifier_powerup_bossfight_nuke_damage = class({})

function modifier_powerup_bossfight_nuke_damage:IsHidden() return true end
function modifier_powerup_bossfight_nuke_damage:IsDebuff() return false end
function modifier_powerup_bossfight_nuke_damage:IsPurgable() return false end
function modifier_powerup_bossfight_nuke_damage:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_powerup_bossfight_nuke_damage:OnCreated(keys)
	if IsServer() then
		self:SetStackCount(SPHERE_NUKE_DAMAGE)
		self:StartIntervalThink(0.1)
	end
end

function modifier_powerup_bossfight_nuke_damage:OnIntervalThink()
	self:SetStackCount(SPHERE_NUKE_DAMAGE)
end

function modifier_powerup_bossfight_nuke_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
	}
end

function modifier_powerup_bossfight_nuke_damage:GetModifierOverrideAbilitySpecial(keys)
	if (not keys.ability) or (not keys.ability_special_value) then return 0 end

	if keys.ability and keys.ability:GetAbilityName() == "snapfire_scatterblast" and keys.ability_special_value == "damage" then
		return 1
	end 

	return 0
end

function modifier_powerup_bossfight_nuke_damage:GetModifierOverrideAbilitySpecialValue(keys)
	if keys.ability and keys.ability:GetAbilityName() == "snapfire_scatterblast" and keys.ability_special_value == "damage" then
		return SPHERE_NUKE_DAMAGE
	end 

	return 0
end





modifier_powerup_bossfight_movespeed = class({})

function modifier_powerup_bossfight_movespeed:IsHidden() return true end
function modifier_powerup_bossfight_movespeed:IsDebuff() return false end
function modifier_powerup_bossfight_movespeed:IsPurgable() return false end
function modifier_powerup_bossfight_movespeed:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_powerup_bossfight_movespeed:GetEffectName()
	return "particles/speed_buff.vpcf"
end

function modifier_powerup_bossfight_movespeed:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_powerup_bossfight_movespeed:OnCreated(keys)
	if IsServer() then
		self:SetStackCount(SPHERE_MOVE_SPEED)
		self:StartIntervalThink(0.1)
	end
end

function modifier_powerup_bossfight_movespeed:OnIntervalThink()
	self:SetStackCount(SPHERE_MOVE_SPEED)
end


function modifier_powerup_bossfight_movespeed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_powerup_bossfight_movespeed:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end





modifier_powerup_bossfight_regen = class({})

function modifier_powerup_bossfight_regen:IsHidden() return true end
function modifier_powerup_bossfight_regen:IsDebuff() return false end
function modifier_powerup_bossfight_regen:IsPurgable() return false end
function modifier_powerup_bossfight_regen:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_powerup_bossfight_regen:OnCreated(keys)
	if IsServer() then
		self:SetStackCount(SPHERE_HEALTH_REGEN)
		self:StartIntervalThink(0.1)
	end
end

function modifier_powerup_bossfight_regen:OnIntervalThink()
	self:SetStackCount(SPHERE_HEALTH_REGEN)
end


function modifier_powerup_bossfight_regen:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_powerup_bossfight_regen:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end





modifier_powerup_bossfight_ultimate_power = class({})

function modifier_powerup_bossfight_ultimate_power:IsHidden() return true end
function modifier_powerup_bossfight_ultimate_power:IsDebuff() return false end
function modifier_powerup_bossfight_ultimate_power:IsPurgable() return false end
function modifier_powerup_bossfight_ultimate_power:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_powerup_bossfight_ultimate_power:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function modifier_powerup_bossfight_ultimate_power:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
end

function modifier_powerup_bossfight_ultimate_power:OnCreated(keys)
	if IsServer() then
		self:SetStackCount(SPHERE_POWER_FACTOR)
		self:StartIntervalThink(0.1)
	end
end

function modifier_powerup_bossfight_ultimate_power:OnIntervalThink()
	self:SetStackCount(SPHERE_POWER_FACTOR)
end

function modifier_powerup_bossfight_ultimate_power:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_powerup_bossfight_ultimate_power:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_powerup_bossfight_ultimate_power:GetModifierMoveSpeedBonus_Percentage()
	return 10 * self:GetStackCount()
end

function modifier_powerup_bossfight_ultimate_power:GetModifierModelScale()
	return 50
end

function modifier_powerup_bossfight_ultimate_power:GetModifierIncomingDamage_Percentage()
	return (self:GetStackCount() > 0 and (100 / self:GetStackCount()) - 100) or 0
end

function modifier_powerup_bossfight_ultimate_power:GetModifierPercentageCooldown()
	return (self:GetStackCount() > 0 and 100 - (100 / self:GetStackCount())) or 0
end

function modifier_powerup_bossfight_ultimate_power:GetModifierAttackSpeedBonus_Constant()
	return 200 * (self:GetStackCount() - 1)
end

function modifier_powerup_bossfight_ultimate_power:GetModifierTotalDamageOutgoing_Percentage()
	return 100 * (self:GetStackCount() - 1)
end





modifier_powerup_boots = class({})

function modifier_powerup_boots:IsHidden() return false end
function modifier_powerup_boots:IsDebuff() return false end
function modifier_powerup_boots:IsPurgable() return false end

function modifier_powerup_boots:GetEffectName()
	return "particles/speed_buff.vpcf"
end

function modifier_powerup_boots:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_powerup_boots:OnCreated()
	if IsClient() then return end

	local parent = self:GetParent()

	parent:UnHideAbilityToSlot("boosted_astral_step", "void_spirit_astral_step")
end

function modifier_powerup_boots:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	parent:UnHideAbilityToSlot("void_spirit_astral_step", "boosted_astral_step")
end

function modifier_powerup_boots:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_powerup_boots:GetModifierMoveSpeedBonus_Percentage()
	return 35
end



modifier_powerup_bull = class({})

function modifier_powerup_bull:IsHidden() return false end
function modifier_powerup_bull:IsDebuff() return false end
function modifier_powerup_bull:IsPurgable() return false end

function modifier_powerup_bull:GetEffectName()
	return "particles/econ/items/spirit_breaker/spirit_breaker_iron_surge/spirit_breaker_charge_iron.vpcf"
end

function modifier_powerup_bull:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_powerup_bull:OnCreated()
	if IsClient() then return end

	self:StartIntervalThink(0.03)
end

function modifier_powerup_bull:OnIntervalThink()
	local parent = self:GetParent()
	local parent_loc = parent:GetAbsOrigin()

	local enemies = FindUnitsInRadius(
		parent:GetTeam(),
		parent_loc,
		nil,
		170,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		if (not enemy:HasModifier("modifier_bull_prevention")) then
			local direction = (enemy:GetAbsOrigin() - parent_loc):Normalized()

			enemy:AddNewModifier(enemy, nil, "modifier_bull_prevention", {duration = 1})

			KnockbackArena:Knockback(parent, enemy, direction.x, direction.y, 1)
			enemy:EmitSound("KnockbackArena.Powerup.Bull.Hit")
		end
	end
end



modifier_bull_prevention = class({})

function modifier_bull_prevention:IsHidden() return true end
function modifier_bull_prevention:IsDebuff() return false end
function modifier_bull_prevention:IsPurgable() return false end



modifier_powerup_shield = class({})

function modifier_powerup_shield:IsHidden() return false end
function modifier_powerup_shield:IsDebuff() return false end
function modifier_powerup_shield:IsPurgable() return false end

function modifier_powerup_shield:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield.vpcf"
end

function modifier_powerup_shield:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



modifier_powerup_metal = class({})

function modifier_powerup_metal:IsHidden() return false end
function modifier_powerup_metal:IsDebuff() return false end
function modifier_powerup_metal:IsPurgable() return false end

function modifier_powerup_metal:GetStatusEffectName()
	return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
end

function modifier_powerup_metal:StatusEffectPriority()
	return 100
end



modifier_powerup_refresh = class({})

function modifier_powerup_refresh:IsHidden() return false end
function modifier_powerup_refresh:IsDebuff() return false end
function modifier_powerup_refresh:IsPurgable() return false end

function modifier_powerup_refresh:OnCreated()
	if IsClient() then return end

	self:SetStackCount(2)
end

function modifier_powerup_refresh:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST } end
end

function modifier_powerup_refresh:OnAbilityFullyCast(keys)
	if keys.unit == self:GetParent() then
		if keys.ability and self:GetStackCount() > 0 then
			local ability_name = keys.ability:GetAbilityName()

			if ability_name ~= "void_spirit_astral_step" then
				keys.unit:EmitSound("KnockbackArena.Powerup.Refresh.Proc")

				local proc_pfx = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.unit)
				ParticleManager:ReleaseParticleIndex(proc_pfx)

				self:DecrementStackCount()

				keys.ability:EndCooldown()

				if self:GetStackCount() <= 0 then self:Destroy() end
			end
		end
	end
end



modifier_powerup_invis = class({})

function modifier_powerup_invis:IsHidden() return false end
function modifier_powerup_invis:IsDebuff() return false end
function modifier_powerup_invis:IsPurgable() return false end

function modifier_powerup_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_powerup_invis:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_ABILITY_START,
			MODIFIER_PROPERTY_INVISIBILITY_LEVEL
		}
	else
		return {
			MODIFIER_PROPERTY_INVISIBILITY_LEVEL
		}
	end
end

function modifier_powerup_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_powerup_invis:OnAbilityStart(keys)
	if keys.unit == self:GetParent() then
		self:Destroy()
	end
end