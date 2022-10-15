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
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end

function modifier_tower_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
			MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
			MODIFIER_EVENT_ON_DEATH
		}
	else
		return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		}
	end
end

function modifier_tower_state:GetModifierProvidesFOWVision()
	return 1
end

function modifier_tower_state:GetModifierPreAttack_BonusDamage()
	return 10 * self:GetStackCount()
end

function modifier_tower_state:GetModifierAttackSpeedBonus_Constant()
	return 4 * self:GetStackCount()
end

function modifier_tower_state:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		PassiveGold:GiveGoldToPlayersInTeam(ENEMY_TEAM[keys.unit:GetTeam()], TOWER_KILL_GOLD, 0)

		if keys.unit.respawning_tower then
			keys.unit.respawning_tower:OnDeath(keys)
		end
	end
end

function modifier_tower_state:GetModifierProcAttack_Feedback(keys)
	if keys.target and keys.target:IsHero() then
		local modifier = keys.target:FindModifierByName("modifier_tower_damage_up")
		if modifier then
			ApplyDamage({
				victim = keys.target,
				attacker = keys.attacker,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage = keys.attacker:GetAttackDamage() * (2 ^ modifier:GetStackCount() - 1)
			})
		end

		modifier = keys.target:AddNewModifier(keys.attacker, nil, "modifier_tower_damage_up", {duration = 15})
		modifier:SetStackCount(math.min(TOWER_MAX_DAMAGE_STACKS, modifier:GetStackCount() + 1))
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



modifier_tower_damage_up = class({})

function modifier_tower_damage_up:IsHidden() return false end
function modifier_tower_damage_up:IsDebuff() return true end
function modifier_tower_damage_up:IsPurgable() return false end

function modifier_tower_damage_up:GetTexture()
	return "ursa_fury_swipes"
end



modifier_jungle_tower_shield = class({})

function modifier_jungle_tower_shield:IsHidden() return true end
function modifier_jungle_tower_shield:IsDebuff() return false end
function modifier_jungle_tower_shield:IsPurgable() return false end

function modifier_jungle_tower_shield:OnCreated(keys)
	if IsClient() then return end

	if keys.shield then
		self:SetStackCount(keys.shield)

		self.shield_pfx = ParticleManager:CreateParticle("particles/econ/generic/generic_progress_meter/generic_progress_circle.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(self.shield_pfx, 0, self:GetParent():GetAbsOrigin() + Vector(0, 0, 50))
		ParticleManager:SetParticleControl(self.shield_pfx, 1, Vector(300, 1 - self:GetStackCount() / 250, 0))
		ParticleManager:SetParticleControl(self.shield_pfx, 15, Vector(0, 100, 255))
		ParticleManager:SetParticleControl(self.shield_pfx, 16, Vector(1, 0, 0))
	end
end

function modifier_jungle_tower_shield:OnStackCountChanged(stacks)
	if IsClient() then return end

	if self.shield_pfx then
		ParticleManager:SetParticleControl(self.shield_pfx, 1, Vector(300, 1 - self:GetStackCount() / 250, 0))
	end

	if self:GetStackCount() <= 0 then
		self:Destroy()
	end
end

function modifier_jungle_tower_shield:OnDestroy()
	if IsClient() then return end

	if self.shield_pfx then
		ParticleManager:DestroyParticle(self.shield_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.shield_pfx)
	end
end

function modifier_jungle_tower_shield:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_ATTACKED,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		}
	else
		return {
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		}
	end
end

function modifier_jungle_tower_shield:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_jungle_tower_shield:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_jungle_tower_shield:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_jungle_tower_shield:OnAttacked(keys)
	if keys.target and keys.target == self:GetParent() then
		if keys.attacker:HasModifier("modifier_jungle_attacker") then
			local stacks = (keys.attacker:GetUnitName() == "npc_eon_samurai_knight_attacker" and 5) or 1
			self:SetStackCount(math.max(0, self:GetStackCount() - stacks))
		end
	end
end