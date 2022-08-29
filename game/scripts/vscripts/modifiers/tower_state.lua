modifier_tower_state = class({})

function modifier_tower_state:IsHidden() return true end
function modifier_tower_state:IsDebuff() return false end
function modifier_tower_state:IsPurgable() return false end

function modifier_tower_state:OnCreated(keys)
	if IsClient() then return end

	self:StartIntervalThink(60)
end

function modifier_tower_state:OnIntervalThink()
	self:IncrementStackCount()
end

function modifier_tower_state:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_PROVIDES_VISION] = true
	}
end

function modifier_tower_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_DEATH
		}
	else
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		}
	end
end

function modifier_tower_state:GetModifierPreAttack_BonusDamage()
	return 10 * self:GetStackCount()
end

function modifier_tower_state:GetModifierAttackSpeedBonus_Constant()
	return 4 * self:GetStackCount()
end

function modifier_tower_state:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		if keys.unit.respawning_tower then
			keys.unit.respawning_tower:Respawn()
			keys.unit:Destroy()
		end
	end
end



modifier_respawning_tower_state = class({})

function modifier_respawning_tower_state:IsHidden() return false end
function modifier_respawning_tower_state:IsDebuff() return true end
function modifier_respawning_tower_state:IsPurgable() return false end

function modifier_respawning_tower_state:GetTexture()
	return "item_repair_kit"
end

function modifier_respawning_tower_state:GetEffectName()
	return "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
end

function modifier_respawning_tower_state:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_respawning_tower_state:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
end

function modifier_respawning_tower_state:DeclareFunctions()
	return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end

function modifier_respawning_tower_state:GetModifierConstantHealthRegen()
	return self:GetParent():GetMaxHealth() / 60
end