modifier_shrine_base_state = class({})

function modifier_shrine_base_state:IsHidden() return true end
function modifier_shrine_base_state:IsDebuff() return false end
function modifier_shrine_base_state:IsPurgable() return false end

function modifier_shrine_base_state:IsAura() return true end
function modifier_shrine_base_state:GetModifierAura() return "modifier_shrine_base_state_aura" end
function modifier_shrine_base_state:GetAuraRadius() return 900 end
function modifier_shrine_base_state:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_shrine_base_state:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_shrine_base_state:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end

function modifier_shrine_base_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true
	}
end

function modifier_shrine_base_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE
	}
end

function modifier_shrine_base_state:GetModifierModelScale()
	return 20
end



modifier_shrine_base_state_aura = class({})

function modifier_shrine_base_state_aura:IsHidden() return self:GetParent():HasModifier("modifier_damage_taken") end
function modifier_shrine_base_state_aura:IsDebuff() return false end
function modifier_shrine_base_state_aura:IsPurgable() return false end

function modifier_shrine_base_state_aura:GetTexture() return "rune_regen" end

function modifier_shrine_base_state_aura:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
		}
	else
		return {
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
		}
	end
end

function modifier_shrine_base_state_aura:OnTakeDamage(keys)
	if keys.unit and keys.unit == self:GetParent() and keys.unit:IsAlive() then
		if keys.attacker and keys.attacker:GetTeam() ~= keys.unit:GetTeam() then
			keys.unit:AddNewModifier(keys.unit, nil, "modifier_damage_taken", {duration = 3})
		end
	end
end

function modifier_shrine_base_state_aura:GetModifierHealthRegenPercentage()
	return self:GetParent():HasModifier("modifier_damage_taken") and 0 or 2.5
end

function modifier_shrine_base_state_aura:GetModifierConstantManaRegen()
	return self:GetParent():HasModifier("modifier_damage_taken") and 0 or 0.03 * self:GetParent():GetMaxMana()
end



modifier_damage_taken = class({})

function modifier_damage_taken:IsHidden() return true end
function modifier_damage_taken:IsDebuff() return true end
function modifier_damage_taken:IsPurgable() return false end



modifier_shrine_active = class({})

function modifier_shrine_active:IsHidden() return true end
function modifier_shrine_active:IsDebuff() return false end
function modifier_shrine_active:IsPurgable() return false end

function modifier_shrine_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end

function modifier_shrine_active:GetOverrideAnimation()
	return ACT_DOTA_CAPTURE
end

function modifier_shrine_active:GetActivityTranslationModifiers()
	return "level2"
end