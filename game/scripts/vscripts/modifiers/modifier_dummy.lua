modifier_dummy_state = class({})

function modifier_dummy_state:IsHidden() return true end
function modifier_dummy_state:IsDebuff() return false end
function modifier_dummy_state:IsPurgable() return false end
function modifier_dummy_state:RemoveOnDeath() return false end
function modifier_dummy_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_dummy_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true
	}
end



modifier_not_on_minimap = class({})

function modifier_not_on_minimap:IsHidden() return true end
function modifier_not_on_minimap:IsDebuff() return false end
function modifier_not_on_minimap:IsPurgable() return false end
function modifier_not_on_minimap:RemoveOnDeath() return false end
function modifier_not_on_minimap:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_not_on_minimap:CheckState()
	return { [MODIFIER_STATE_NOT_ON_MINIMAP] = true }
end