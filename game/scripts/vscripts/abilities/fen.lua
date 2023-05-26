fen_dash_strike = class({})

function fen_dash_strike:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector()

	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")

	local destination = origin + distance * forward

	while (distance > 0) and (not GridNav:IsTraversable(destination)) do
		distance = math.max(0, distance - 40)
		destination = origin + distance * forward
	end

	FindClearSpaceForUnit(caster, destination, true)

	EmitSoundOnLocationWithCaster(origin, "Hero_VoidSpirit.AstralStep.Start", caster)
	EmitSoundOnLocationWithCaster(destination, "Hero_VoidSpirit.AstralStep.End", caster)

	local step_pfx = ParticleManager:CreateParticle("particles/fen/fen_dash_strike_dash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(step_pfx, 0, origin)
	ParticleManager:SetParticleControl(step_pfx, 2, destination)
	ParticleManager:ReleaseParticleIndex(step_pfx)

	local enemies = FindUnitsInLine(
		caster:GetTeam(),
		origin,
		destination,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE
	)

	for _, enemy in pairs(enemies) do
		caster:PerformAttack(enemy, true, true, true, true, false, false, false)
	end

	caster:AddNewModifier(caster, self, "modifier_dash_strike_buff", {duration = duration})
end



LinkLuaModifier("modifier_dash_strike_buff", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_dash_strike_buff = class({})

function modifier_dash_strike_buff:IsHidden() return false end
function modifier_dash_strike_buff:IsDebuff() return false end
function modifier_dash_strike_buff:IsPurgable() return false end
function modifier_dash_strike_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_dash_strike_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_dash_strike_buff:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_reduction")
end





fen_berserker_rage = class({})

function fen_berserker_rage:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:EmitSound("Fen.Rage.Cast")

	caster:AddNewModifier(caster, self, "modifier_berserker_rage_buff", {duration = duration})
end



LinkLuaModifier("modifier_berserker_rage_buff", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_berserker_rage_buff = class({})

function modifier_berserker_rage_buff:IsHidden() return false end
function modifier_berserker_rage_buff:IsDebuff() return false end
function modifier_berserker_rage_buff:IsPurgable() return false end

function modifier_berserker_rage_buff:GetEffectName()
	return "particles/fen/berserker_rage_buff.vpcf"
end

function modifier_berserker_rage_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_berserker_rage_buff:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
	else
		return {
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
		}
	end
end

function modifier_berserker_rage_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_berserker_rage_buff:OnTakeDamage(keys)
	if self:GetParent() == keys.attacker then
		local lifesteal = 0.01 * keys.damage * self:GetAbility():GetSpecialValueFor("lifesteal")

		keys.attacker:Heal(lifesteal, self)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.attacker, lifesteal, nil)
	end
end





fen_dash = class({})

function fen_dash:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	local forward = (target - origin):Normalized()

	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")

	local destination = origin + distance * forward

	while (distance > 0) and (not GridNav:IsTraversable(destination)) do
		distance = math.max(0, distance - 50)
		destination = origin + distance * forward
	end

	FindClearSpaceForUnit(caster, destination, true)

	EmitSoundOnLocationWithCaster(origin, "Hero_VoidSpirit.AstralStep.Start", caster)
	EmitSoundOnLocationWithCaster(destination, "Hero_VoidSpirit.AstralStep.End", caster)

	local step_pfx = ParticleManager:CreateParticle("particles/fen/fen_dash_strike_dash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(step_pfx, 0, origin)
	ParticleManager:SetParticleControl(step_pfx, 2, destination)
	ParticleManager:ReleaseParticleIndex(step_pfx)

	local enemies = FindUnitsInLine(
		caster:GetTeam(),
		origin,
		destination,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE
	)

	for _, enemy in pairs(enemies) do
		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	end
end





fen_unleash_the_blade = class({})

function fen_unleash_the_blade:OnSpellStart()
	local caster = self:GetCaster()

	caster:SwapAbilities("fen_unleash_the_blade", "fen_unleash_the_blade_slash", false, true)

	caster:AddNewModifier(caster, self, "modifier_unleash_the_blade_active", {duration = self:GetSpecialValueFor("duration")})
end



LinkLuaModifier("modifier_unleash_the_blade_active", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_unleash_the_blade_active = class({})

function modifier_unleash_the_blade_active:IsHidden() return false end
function modifier_unleash_the_blade_active:IsDebuff() return false end
function modifier_unleash_the_blade_active:IsPurgable() return false end

function modifier_unleash_the_blade_active:GetEffectName()
	return "particles/fallen_snow/unleash_the_blade_active.vpcf"
end

function modifier_unleash_the_blade_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_unleash_the_blade_active:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_unleash_the_blade_active:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("damage_reduction")
end

function modifier_unleash_the_blade_active:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	parent:SwapAbilities("fen_unleash_the_blade", "fen_unleash_the_blade_slash", true, false)
end



fen_unleash_the_blade_slash = class({})

function fen_unleash_the_blade_slash:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector()

	local damage = self:GetSpecialValueFor("damage")
	local length = self:GetSpecialValueFor("length")
	local angle = self:GetSpecialValueFor("angle")

	local destination = origin + length * forward
	local strike_origin = origin - 25 * forward

	caster:EmitSound("FallenSnow.Slash")

	local strike_pfx = ParticleManager:CreateParticle("particles/fallen_snow/unleash_the_blade_slash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(strike_pfx, 0, strike_origin)
	ParticleManager:SetParticleControlOrientation(strike_pfx, 0, caster:GetForwardVector(), caster:GetRightVector(), caster:GetUpVector())
	ParticleManager:ReleaseParticleIndex(strike_pfx)

	local direction = Vector(forward.x, forward.y, 0):Normalized()
	local min_dot_product = math.cos(2 * angle * math.pi / 360)

	local enemies = {}

	local end_enemies = FindUnitsInRadius(
		caster:GetTeam(),
		strike_origin,
		nil,
		length + 25,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false
	)

	for _, enemy in pairs(end_enemies) do
		local enemy_forward = (enemy:GetAbsOrigin() - strike_origin):Normalized()
		local enemy_direction = Vector(enemy_forward.x, enemy_forward.y, 0):Normalized()

		local dot_product = DotProduct(direction, enemy_direction)

		if dot_product >= min_dot_product then
			table.insert(enemies, enemy)
		end
	end

	for _, enemy in pairs(enemies) do
		local slash_damage = ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	end
end





fen_counter = class({})

function fen_counter:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fen_counter_windup", {})
end

function fen_counter:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveModifierByName("modifier_fen_counter_windup")
end

function fen_counter:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	caster:RemoveModifierByName("modifier_fen_counter_windup")

	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")

	local slash_pfx = ParticleManager:CreateParticle("particles/fen/counter_slash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(slash_pfx, 2, caster_loc)
	ParticleManager:ReleaseParticleIndex(slash_pfx)

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		caster_loc,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		local hit_pfx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter_slash.vpcf", PATTACH_ABSORIGIN, enemy)
		ParticleManager:ReleaseParticleIndex(hit_pfx)

		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	end
end



LinkLuaModifier("modifier_fen_counter_windup", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_fen_counter_windup = class({})

function modifier_fen_counter_windup:IsHidden() return false end
function modifier_fen_counter_windup:IsDebuff() return false end
function modifier_fen_counter_windup:IsPurgable() return false end

function modifier_fen_counter_windup:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function modifier_fen_counter_windup:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
end

function modifier_fen_counter_windup:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_fen_counter_windup:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		}
	else
		return {
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		}
	end
end