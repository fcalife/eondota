modifier_treasure_goblin_state = class({})

function modifier_treasure_goblin_state:IsHidden() return true end
function modifier_treasure_goblin_state:IsDebuff() return false end
function modifier_treasure_goblin_state:IsPurgable() return false end

function modifier_treasure_goblin_state:GetEffectName()
	return "particles/nightshade/nightshade_attach.vpcf"
end

function modifier_treasure_goblin_state:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_treasure_goblin_state:GetStatusEffectName()
	return "particles/nightshade/nightshade.vpcf"
end

function modifier_treasure_goblin_state:OnCreated(keys)
	if IsClient() then return end

	local stacks = math.floor(100 * math.min(1, keys.time / (60 * NEUTRAL_CREEP_SCALING_LIMIT)))
	self:SetStackCount(stacks)

	local parent = self:GetParent()

	if parent then
		local new_health = parent:GetMaxHealth() * (1 + 0.02 * stacks)
		parent:SetBaseMaxHealth(new_health)
		parent:SetMaxHealth(new_health)
		parent:SetHealth(new_health)
	end
end

function modifier_treasure_goblin_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_treasure_goblin_state:GetModifierPreAttack_BonusDamage()
	return 0.01 * self:GetStackCount() * 255
end