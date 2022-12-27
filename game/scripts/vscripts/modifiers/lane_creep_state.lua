modifier_lane_creep_state = class({})

function modifier_lane_creep_state:IsHidden() return true end
function modifier_lane_creep_state:IsDebuff() return false end
function modifier_lane_creep_state:IsPurgable() return false end

function modifier_lane_creep_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_DEATH
		}
	end
end

function modifier_lane_creep_state:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		if keys.unit.lane and keys.attacker:IsHero() then
			ArcherCoin(keys.unit:GetAbsOrigin(), ENEMY_TEAM[keys.unit:GetTeam()])
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
	return 10
end