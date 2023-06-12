fen_dash_strike = class({})

function fen_dash_strike:GetSlashRadius()
	local radius = self:GetSpecialValueFor("slash_radius")

	if self:GetCaster():HasModifier("modifier_fen_divine_blade") then radius = 1.5 * radius end

	return radius
end

function fen_dash_strike:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fen_dash_wings", {})

	self:GetCaster():EmitSound("Fen.Dash")
end

function fen_dash_strike:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveModifierByName("modifier_fen_dash_wings")
end

function fen_dash_strike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	local forward = (target - origin):Normalized()

	local distance = self:GetSpecialValueFor("distance")
	local target_distance = math.min(distance, (target - origin):Length2D())

	local destination = origin + target_distance * forward
	local knockback_origin = origin - 100 * forward

	local knockback = {
		center_x = knockback_origin.x,
		center_y = knockback_origin.y,
		center_z = knockback_origin.z,
		knockback_duration = 0.1,
		knockback_distance = target_distance,
		knockback_height = 40,
		should_stun = 0,
		duration = 0.1
	}

	caster:RemoveModifierByName("modifier_knockback")
	caster:AddNewModifier(caster, nil, "modifier_knockback", knockback)

	Timers:CreateTimer(0.1, function()
		self:PerformSlash()

		caster:RemoveModifierByName("modifier_fen_dash_wings")
	end)
end

