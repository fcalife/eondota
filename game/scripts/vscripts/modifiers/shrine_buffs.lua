modifier_shrine_buff_arcane = class({})

function modifier_shrine_buff_arcane:IsHidden() return false end
function modifier_shrine_buff_arcane:IsDebuff() return false end
function modifier_shrine_buff_arcane:IsPurgable() return false end

function modifier_shrine_buff_arcane:GetTexture()
	return "rune_arcane"
end

function modifier_shrine_buff_arcane:GetEffectName()
	return "particles/control_zone/shrine_arcane_buff.vpcf"
end

function modifier_shrine_buff_arcane:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shrine_buff_arcane:OnCreated(keys)
	if IsClient() then return end

	self:SetStackCount(keys.handicap)
end

function modifier_shrine_buff_arcane:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_shrine_buff_arcane:GetModifierPercentageCooldown()
	return 40 + 10 * self:GetStackCount()
end

function modifier_shrine_buff_arcane:GetModifierSpellAmplify_Percentage()
	return 30 + 10 * self:GetStackCount()
end



modifier_shrine_buff_frenzy = class({})

function modifier_shrine_buff_frenzy:IsHidden() return false end
function modifier_shrine_buff_frenzy:IsDebuff() return false end
function modifier_shrine_buff_frenzy:IsPurgable() return false end

function modifier_shrine_buff_frenzy:GetTexture()
	return "rune_haste"
end

function modifier_shrine_buff_frenzy:GetEffectName()
	return "particles/control_zone/shrine_frenzy_buff.vpcf"
end

function modifier_shrine_buff_frenzy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shrine_buff_frenzy:OnCreated(keys)
	if IsClient() then return end

	self:SetStackCount(keys.handicap)
end

function modifier_shrine_buff_frenzy:CheckState()
	return {
		[MODIFIER_STATE_UNSLOWABLE] = true
	}
end

function modifier_shrine_buff_frenzy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_shrine_buff_frenzy:GetModifierAttackSpeedBonus_Constant()
	return 150 + 50 * self:GetStackCount()
end

function modifier_shrine_buff_frenzy:GetModifierMoveSpeedBonus_Percentage()
	return 25 + 10 * self:GetStackCount()
end



modifier_shrine_buff_catastrophe = class({})

function modifier_shrine_buff_catastrophe:IsHidden() return false end
function modifier_shrine_buff_catastrophe:IsDebuff() return false end
function modifier_shrine_buff_catastrophe:IsPurgable() return false end

function modifier_shrine_buff_catastrophe:GetTexture()
	return "item_fusion_rune"
end

function modifier_shrine_buff_catastrophe:GetEffectName()
	return "particles/control_zone/shrine_catastrophe_buff.vpcf"
end

function modifier_shrine_buff_catastrophe:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shrine_buff_catastrophe:OnCreated(keys)
	if IsClient() then return end

	self:SetStackCount(keys.handicap)
	self.damage_lock = false
end

function modifier_shrine_buff_catastrophe:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_TOOLTIP
		}
	else
		return {
			MODIFIER_PROPERTY_TOOLTIP
		}
	end
end

function modifier_shrine_buff_catastrophe:OnTooltip()
	return math.min(100, 30 + 20 * self:GetStackCount())
end

function modifier_shrine_buff_catastrophe:OnTakeDamage(keys)
	if keys.attacker and keys.attacker == self:GetParent() then
		if keys.unit and keys.attacker:GetTeam() ~= keys.unit:GetTeam() then
			if (not keys.unit.damage_lock) and RollPercentage(math.min(100, 20 + 20 * self:GetStackCount())) then
				keys.unit.damage_lock = true

				self:TriggerRandomEffect(keys.unit)
			end
		end
	end
end

function modifier_shrine_buff_catastrophe:TriggerRandomEffect(target)
	if RollPercentage(34) then
		local zap_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(zap_pfx, 0, target:GetAbsOrigin() + Vector(0, 0, 800))
		ParticleManager:SetParticleControlEnt(zap_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
		ParticleManager:ReleaseParticleIndex(zap_pfx)

		ApplyDamage({victim = target, attacker = self:GetParent(), damage = 100 + 0.1 * target:GetHealth(), damage_type = DAMAGE_TYPE_MAGICAL})
		target.damage_lock = false

		target:EmitSound("Catastrophe.Zap")
	elseif RollPercentage(50) then
		target:EmitSound("Catastrophe.MeteorLaunch")

		local meteor_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(meteor_pfx, 0, target:GetAbsOrigin() + Vector(0, 0, 1200) + RandomVector(300))
		ParticleManager:SetParticleControlEnt(meteor_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
		ParticleManager:SetParticleControl(meteor_pfx, 2, Vector(1.4, 0, 0))
		ParticleManager:ReleaseParticleIndex(meteor_pfx)

		Timers:CreateTimer(1.4, function()
			if target and target:IsAlive() then
				ApplyDamage({victim = target, attacker = self:GetParent(), damage = 200 + 0.08 * target:GetHealth(), damage_type = DAMAGE_TYPE_MAGICAL})
			end

			target.damage_lock = false

			target:EmitSound("Catastrophe.MeteorLand")
		end)
	else
		local spike_pfx = ParticleManager:CreateParticle("particles/econ/items/lion/lion_ti9/lion_spell_impale_hit_ti9_spikes.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(spike_pfx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(spike_pfx, 1, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(spike_pfx)

		ApplyDamage({victim = target, attacker = self:GetParent(), damage = 300 + 0.06 * target:GetHealth(), damage_type = DAMAGE_TYPE_MAGICAL})
		target.damage_lock = false

		target:EmitSound("Catastrophe.Spike")
	end
end



modifier_shrine_buff_ultimate = class({})

function modifier_shrine_buff_ultimate:IsHidden() return false end
function modifier_shrine_buff_ultimate:IsDebuff() return false end
function modifier_shrine_buff_ultimate:IsPurgable() return false end

function modifier_shrine_buff_ultimate:GetTexture()
	return "black_dragon_dragonhide_aura"
end

function modifier_shrine_buff_ultimate:GetEffectName()
	return "particles/control_zone/shrine_unstoppable_buff.vpcf"
end

function modifier_shrine_buff_ultimate:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shrine_buff_ultimate:OnCreated(keys)
	if IsClient() then return end

	self:SetStackCount(keys.stacks)
end

function modifier_shrine_buff_ultimate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_shrine_buff_ultimate:GetModifierSpellAmplify_Percentage()
	return 20 + 30 * (self:GetStackCount() - 1)
end

function modifier_shrine_buff_ultimate:GetModifierDamageOutgoing_Percentage()
	return 20 + 30 * (self:GetStackCount() - 1)
end