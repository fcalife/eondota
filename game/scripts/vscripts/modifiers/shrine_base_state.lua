modifier_shrine_base_state = class({})

function modifier_shrine_base_state:IsHidden() return true end
function modifier_shrine_base_state:IsDebuff() return false end
function modifier_shrine_base_state:IsPurgable() return false end

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