function fen_dash_strike:PerformSlash()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	local radius = self:GetSlashRadius()
	local damage = self:GetSpecialValueFor("damage")
	local slow_duration = self:GetSpecialValueFor("slow_duration")

	caster:EmitSound("Fen.Dash.Impact")

	local slash_pfx = ParticleManager:CreateParticle("particles/fen/counter_slash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(slash_pfx, 2, caster_loc)
	ParticleManager:ReleaseParticleIndex(slash_pfx)

	if caster:HasModifier("modifier_fen_divine_blade") then
		local divine_slash_pfx = ParticleManager:CreateParticle("particles/fen/counter_slash_divine.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(divine_slash_pfx, 0, caster_loc)
		ParticleManager:ReleaseParticleIndex(divine_slash_pfx)
	end

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
		local hit_pfx = ParticleManager:CreateParticle("particles/fen/counter_slash_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin() + Vector(0, 0, 128))
		ParticleManager:ReleaseParticleIndex(hit_pfx)

		enemy:EmitSound("Fen.Spin.Slash")

		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})

		if enemy:TriggerCounter(caster) then
			ApplyDamage({attacker = caster, victim = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
		else
			enemy:AddNewModifier(caster, self, "modifier_fen_dash_slow", {duration = slow_duration})
		end
	end

	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

	Timers:CreateTimer(0.25, function() caster:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1) end)
end



LinkLuaModifier("modifier_fen_dash_wings", "abilities/fen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fen_dash_slow", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_fen_dash_wings = class({})

function modifier_fen_dash_wings:IsHidden() return true end
function modifier_fen_dash_wings:IsDebuff() return false end
function modifier_fen_dash_wings:IsPurgable() return false end

function modifier_fen_dash_wings:GetEffectName()
	return "particles/fen/fen_dash_trail.vpcf"
end

function modifier_fen_dash_wings:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



modifier_fen_dash_slow = class({})

function modifier_fen_dash_slow:IsHidden() return false end
function modifier_fen_dash_slow:IsDebuff() return true end
function modifier_fen_dash_slow:IsPurgable() return true end

function modifier_fen_dash_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_fen_dash_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end





fen_spin = class({})

function fen_spin:OnToggle()
	local caster = self:GetCaster()

	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_fen_spin", {duration = self:GetSpecialValueFor("duration")})
		self:EndCooldown()
	else
		caster:RemoveModifierByName("modifier_fen_spin")
	end
end

function fen_spin:GetSlashRadius()
	local radius = self:GetSpecialValueFor("slash_radius")

	if self:GetCaster():HasModifier("modifier_fen_divine_blade") then radius = 1.5 * radius end

	return radius
end




LinkLuaModifier("modifier_fen_spin", "abilities/fen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fen_spin_divine", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_fen_spin = class({})

function modifier_fen_spin:IsHidden() return false end
function modifier_fen_spin:IsDebuff() return false end
function modifier_fen_spin:IsPurgable() return false end

function modifier_fen_spin:GetEffectName()
	return "particles/fen/fen_spin.vpcf"
end

function modifier_fen_spin:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_fen_spin:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()
	local parent_loc = parent:GetAbsOrigin()

	parent:EmitSound("Fen.Spin")
	parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

	local ability = self:GetAbility()

	self.radius = ability:GetSlashRadius()
	self.damage = ability:GetSpecialValueFor("damage")
	self.slash_radius = ability:GetSpecialValueFor("slash_radius")
	self.initial_tick = ability:GetSpecialValueFor("initial_tick")
	self.tick_down = ability:GetSpecialValueFor("tick_down")
	self.min_tick = ability:GetSpecialValueFor("min_tick")

	self.current_tick = self.initial_tick
	self.tick_counter = 0
	self.elapsed_time = 0

	self:PerformSlash()

	self:StartIntervalThink(0.03)

	self.spin_pfx = ParticleManager:CreateParticle("particles/fen/fen_spin.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.spin_pfx, 0, parent_loc)
	ParticleManager:SetParticleControl(self.spin_pfx, 2, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(self.spin_pfx, 3, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(self.spin_pfx, 5, Vector(self.radius, 3, 3))
end

function modifier_fen_spin:OnIntervalThink()
	self.elapsed_time = self.elapsed_time + 0.03
	self.tick_counter = self.tick_counter + 0.03

	if self.tick_counter > self.current_tick then
		self.tick_counter = self.tick_counter - self.current_tick
		self.current_tick = math.max(self.min_tick, self.current_tick - self.tick_down)

		self:PerformSlash()
		self:IncrementStackCount()
	end

	local parent = self:GetParent()
	local parent_loc = parent:GetAbsOrigin()

	if self.spin_pfx then
		ParticleManager:SetParticleControl(self.spin_pfx, 0, parent_loc)
		ParticleManager:SetParticleControl(self.spin_pfx, 3, Vector(self.elapsed_time, 0, 0))
	end

	if parent:IsStunned() or parent:IsSilenced() or parent:IsNightmared() then self:Destroy() end
end

function modifier_fen_spin:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	local ability = self:GetAbility()

	parent:StopSound("Fen.Spin")
	parent:EmitSound("Fen.Spin.End")
	parent:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

	if self.spin_pfx then
		ParticleManager:DestroyParticle(self.spin_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.spin_pfx)
	end

	if ability:GetToggleState() then ability:ToggleAbility() end

	ability:UseResources(true, true, true, true)
end

function modifier_fen_spin:CheckState()
	if IsServer() then return { [MODIFIER_STATE_DISARMED] = true } end
end

function modifier_fen_spin:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_ABILITY_START,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
		}
	else
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
		}
	end
end

function modifier_fen_spin:OnAbilityStart(keys)
	if keys.unit and keys.unit == self:GetParent() then
		if keys.ability and keys.ability ~= self:GetAbility() then
			self:Destroy()
		end
	end
end

function modifier_fen_spin:GetModifierMoveSpeedBonus_Percentage()
	return (-1) * self:GetStackCount() * self:GetAbility():GetSpecialValueFor("slow_tick")
end

function modifier_fen_spin:PerformSlash()
	local parent = self:GetCaster()
	local parent_loc = parent:GetAbsOrigin()

	local enemies = FindUnitsInRadius(
		parent:GetTeam(),
		parent_loc,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		local hit_pfx = ParticleManager:CreateParticle("particles/fen/counter_slash_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin() + Vector(0, 0, 128))
		ParticleManager:ReleaseParticleIndex(hit_pfx)

		enemy:EmitSound("Fen.Spin.Slash")

		ApplyDamage({attacker = parent, victim = enemy, damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL})

		if enemy:TriggerCounter(parent) then ApplyDamage({attacker = parent, victim = parent, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL}) end
	end
end



modifier_fen_spin_divine = class({})

function modifier_fen_spin_divine:IsHidden() return false end
function modifier_fen_spin_divine:IsDebuff() return false end
function modifier_fen_spin_divine:IsPurgable() return false end

function modifier_fen_spin_divine:GetEffectName()
	return "particles/fen/fen_spin.vpcf"
end

function modifier_fen_spin_divine:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end





fen_counter = class({})

function fen_counter:OnSpellStart()
	local caster = self:GetCaster()

	caster:EmitSound("Fen.Counter")

	caster:AddNewModifier(caster, self, "modifier_fen_counter", {duration = self:GetSpecialValueFor("duration")})
end

function fen_counter:GetSlashRadius()
	local radius = self:GetSpecialValueFor("slash_radius")

	if self:GetCaster():HasModifier("modifier_fen_divine_blade") then radius = 1.5 * radius end

	return radius
end

function fen_counter:PerformSlash()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	local damage = self:GetSpecialValueFor("slash_damage")
	local radius = self:GetSlashRadius()

	caster:EmitSound("Fen.Counter.Proc")

	local slash_pfx = ParticleManager:CreateParticle("particles/fen/counter_slash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(slash_pfx, 2, caster_loc)
	ParticleManager:ReleaseParticleIndex(slash_pfx)

	if caster:HasModifier("modifier_fen_divine_blade") then
		local divine_slash_pfx = ParticleManager:CreateParticle("particles/fen/counter_slash_divine.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(divine_slash_pfx, 0, caster_loc)
		ParticleManager:ReleaseParticleIndex(divine_slash_pfx)
	end

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
		local hit_pfx = ParticleManager:CreateParticle("particles/fen/counter_slash_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin() + Vector(0, 0, 128))
		ParticleManager:ReleaseParticleIndex(hit_pfx)

		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})

		if enemy:TriggerCounter(caster) then ApplyDamage({attacker = caster, victim = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL}) end
	end

	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

	Timers:CreateTimer(0.25, function() caster:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1) end)

	caster:RemoveModifierByName("modifier_fen_counter")
end

function fen_counter:LaunchProjectile(target, params)
	local caster = self:GetCaster()
	local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

	local counter_projectile = {
		Ability				= self,
		EffectName			= params.particle,
		vSpawnOrigin		= caster:GetAbsOrigin(),
		fDistance			= params.distance,
		fStartRadius		= params.radius,
		fEndRadius			= params.radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime 		= GameRules:GetGameTime() + params.distance / params.speed + 0.01,
		bDeleteOnHit		= false,
		vVelocity			= params.speed * Vector(direction.x, direction.y, 0),
		bProvidesVision		= false,
		iVisionRadius 		= 0,
		iVisionTeamNumber 	= caster:GetTeam(),
		ExtraData			= {damage = params.damage}
	}

	ProjectileManager:CreateLinearProjectile(counter_projectile)

	caster:EmitSound(params.launch_sound)
end

function fen_counter:OnProjectileHit_ExtraData(target, location, data)
	if target then
		ApplyDamage({attacker = self:GetCaster(), victim = target, damage = data.damage, damage_type = DAMAGE_TYPE_PHYSICAL})

		return true
	end
end



LinkLuaModifier("modifier_fen_counter", "abilities/fen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fen_counter_grace_time", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_fen_counter = class({})

function modifier_fen_counter:IsHidden() return false end
function modifier_fen_counter:IsDebuff() return false end
function modifier_fen_counter:IsPurgable() return false end

function modifier_fen_counter:OnCreated(keys)
	if IsClient() then return end

	local parent_loc = self:GetParent():GetAbsOrigin()

	self.shield_pfx = ParticleManager:CreateParticle("particles/fen/counter_shield.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.shield_pfx, 0, parent_loc)
	ParticleManager:SetParticleControl(self.shield_pfx, 1, parent_loc)
end

function modifier_fen_counter:OnDestroy()
	if IsClient() then return end

	if self.shield_pfx then
		ParticleManager:DestroyParticle(self.shield_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.shield_pfx)
	end

	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_fen_counter_grace_time", {duration = 0.25})
end

function modifier_fen_counter:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		}
	else
		return {
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		}
	end
end

function modifier_fen_counter:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
end

function modifier_fen_counter:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_fen_counter:GetAbsoluteNoDamageMagical() return 1 end
function modifier_fen_counter:GetAbsoluteNoDamagePure() return 1 end



modifier_fen_counter_grace_time = class({})

function modifier_fen_counter_grace_time:IsHidden() return true end
function modifier_fen_counter_grace_time:IsDebuff() return false end
function modifier_fen_counter_grace_time:IsPurgable() return false end

function modifier_fen_counter_grace_time:CheckState()
	return { [MODIFIER_STATE_NO_HEALTH_BAR] = true }
end

function modifier_fen_counter_grace_time:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
end

function modifier_fen_counter_grace_time:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_fen_counter_grace_time:GetAbsoluteNoDamageMagical() return 1 end
function modifier_fen_counter_grace_time:GetAbsoluteNoDamagePure() return 1 end





fen_divine_blade = class({})

function fen_divine_blade:OnSpellStart()
	local caster = self:GetCaster()

	caster:EmitSound("Fen.DivineBlade")

	caster:AddNewModifier(caster, self, "modifier_fen_divine_blade", {duration = self:GetSpecialValueFor("duration")})
end



LinkLuaModifier("modifier_fen_divine_blade", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_fen_divine_blade = class({})

function modifier_fen_divine_blade:IsHidden() return false end
function modifier_fen_divine_blade:IsDebuff() return false end
function modifier_fen_divine_blade:IsPurgable() return false end

function modifier_fen_divine_blade:GetEffectName()
	return "particles/fen/fen_divine_wings.vpcf"
end

function modifier_fen_divine_blade:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_fen_divine_blade:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()
	local ability = self:GetAbility()
	local slash_ability = parent:FindAbilityByName("fen_divine_blade_slash")

	if slash_ability then
		slash_ability:RefreshCharges()
		slash_ability:EndCooldown()
	end

	parent:SwapAbilities("fen_divine_blade", "fen_divine_blade_slash", false, true)

	self.sword_pfx = ParticleManager:CreateParticle("particles/fen/fen_divine_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(self.sword_pfx, 0, parent, PATTACH_POINT_FOLLOW, "blade_attachment", Vector(0, 0, 0), false)
end

function modifier_fen_divine_blade:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	parent:SwapAbilities("fen_divine_blade", "fen_divine_blade_slash", true, false)

	if self.sword_pfx then
		ParticleManager:DestroyParticle(self.sword_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.sword_pfx)
	end

	local ability = self:GetAbility()

	if ability then
		local full_cooldown = 20

		ability:EndCooldown()
		ability:StartCooldown(full_cooldown * (self:GetStackCount() >= 3 and 0.5 or 1))
	end
end

function modifier_fen_divine_blade:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}
end

function modifier_fen_divine_blade:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("attack_range")
end

function modifier_fen_divine_blade:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end



fen_divine_blade_slash = class({})

function fen_divine_blade_slash:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	local forward = (target - origin):Normalized()

	caster:SetForwardVector(forward)

	caster:EmitSound("Fen.DivineBlade")

	local precast_pfx = ParticleManager:CreateParticle("particles/fen/fen_divine_slash_precast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(precast_pfx, 0, origin)
	ParticleManager:SetParticleControlOrientation(precast_pfx, 0, caster:GetForwardVector(), caster:GetRightVector(), caster:GetUpVector())
	ParticleManager:ReleaseParticleIndex(precast_pfx)
end

function fen_divine_blade_slash:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	local forward = (target - origin):Normalized()

	local damage = self:GetSpecialValueFor("damage")
	local length = self:GetSpecialValueFor("length")
	local radius = self:GetSpecialValueFor("radius")
	local bonus_duration = self:GetSpecialValueFor("bonus_duration")
	local bonus_attacks = self:GetSpecialValueFor("bonus_attacks")

	local destination = origin + length * forward

	caster:EmitSound("Fen.DivineBlade.Strike")

	caster:SetForwardVector(forward)

	local strike_pfx = ParticleManager:CreateParticle("particles/fen/fen_divine_slash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(strike_pfx, 0, origin)
	ParticleManager:SetParticleControlOrientation(strike_pfx, 0, caster:GetForwardVector(), caster:GetRightVector(), caster:GetUpVector())
	ParticleManager:SetParticleControl(strike_pfx, 1, destination)
	ParticleManager:SetParticleControl(strike_pfx, 2, destination)
	ParticleManager:ReleaseParticleIndex(strike_pfx)

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

	if #enemies > 0 then
		local modifier = caster:FindModifierByName("modifier_fen_divine_blade")

		if modifier then
			modifier:IncrementStackCount()
		end

		local buff_modifier = caster:AddNewModifier(caster, self, "modifier_fen_divine_blade_slash_buff", {duration = bonus_duration})
		buff_modifier:SetStackCount(bonus_attacks)
	end

	for _, enemy in pairs(enemies) do
		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})

		enemy:EmitSound("Fen.DivineBlade.Hit")

		if enemy:TriggerCounter(caster) then ApplyDamage({attacker = caster, victim = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL}) end
	end

	if self:GetCurrentAbilityCharges() <= 0 then
		caster:RemoveModifierByName("modifier_fen_divine_blade")
	end
end



LinkLuaModifier("modifier_fen_divine_blade_slash_buff", "abilities/fen", LUA_MODIFIER_MOTION_NONE)

modifier_fen_divine_blade_slash_buff = class({})

function modifier_fen_divine_blade_slash_buff:IsHidden() return false end
function modifier_fen_divine_blade_slash_buff:IsDebuff() return false end
function modifier_fen_divine_blade_slash_buff:IsPurgable() return false end

function modifier_fen_divine_blade_slash_buff:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
		}
	else
		return {
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
		}
	end
end

function modifier_fen_divine_blade_slash_buff:GetModifierAttackSpeedBonus_Constant()
	return 400
end

function modifier_fen_divine_blade_slash_buff:GetModifierProcAttack_Feedback()
	self:DecrementStackCount()

	if self:GetStackCount() <= 0 then self:Destroy() end
end



request_help_q = class({})
function request_help_q:OnSpellStart() self:GetCaster():EmitSound("Help.Request") end

request_help_w = class({})
function request_help_w:OnSpellStart() self:GetCaster():EmitSound("Help.Request") end

request_help_e = class({})
function request_help_e:OnSpellStart() self:GetCaster():EmitSound("Help.Request") end

request_help_r = class({})
function request_help_r:OnSpellStart() self:GetCaster():EmitSound("Help.Request") end