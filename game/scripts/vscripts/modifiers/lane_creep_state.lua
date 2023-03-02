modifier_lane_creep_state = class({})

function modifier_lane_creep_state:IsHidden() return true end
function modifier_lane_creep_state:IsDebuff() return false end
function modifier_lane_creep_state:IsPurgable() return false end

function modifier_lane_creep_state:OnCreated(keys)
	if IsClient() then return end

	self:StartIntervalThink(0.5)
end

function modifier_lane_creep_state:OnIntervalThink()
	local parent = self:GetParent()

	ResolveNPCPositions(parent:GetAbsOrigin(), 300)

	if parent.lane_path then parent:ExecutePathOrders(parent.lane_path) end

	self:Destroy()
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
	return 10
end