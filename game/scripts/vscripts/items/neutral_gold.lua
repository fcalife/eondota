item_neutral_gold = class({})
item_health_potion = class({})
item_mario_star = class({})



LinkLuaModifier("modifier_powerup_star", "items/neutral_gold", LUA_MODIFIER_MOTION_NONE)

modifier_powerup_star = class({})

function modifier_powerup_star:IsHidden() return false end
function modifier_powerup_star:IsDebuff() return false end
function modifier_powerup_star:IsPurgable() return false end

function modifier_powerup_star:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function modifier_powerup_star:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
end

function modifier_powerup_star:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_powerup_star:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
end