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
	return 30 + 10 * self:GetStackCount()
end

function modifier_shrine_buff_arcane:GetModifierSpellAmplify_Percentage()
	return 20 + 15 * self:GetStackCount()
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
	return 100 + 50 * self:GetStackCount()
end

function modifier_shrine_buff_frenzy:GetModifierMoveSpeedBonus_Percentage()
	return 20 + 10 * self:GetStackCount()
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
			if (not self.damage_lock) and RollPercentage(math.min(100, 30 + 20 * self:GetStackCount())) then
				self.damage_lock = true

				self:TriggerRandomEffect(keys.unit)
			end
		end
	end
end

function modifier_shrine_buff_catastrophe:TriggerRandomEffect(target)
	if RollPercentage(50) then
		local zap_pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/maelstorm_ti9.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(zap_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
		ParticleManager:ReleaseParticleIndex(zap_pfx)

		ApplyDamage({victim = target, attacker = self:GetParent(), damage = 100 + 0.06 * target:GetHealth(), damage_type = DAMAGE_TYPE_MAGICAL})
		self.damage_lock = false

		target:EmitSound("Catastrophe.Zap")
	else
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

			self.damage_lock = false

			target:EmitSound("Catastrophe.MeteorLand")
		end)
	end
end



modifier_shrine_buff_ultimate = class({})

function modifier_shrine_buff_ultimate:IsHidden() return false end
function modifier_shrine_buff_ultimate:IsDebuff() return false end
function modifier_shrine_buff_ultimate:IsPurgable() return false end

function modifier_shrine_buff_ultimate:GetTexture()
	return "rune_doubledamage"
end

function modifier_shrine_buff_ultimate:GetEffectName()
	return "particles/control_zone/shrine_unstoppable_buff.vpcf"
end

function modifier_shrine_buff_ultimate:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shrine_buff_ultimate:OnCreated(keys)
	if IsClient() then return end

	self:SetStackCount(keys.handicap)
end

function modifier_shrine_buff_ultimate:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
	}
end

function modifier_shrine_buff_ultimate:GetModifierPreAttack_CriticalStrike()
	return 150 + 50 * self:GetStackCount()
end

function modifier_shrine_buff_ultimate:GetModifierStatusResistanceStacking()
	return 30 + 15 * self:GetStackCount()
end