modifier_firelord_state = class({})

function modifier_firelord_state:IsHidden() return true end
function modifier_firelord_state:IsDebuff() return false end
function modifier_firelord_state:IsPurgable() return false end

function modifier_firelord_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end



modifier_firelord_busy = class({})

function modifier_firelord_busy:IsHidden() return true end
function modifier_firelord_busy:IsDebuff() return false end
function modifier_firelord_busy:IsPurgable() return false end

function modifier_firelord_busy:OnDestroy()
	if IsClient() then return end

	ScoreManager:UpdateEssenceScoreboard()
end



modifier_firelord_fire_visual = class({})

function modifier_firelord_fire_visual:IsHidden() return true end
function modifier_firelord_fire_visual:IsDebuff() return false end
function modifier_firelord_fire_visual:IsPurgable() return false end

function modifier_firelord_fire_visual:GetEffectName()
	return "particles/econ/items/doom/doom_2021_immortal_weapon/doom_2021_immortal_weapon_infernalblade_debuff_flames.vpcf"
end

function modifier_firelord_fire_visual:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end