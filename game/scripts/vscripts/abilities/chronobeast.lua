LinkLuaModifier("modifier_chronobeast_phase_past", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chronobeast_phase_present", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chronobeast_phase_future", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chronobeast_wait", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chronobeast_channeling", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_god_mode", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_crawling", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)



modifier_boss_god_mode = class({})

function modifier_boss_god_mode:IsHidden() return true end
function modifier_boss_god_mode:IsDebuff() return false end
function modifier_boss_god_mode:IsPurgable() return false end

function modifier_boss_god_mode:GetStatusEffectName()
	return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_boss_god_mode:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_boss_god_mode:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_boss_god_mode:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
end

function modifier_boss_god_mode:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_boss_god_mode:GetAbsoluteNoDamageMagical() return 1 end
function modifier_boss_god_mode:GetAbsoluteNoDamagePure() return 1 end





modifier_boss_crawling = class({})

function modifier_boss_crawling:IsHidden() return true end
function modifier_boss_crawling:IsDebuff() return false end
function modifier_boss_crawling:IsPurgable() return false end

function modifier_boss_crawling:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_boss_crawling:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end

function modifier_boss_crawling:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_boss_crawling:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_boss_crawling:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX
	}
end

function modifier_boss_crawling:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_boss_crawling:GetOverrideAnimationRate()
	return 0.4
end

function modifier_boss_crawling:GetDisableHealing()
	return 1
end

function modifier_boss_crawling:GetModifierMoveSpeed_AbsoluteMax()
	return 140
end

function modifier_boss_crawling:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()
	local angles = parent:GetAnglesAsVector()

	parent:SetAngles(angles.x + 70, angles.y, angles.z)
end

function modifier_boss_crawling:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	local angles = parent:GetAnglesAsVector()

	parent:SetAngles(angles.x - 70, angles.y, angles.z)
end



modifier_chronobeast_phase_past = class({})

function modifier_chronobeast_phase_past:IsHidden() return true end
function modifier_chronobeast_phase_past:IsDebuff() return false end
function modifier_chronobeast_phase_past:IsPurgable() return false end

function modifier_chronobeast_phase_past:CheckState()
	return { [MODIFIER_STATE_DISARMED] = true }
end

function modifier_chronobeast_phase_past:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
end

function modifier_chronobeast_phase_past:GetModifierMoveSpeedBonus_Percentage()
	return 30
end

function modifier_chronobeast_phase_past:GetModifierPercentageCooldown()
	return 20
end



modifier_chronobeast_phase_present = class({})

function modifier_chronobeast_phase_present:IsHidden() return true end
function modifier_chronobeast_phase_present:IsDebuff() return false end
function modifier_chronobeast_phase_present:IsPurgable() return false end

function modifier_chronobeast_phase_present:CheckState()
	return { [MODIFIER_STATE_DISARMED] = true }
end



modifier_chronobeast_phase_future = class({})

function modifier_chronobeast_phase_future:IsHidden() return true end
function modifier_chronobeast_phase_future:IsDebuff() return false end
function modifier_chronobeast_phase_future:IsPurgable() return false end

function modifier_chronobeast_phase_future:CheckState()
	return { [MODIFIER_STATE_DISARMED] = true }
end

function modifier_chronobeast_phase_future:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
end

function modifier_chronobeast_phase_future:GetModifierPercentageCooldown()
	return 40
end



modifier_chronobeast_wait = class({})

function modifier_chronobeast_wait:IsHidden() return true end
function modifier_chronobeast_wait:IsDebuff() return false end
function modifier_chronobeast_wait:IsPurgable() return false end



modifier_chronobeast_channeling = class({})

function modifier_chronobeast_channeling:IsHidden() return true end
function modifier_chronobeast_channeling:IsDebuff() return false end
function modifier_chronobeast_channeling:IsPurgable() return false end

function modifier_chronobeast_channeling:CheckState()
	return { [MODIFIER_STATE_ROOTED] = true }
end

function modifier_chronobeast_channeling:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
end

function modifier_chronobeast_channeling:GetModifierDisableTurning()
	return 1
end





beast_swipe_light = class({})

function beast_swipe_light:GetPlaybackRateOverride()
	return 0.55
end

function beast_swipe_light:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Claw.Light.Windup")
end

function beast_swipe_light:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:GetAbsOrigin() + 125 * caster:GetForwardVector():Normalized()

	self:CleaveFromPosition(target)
end

function beast_swipe_light:CleaveFromPosition(origin)
	local caster = self:GetCaster()

	local angle = self:GetSpecialValueFor("angle")
	local length = self:GetSpecialValueFor("length")

	local direction = caster:GetForwardVector()
	local min_dot_product = math.cos(2 * angle * math.pi / 360)

	local strike_pfx = ParticleManager:CreateParticle("particles/dodgeball/tank/tank_cleave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(strike_pfx, 0, origin)
	ParticleManager:SetParticleControlOrientation(strike_pfx, 0, direction, caster:GetRightVector(), caster:GetUpVector())
	ParticleManager:ReleaseParticleIndex(strike_pfx)

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		origin,
		nil,
		length,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		local enemy_direction = (enemy:GetAbsOrigin() - origin):Normalized()
		local dot_product = DotProduct(direction, enemy_direction)

		if dot_product >= min_dot_product then
			self:Hit(enemy)
		end
	end

	caster:EmitSound("Claw.Light.Smash")
end

function beast_swipe_light:Hit(target)
	PlayRandomClawEffect(target)
	PlayBloodSplatter(target)

	target:EmitSound("Claw.Hit")

	ApplyDamage({attacker = self:GetCaster(), victim = target, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL})

	Knockback(self:GetCaster(), target, {})
end





beast_swipe_heavy = class({})

function beast_swipe_heavy:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_chronobeast_phase_future") then
		return 1.1
	else
		return 1.7
	end
end

function beast_swipe_heavy:GetPlaybackRateOverride()
	if self:GetCaster():HasModifier("modifier_chronobeast_phase_future") then
		return 1.7
	else
		return 1.1
	end
end

function beast_swipe_heavy:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Claw.Heavy.Windup")
end

function beast_swipe_heavy:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster:GetAbsOrigin() + 125 * caster:GetForwardVector():Normalized()

	self:CleaveFromPosition(target)
end

function beast_swipe_heavy:CleaveFromPosition(origin)
	local caster = self:GetCaster()

	local angle = self:GetSpecialValueFor("angle")
	local length = self:GetSpecialValueFor("length")

	local direction = caster:GetForwardVector()
	local min_dot_product = math.cos(2 * angle * math.pi / 360)

	local strike_pfx = ParticleManager:CreateParticle("particles/boss/heavy_swipe.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(strike_pfx, 0, origin)
	ParticleManager:SetParticleControlOrientation(strike_pfx, 0, direction, caster:GetRightVector(), caster:GetUpVector())
	ParticleManager:ReleaseParticleIndex(strike_pfx)

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		origin,
		nil,
		length,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		local enemy_direction = (enemy:GetAbsOrigin() - origin):Normalized()
		local dot_product = DotProduct(direction, enemy_direction)

		if dot_product >= min_dot_product then
			self:Hit(enemy)
		end
	end

	caster:EmitSound("KnockbackArena.HeavyThrow")

	ScreenShake(origin, 20, 60, 0.5, 1400, 0, true)
end

function beast_swipe_heavy:Hit(target)
	PlayRandomClawEffect(target)
	PlayBloodSplatter(target)

	target:EmitSound("Claw.Hit")

	ApplyDamage({attacker = self:GetCaster(), victim = target, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL})

	Knockback(self:GetCaster(), target, {distance = 2})
end





beast_leap = class({})

function beast_leap:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	self.tell_pfx = ParticleManager:CreateParticle("particles/boss/boss_tell_circle.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.tell_pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.tell_pfx, 1, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.tell_pfx, 2, self:GetCursorPosition())
	ParticleManager:SetParticleControl(self.tell_pfx, 3, Vector(self:GetSpecialValueFor("radius"), 0, 0))
end

function beast_leap:OnAbilityPhaseInterrupted()
	if self.tell_pfx then ParticleManager:DestroyParticle(self.tell_pfx, true) end
end

function beast_leap:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local knockback_direction = (target - caster:GetAbsOrigin()):Normalized()
	local knockback_origin = caster:GetAbsOrigin() - 100 * knockback_direction

	local distance = (target - caster:GetAbsOrigin()):Length2D()
	local duration = 0.08 + 0.0003 * distance
	local height = 40 + 0.035 * distance

	local knockback = {
		center_x = knockback_origin.x,
		center_y = knockback_origin.y,
		center_z = knockback_origin.z,
		knockback_duration = duration,
		knockback_distance = distance,
		knockback_height = height,
		should_stun = 0,
		duration = duration
	}

	caster:RemoveModifierByName("modifier_knockback")
	caster:AddNewModifier(caster, nil, "modifier_knockback", knockback)
	caster:AddNewModifier(caster, nil, "modifier_chronobeast_leap_buff", {duration = duration})

	caster:EmitSound("Leap.Cast")

	Timers:CreateTimer(0.5 * duration, function()
		if self.tell_pfx then ParticleManager:DestroyParticle(self.tell_pfx, true) end
	end)

	Timers:CreateTimer(duration, function()
		self:OnLeapArrived(target)
	end)
end

function beast_leap:OnLeapArrived(target)
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")

	caster:EmitSound("Leap.Arrive")

	local impact_pfx = ParticleManager:CreateParticle("particles/boss/leap_ground.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(impact_pfx, 0, target)
	ParticleManager:SetParticleControlOrientation(impact_pfx, 0, caster:GetForwardVector(), caster:GetRightVector(), caster:GetUpVector())
	ParticleManager:ReleaseParticleIndex(impact_pfx)

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		target,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		self:Hit(enemy)
	end

	ScreenShake(target, 15, 80, 0.4, 1400, 0, true)
end

function beast_leap:Hit(target)
	PlayBloodSplatter(target)

	target:EmitSound("Leap.Impact")

	ApplyDamage({attacker = self:GetCaster(), victim = target, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL})

	Knockback(self:GetCaster(), target, {})
end



LinkLuaModifier("modifier_chronobeast_leap_buff", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)



modifier_chronobeast_leap_buff = class({})

function modifier_chronobeast_leap_buff:IsHidden() return true end
function modifier_chronobeast_leap_buff:IsDebuff() return false end
function modifier_chronobeast_leap_buff:IsPurgable() return false end

function modifier_chronobeast_leap_buff:GetEffectName()
	return "particles/boss/leap_buff.vpcf"
end

function modifier_chronobeast_leap_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end





beast_bite = class({})

function beast_bite:GetChannelAnimation()
	return ACT_DOTA_NIAN_PIN_LOOP
end

function beast_bite:GetPlaybackRateOverride()
	if self:GetCaster():HasModifier("modifier_chronobeast_channeling") then return 1.0 end

	return 0.4
end

function beast_bite:OnAbilityPhaseStart()
	self.bite_target = self:GetCursorTarget()

	self:GetCaster():EmitSound("Bite.Roar")

	local caster_loc = self:GetCaster():GetAbsOrigin()

	self.tell_pfx = ParticleManager:CreateParticle("particles/boss/boss_tell_circle.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.tell_pfx, 0, caster_loc)
	ParticleManager:SetParticleControl(self.tell_pfx, 1, caster_loc)
	ParticleManager:SetParticleControl(self.tell_pfx, 2, caster_loc)
	ParticleManager:SetParticleControl(self.tell_pfx, 3, Vector(self:GetCastRange(caster_loc, self.bite_target) + 200, 0, 0))
end

function beast_bite:OnAbilityPhaseInterrupted()
	self.bite_target = nil

	if self.tell_pfx then ParticleManager:DestroyParticle(self.tell_pfx, true) end
end

function beast_bite:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("duration")

	if self.tell_pfx then ParticleManager:DestroyParticle(self.tell_pfx, true) end

	if self.bite_target and (self.bite_target:GetAbsOrigin() - caster_loc):Length2D() <= (self:GetCastRange(caster_loc, self.bite_target) + 200) then
		self.bite_target:AddNewModifier(caster, self, "modifier_chronobeast_bite", {duration = duration})
		caster:AddNewModifier(caster, self, "modifier_chronobeast_channeling", {duration = duration})
		caster:EmitSound("Bite.Roar")
	else
		self.bite_target = nil
	end
end

function beast_bite:OnChannelFinish(interrupted)
	self:GetCaster():RemoveModifierByName("modifier_chronobeast_channeling")

	if self.bite_target then
		self.bite_target:RemoveModifierByName("modifier_chronobeast_bite")
		self.bite_target = nil
	end
end



LinkLuaModifier("modifier_chronobeast_bite", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)



modifier_chronobeast_bite = class({})

function modifier_chronobeast_bite:IsHidden() return false end
function modifier_chronobeast_bite:IsDebuff() return true end
function modifier_chronobeast_bite:IsPurgable() return false end

function modifier_chronobeast_bite:GetStatusEffectName()
	return "particles/boss/bite_status_effect.vpcf"
end

function modifier_chronobeast_bite:GetEffectName()
	return "particles/boss/bite_blood.vpcf"
end

function modifier_chronobeast_bite:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_chronobeast_bite:OnCreated(keys)
	if IsClient() then return end

	self.elapsed_duration = 0.1
	self.damage_tick = 0.5 * self:GetAbility():GetSpecialValueFor("dps")

	self:StartIntervalThink(0.03)
end

function modifier_chronobeast_bite:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local caster_attach = caster:ScriptLookupAttachment("attach_pindown")
	local attach_angles = caster:GetAttachmentAngles(caster_attach)

	parent:SetAbsOrigin(caster:GetAttachmentOrigin(caster_attach))
	parent:SetAngles(attach_angles.x, attach_angles.y, attach_angles.z)

	self.elapsed_duration = self.elapsed_duration + 0.03

	if self.elapsed_duration > 0.5 then
		PlayRandomClawEffect(parent)
		PlayBloodSplatter(parent)

		parent:EmitSound("Bite.Bleed")

		ApplyDamage({attacker = caster, victim = parent, damage = self.damage_tick, damage_type = DAMAGE_TYPE_PHYSICAL})

		self.elapsed_duration = self.elapsed_duration - 0.5
	end
end

function modifier_chronobeast_bite:OnDestroy()
	if IsClient() then return end

	local caster = self:GetCaster()
	local parent = self:GetParent()
	local angles = caster:GetAnglesAsVector()

	FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
	parent:SetAngles(angles.x, angles.y, angles.z)
end

function modifier_chronobeast_bite:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true
		}
	end
end

function modifier_chronobeast_bite:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
end

function modifier_chronobeast_bite:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_chronobeast_bite:GetOverrideAnimationRate()
	return 2
end





beast_tail_smash = class({})

function beast_tail_smash:GetPlaybackRateOverride()
	return 1.25
end

function beast_tail_smash:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Tail.Smash.Windup")

	Timers:CreateTimer(0.6, function() self:GetCaster():EmitSound("Tail.Smash.Windup") end)
	Timers:CreateTimer(1.0, function() self:GetCaster():EmitSound("Tail.Smash.Windup") end)
end

function beast_tail_smash:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local smash_loc = caster_loc - 325 * caster:GetForwardVector()

	local smash_pfx = ParticleManager:CreateParticle("particles/boss/tail_smash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(smash_pfx, 0, smash_loc)
	ParticleManager:SetParticleControl(smash_pfx, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(smash_pfx)

	EmitSoundOnLocationWithCaster(smash_loc, "Tail.Smash.Hit", caster)

	ScreenShake(smash_loc, 15, 80, 0.4, 1400, 0, true)

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		smash_loc,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		PlayBloodSplatter(enemy)

		enemy:EmitSound("Leap.Impact")

		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})

		Knockback(caster, enemy, {distance = 4})
	end
end





beast_tail_spin = class({})

function beast_tail_spin:GetPlaybackRateOverride()
	return 1.0
end

function beast_tail_spin:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	caster:EmitSound("Tail.Spin.Cast")

	self.cast_pfx = ParticleManager:CreateParticle("particles/boss/breath_charge.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.cast_pfx, 0, caster_loc)
end

function beast_tail_spin:OnAbilityPhaseInterrupted()
	if self.cast_pfx then ParticleManager:DestroyParticle(self.cast_pfx, false) end
end

function beast_tail_spin:OnSpellStart()
	local caster = self:GetCaster()

	caster:EmitSound("Tail.Smash.Hit")

	Timers:CreateTimer(0.4, function() caster:EmitSound("Tail.Smash.Hit") end)
	Timers:CreateTimer(0.9, function() caster:EmitSound("Tail.Smash.Hit") end)

	caster:AddNewModifier(caster, self, "modifier_tail_spin_active", {duration = self:GetSpecialValueFor("duration")})
	caster:AddNewModifier(caster, self, "modifier_chronobeast_channeling", {duration = self:GetSpecialValueFor("duration")})

	ScreenShake(caster:GetAbsOrigin(), 10, 40, 1.1, 1400, 0, true)

	if self.cast_pfx then ParticleManager:DestroyParticle(self.cast_pfx, false) end
end



LinkLuaModifier("modifier_tail_spin_active", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_tail_spin_active = class({})

function modifier_tail_spin_active:IsHidden() return true end
function modifier_tail_spin_active:IsDebuff() return false end
function modifier_tail_spin_active:IsPurgable() return false end

function modifier_tail_spin_active:GetEffectName()
	return "particles/boss/leap_buff.vpcf"
end

function modifier_tail_spin_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tail_spin_active:OnCreated(keys)
	if IsClient() then return end

	local ability = self:GetAbility()

	self.damage = ability:GetSpecialValueFor("damage")
	self.radius = ability:GetSpecialValueFor("radius")

	self.enemies_hit = {}

	self:StartIntervalThink(0.06)
end

function modifier_tail_spin_active:OnIntervalThink()
	local parent = self:GetCaster()
	local parent_loc = parent:GetAbsOrigin()

	local tail_attach = parent:ScriptLookupAttachment("attach_stump")
	local smash_loc = parent_loc + 525 * (parent:GetAttachmentOrigin(tail_attach) - parent_loc):Normalized()

	local enemies = FindUnitsInRadius(
		parent:GetTeam(),
		smash_loc,
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	local cracks_pfx = ParticleManager:CreateParticle("particles/boss/spin_cracks.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(cracks_pfx, 0, smash_loc)
	ParticleManager:SetParticleControl(cracks_pfx, 1, Vector(self.radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(cracks_pfx)

	for _, enemy in pairs(enemies) do
		local player_id = enemy:GetPlayerOwnerID()

		if player_id and (not self.enemies_hit[player_id]) then
			self.enemies_hit[player_id] = true

			PlayBloodSplatter(enemy)

			PlayDoubleClawEffect(enemy)

			Knockback(parent, enemy, {distance = 4})

			enemy:EmitSound("Leap.Impact")

			ApplyDamage({attacker = parent, victim = enemy, damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL})
		end
	end
end





beast_breath = class({})

function beast_breath:GetChannelAnimation()
	return ACT_DOTA_TELEPORT
end

function beast_breath:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Breath.Chargeup")

	self.charge_pfx = ParticleManager:CreateParticle("particles/boss/charge_channel.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.charge_pfx, 0, self:GetCaster():GetAbsOrigin())
end

function beast_breath:OnAbilityPhaseInterrupted()
	if self.charge_pfx then ParticleManager:DestroyParticle(self.charge_pfx, true) end
end

function beast_breath:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_chronobeast_channeling", {duration = duration})

	caster:EmitSound("Breath.Beam")
	caster:EmitSound("Breath.Beam.Loop")

	if self.charge_pfx then
		ParticleManager:DestroyParticle(self.charge_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.charge_pfx)
	end

	self.channel_pfx = ParticleManager:CreateParticle("particles/boss/breath_charge.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.channel_pfx, 0, caster_loc)

	self.current_loc = self:GetCursorPosition()

	self.beam_pfx = ParticleManager:CreateParticle("particles/boss/breath_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(self.beam_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_mouthbase", Vector(0, 0, 0), false)
	ParticleManager:SetParticleControl(self.beam_pfx, 1, self.current_loc)

	ScreenShake(caster_loc, 10, 100, 1.5, 1400, 0, true)
end

function beast_breath:OnChannelFinish(interrupted)
	self:GetCaster():StopSound("Breath.Beam")
	self:GetCaster():StopSound("Breath.Beam.Loop")
	self:GetCaster():EmitSound("Breath.Beam.End")

	self:GetCaster():RemoveModifierByName("modifier_chronobeast_channeling")

	if self.channel_pfx then
		ParticleManager:DestroyParticle(self.channel_pfx, interrupted)
		ParticleManager:ReleaseParticleIndex(self.channel_pfx)
	end

	if self.beam_pfx then
		ParticleManager:DestroyParticle(self.beam_pfx, interrupted)
		ParticleManager:ReleaseParticleIndex(self.beam_pfx)
	end
end

function beast_breath:OnChannelThink(interval)
	self:UpdateBeam()
end


function beast_breath:UpdateBeam()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local move_speed = 0.03 * self:GetSpecialValueFor("move_speed")
	local damage = 0.03 * self:GetSpecialValueFor("dps")
	local closest_hero = false
	local distance = 10000

	if (not self.beam_pfx) or (not self.current_loc) then return end

	for _, hero in pairs (HeroList:GetAllHeroes()) do
		local this_hero_distance = (hero:GetAbsOrigin() - self.current_loc):Length2D()

		if this_hero_distance < distance then
			closest_hero = hero
			distance = this_hero_distance
		end
	end

	if closest_hero then
		self.current_loc = self.current_loc + math.min(move_speed, distance) * (closest_hero:GetAbsOrigin() - self.current_loc):Normalized()
	end

	ParticleManager:SetParticleControl(self.beam_pfx, 1, GetGroundPosition(self.current_loc, nil) + Vector(0, 0, 40))

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		self.current_loc,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		local damage_pfx = ParticleManager:CreateParticle("particles/boss/breath_beam_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:ReleaseParticleIndex(damage_pfx)

		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	end
end



beast_roar = class({})

function beast_roar:GetPlaybackRateOverride()
	return 0.8
end

function beast_roar:OnAbilityPhaseStart()
	--self:GetCaster():EmitSound("Hero_PrimalBeast.Uproar.Vox")
end

function beast_roar:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	local damage = self:GetSpecialValueFor("damage")
	local slow = self:GetSpecialValueFor("slow")
	local duration = self:GetSpecialValueFor("duration")

	caster:EmitSound("Hero_PrimalBeast.Uproar.Vox")

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		caster_loc,
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		Knockback(caster, enemy, {distance = 1.5})

		--ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})

		enemy:AddNewModifier(caster, self, "modifier_roar_slow", {duration = duration})
	end

	local roar_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(roar_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_mouthbase", Vector(0, 0, 0), false)
	ParticleManager:ReleaseParticleIndex(roar_pfx)

	local shockwave_pfx = ParticleManager:CreateParticle("particles/boss/roar_shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(shockwave_pfx, 0, caster_loc)
	ParticleManager:ReleaseParticleIndex(shockwave_pfx)

	ScreenShake(caster_loc, 20, 80, 1.25, 2000, 0, true)
end



LinkLuaModifier("modifier_roar_slow", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_roar_slow = class({})

function modifier_roar_slow:IsHidden() return false end
function modifier_roar_slow:IsDebuff() return true end
function modifier_roar_slow:IsPurgable() return false end

function modifier_roar_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_roar_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end





beast_charge = class({})

function beast_charge:GetPlaybackRateOverride()
	return 1.1
end

function beast_charge:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Charge.Windup")
end

function beast_charge:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local target = self:GetCursorPosition()
	local distance = self:GetSpecialValueFor("distance")
	local charge_speed = self:GetSpecialValueFor("charge_speed")

	local direction = (target - caster_loc):Normalized()
	local movement_step = 0.03 * charge_speed * direction
	local destination = caster_loc + distance * direction
	local knockback_origin = caster_loc - 100 * direction

	while (not GridNav:IsTraversable(destination)) do
		distance = math.max(0, distance - 100)
		destination = caster_loc + distance * direction
	end

	local duration = distance / charge_speed

	caster:EmitSound("Charge.Cast")
	caster:EmitSound("Charge.Trample")

	if duration > 0 then caster:AddNewModifier(caster, self, "modifier_charging", {duration = duration, x = movement_step.x, y = movement_step.y}) end
	if duration > 0 then caster:AddNewModifier(caster, self, "modifier_charging_effect", {duration = duration}) end
end



LinkLuaModifier("modifier_charging", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_charging_effect", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_charge_exhausted", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_charge_exhausted_loot", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_charging = class({})

function modifier_charging:IsHidden() return false end
function modifier_charging:IsDebuff() return true end
function modifier_charging:IsPurgable() return false end

function modifier_charging:GetEffectName()
	return "particles/boss/leap_buff.vpcf"
end

function modifier_charging:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_charging:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
	}
end

function modifier_charging:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
end

function modifier_charging:GetOverrideAnimation()
	return ACT_DOTA_MAGNUS_SKEWER_END
end

function modifier_charging:GetModifierDisableTurning()
	return 1
end

function modifier_charging:OnCreated(keys)
	if IsClient() then return end

	local ability = self:GetAbility()

	self.movement_step = Vector(keys.x, keys.y, 0)

	self.damage = ability:GetSpecialValueFor("damage")
	self.stun_duration = ability:GetSpecialValueFor("stun_duration")

	self.crack_counter = RandomInt(1, 3)

	self.enemies_hit = {}

	self:StartIntervalThink(0.03)
end

function modifier_charging:OnIntervalThink()
	local parent = self:GetParent()
	parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin() + self.movement_step, parent))

	local parent_loc = parent:GetAbsOrigin()
	local forward = parent:GetForwardVector()
	local normal = forward:Cross(Vector(0, 0, 1))

	local start_loc = parent_loc - 350 * forward
	local end_loc = parent_loc + 350 * forward

	local enemies = FindUnitsInLine(
		DOTA_TEAM_BADGUYS,
		start_loc,
		end_loc,
		nil,
		275,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE
	)

	for _, enemy in pairs(enemies) do
		local player_id = enemy:GetPlayerOwnerID()

		if player_id and (not self.enemies_hit[player_id]) then
			self.enemies_hit[player_id] = true

			local enemy_loc = enemy:GetAbsOrigin()
			local enemy_direction = (enemy_loc - parent_loc):Normalized()
			local knockback_direction = normal

			if normal:Dot(enemy_direction) < 0 then knockback_direction = (-1) * normal end

			PlayBloodSplatter(enemy)

			PlayDoubleClawEffect(enemy)

			Knockback(parent, enemy, {distance = 3.5, direction = knockback_direction})

			ApplyDamage({attacker = parent, victim = enemy, damage = self.damage, damage_type = DAMAGE_TYPE_PHYSICAL})
		end
	end

	if self.crack_counter <= 1 then
		local cracks_pfx = ParticleManager:CreateParticle("particles/boss/charge_cracks.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(cracks_pfx, 0, parent_loc)
		ParticleManager:SetParticleControl(cracks_pfx, 1, Vector(275, 0, 0))
		ParticleManager:ReleaseParticleIndex(cracks_pfx)

		self.crack_counter = RandomInt(1, 3)
	else
		self.crack_counter = self.crack_counter - 1
	end
end

function modifier_charging:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
	parent:AddNewModifier(parent, self:GetAbility(), "modifier_charge_exhausted", {duration = self.stun_duration})
end



modifier_charging_effect = class({})

function modifier_charging_effect:IsHidden() return false end
function modifier_charging_effect:IsDebuff() return true end
function modifier_charging_effect:IsPurgable() return false end

function modifier_charging_effect:GetEffectName()
	return "particles/boss/charge_active.vpcf"
end

function modifier_charging_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



modifier_charge_exhausted = class({})

function modifier_charge_exhausted:IsHidden() return false end
function modifier_charge_exhausted:IsDebuff() return true end
function modifier_charge_exhausted:IsPurgable() return false end

function modifier_charge_exhausted:GetEffectName()
	return "particles/boss/charge_vulnerable_debuff.vpcf"
end

function modifier_charge_exhausted:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_charge_exhausted:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if SPHERE_TRIGGER_WEAK_POINT then
		if (BossManager:GetCurrentPhase() >= BOSS_PHASE_PRESENT and BossManager:GetEonDropCount() < 1)
			or (BossManager:GetCurrentPhase() >= BOSS_PHASE_PAST and BossManager:GetEonDropCount() < 3)
			or (BossManager:GetCurrentPhase() >= BOSS_PHASE_FUTURE and BossManager:GetEonDropCount() < 5) then

			parent:AddNewModifier(parent, nil, "modifier_charge_exhausted_loot", {})
		end
	end
end

function modifier_charge_exhausted:OnDestroy()
	if IsClient() then return end

	self:GetParent():RemoveModifierByName("modifier_charge_exhausted_loot")
end

function modifier_charge_exhausted:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_charge_exhausted:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_charge_exhausted:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_charge_exhausted:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("dmg_bonus")
end



modifier_charge_exhausted_loot = class({})

function modifier_charge_exhausted_loot:IsHidden() return true end
function modifier_charge_exhausted_loot:IsDebuff() return true end
function modifier_charge_exhausted_loot:IsPurgable() return false end

function modifier_charge_exhausted_loot:GetEffectName()
	return "particles/eon_carrier.vpcf"
end

function modifier_charge_exhausted_loot:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_charge_exhausted_loot:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_TAKEDAMAGE } end
end

function modifier_charge_exhausted_loot:OnTakeDamage(keys)
	if keys.unit == self:GetParent() then
		BossManager:IncrementEonDropCount()

		local map_center = BossManager:GetCurrentMapCenter()
		local position = map_center + 0.01 * RandomInt(5, 80) * (keys.attacker:GetAbsOrigin() - map_center)

		PowerupManager:SpawnPowerUp(keys.unit:GetAbsOrigin(), position, "item_mario_star")

		self:Destroy()
	end
end





beast_spikes = class({})

function beast_spikes:GetIntrinsicModifierName()
	return "modifier_extra_jumps"
end

function beast_spikes:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	caster:EmitSound("Breath.Chargeup")

	self.cast_pfx = ParticleManager:CreateParticle("particles/boss/breath_charge.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.cast_pfx, 0, caster_loc)
end

function beast_spikes:OnAbilityPhaseInterrupted()
	if self.cast_pfx then ParticleManager:DestroyParticle(self.cast_pfx, false) end
end

function beast_spikes:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local target = self:GetCursorTarget()
	local forward = (target:GetAbsOrigin() - caster_loc):Normalized()
	local spikes_origin = caster_loc + 200 * forward

	caster:EmitSound("Bite.Roar")

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local spike_count = self:GetSpecialValueFor("spike_count")
	local jump_time = self:GetSpecialValueFor("jump_time")
	local jump_count = 2

	if caster:HasModifier("modifier_extra_jumps") then
		jump_count = jump_count + caster:FindModifierByName("modifier_extra_jumps"):GetStackCount()
	end

	local spike_projectile = {
		Ability				= self,
		EffectName			= "particles/boss/spike_projectile.vpcf",
		vSpawnOrigin		= spikes_origin,
		fDistance			= 3000,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO,
		fExpireTime 		= GameRules:GetGameTime() + 3000 / speed + 0.01,
		bDeleteOnHit		= false,
		vVelocity			= speed * forward,
		bProvidesVision		= false,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
	}

	caster:AddNewModifier(caster, self, "modifier_chronobeast_channeling", {duration = jump_time * jump_count})
	caster:StartGestureWithPlaybackRate(ACT_DOTA_NIAN_INTRO_LEAP, 1.6)

	Timers:CreateTimer(jump_time, function()
		spike_projectile.fExpireTime = GameRules:GetGameTime() + 3000 / speed + 0.01
		forward = (target:GetAbsOrigin() - caster_loc):Normalized()

		for i = 1, spike_count do
			local direction = RotatePosition(Vector(0, 0, 0), QAngle(0, (i - 1) * 360 / spike_count, 0), forward)
			spike_projectile.vVelocity = speed * Vector(direction.x, direction.y, 0):Normalized()

			ProjectileManager:CreateLinearProjectile(spike_projectile)
		end

		ScreenShake(spikes_origin, 17, 60, 0.7, 2000, 0, true)

		caster:FadeGesture(ACT_DOTA_NIAN_INTRO_LEAP)

		caster:EmitSound("Spikes.Launch")

		jump_count = jump_count - 1

		if jump_count > 0 then
			spike_count = spike_count + 3

			caster:StartGestureWithPlaybackRate(ACT_DOTA_NIAN_INTRO_LEAP, 1.6)

			return jump_time
		else
			if self.cast_pfx then ParticleManager:DestroyParticle(self.cast_pfx, false) end
		end
	end)
end

function beast_spikes:OnProjectileHit(target, location)
	if target and (not target:HasModifier("modifier_knockback")) then
		local caster = self:GetCaster()

		Knockback(caster, target, {distance = 0, duration = 0.3, height = 110})

		ApplyDamage({attacker = caster, victim = target, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_PHYSICAL})

		target:AddNewModifier(caster, self, "modifier_spikes_slow", {duration = self:GetSpecialValueFor("slow_duration")})

		target:EmitSound("Spikes.Hit")

		PlayBloodSplatter(target)

		local hit_pfx = ParticleManager:CreateParticle("particles/boss/spike_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(hit_pfx, 0, target:GetAbsOrigin())

		return false
	end
end



LinkLuaModifier("modifier_extra_jumps", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_extra_jumps = class({})

function modifier_extra_jumps:IsHidden() return true end
function modifier_extra_jumps:IsDebuff() return false end
function modifier_extra_jumps:IsPurgable() return false end



LinkLuaModifier("modifier_spikes_slow", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_spikes_slow = class({})

function modifier_spikes_slow:IsHidden() return false end
function modifier_spikes_slow:IsDebuff() return true end
function modifier_spikes_slow:IsPurgable() return false end

function modifier_spikes_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_spikes_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end





beast_phase_roar = class({})

function beast_phase_roar:GetPlaybackRateOverride()
	return 0.8
end

function beast_phase_roar:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_PrimalBeast.Uproar.Vox")
end

function beast_phase_roar:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	--caster:EmitSound("Hero_PrimalBeast.Uproar.Vox")

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		caster_loc,
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		Knockback(caster, enemy, {distance = 2})

		enemy:AddNewModifier(caster, self, "modifier_phase_transition_roar", {})
	end

	local roar_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(roar_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_mouthbase", Vector(0, 0, 0), false)
	ParticleManager:ReleaseParticleIndex(roar_pfx)

	local shockwave_pfx = ParticleManager:CreateParticle("particles/boss/roar_shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(shockwave_pfx, 0, caster_loc)
	ParticleManager:ReleaseParticleIndex(shockwave_pfx)

	ScreenShake(caster_loc, 20, 80, 1.25, 2000, 0, true)
end



LinkLuaModifier("modifier_phase_transition_roar", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phase_transition_no_damage", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_phase_transition_roar = class({})

function modifier_phase_transition_roar:IsHidden() return false end
function modifier_phase_transition_roar:IsDebuff() return true end
function modifier_phase_transition_roar:IsPurgable() return false end

function modifier_phase_transition_roar:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}
end



modifier_phase_transition_no_damage = class({})

function modifier_phase_transition_no_damage:IsHidden() return true end
function modifier_phase_transition_no_damage:IsDebuff() return true end
function modifier_phase_transition_no_damage:IsPurgable() return false end

function modifier_phase_transition_no_damage:CheckState()
	return { [MODIFIER_STATE_NO_HEALTH_BAR] = true }
end

function modifier_phase_transition_no_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
end

function modifier_phase_transition_no_damage:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_phase_transition_no_damage:GetAbsoluteNoDamageMagical() return 1 end
function modifier_phase_transition_no_damage:GetAbsoluteNoDamagePure() return 1 end



LinkLuaModifier("modifier_phase_transition_beast_state", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_phase_transition_beast_state = class({})

function modifier_phase_transition_beast_state:IsHidden() return false end
function modifier_phase_transition_beast_state:IsDebuff() return true end
function modifier_phase_transition_beast_state:IsPurgable() return false end

function modifier_phase_transition_beast_state:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
end

function modifier_phase_transition_beast_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
	}
end

function modifier_phase_transition_beast_state:GetModifierMoveSpeedBonus_Percentage()
	return 200
end

function modifier_phase_transition_beast_state:GetModifierIgnoreMovespeedLimit()
	return 1
end





beast_controller = class({})

function beast_controller:GetIntrinsicModifierName()
	return "modifier_boss_health_controller"
end



LinkLuaModifier("modifier_boss_health_controller", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_boss_health_controller = class({})

function modifier_boss_health_controller:IsHidden() return true end
function modifier_boss_health_controller:IsDebuff() return false end
function modifier_boss_health_controller:IsPurgable() return false end

function modifier_boss_health_controller:OnCreated()
	if IsClient() then return end

	self.advanced_to_phase_two = false
	self.advanced_to_phase_three = false
end

function modifier_boss_health_controller:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_EVENT_ON_DEATH
		}
	end
end

function modifier_boss_health_controller:OnTakeDamage(keys)
	if keys.unit == self:GetParent() then
		local boss_health = keys.unit:GetHealth()

		if boss_health <= 5000 and self.advanced_to_phase_two and (not self.advanced_to_phase_three) then
			self.advanced_to_phase_three = true

			BossManager:AdvanceToPhaseThree()
		elseif boss_health <= 5000 and (not self.advanced_to_phase_two) then
			self.advanced_to_phase_two = true

			BossManager:AdvanceToPhaseTwo()
		end

		if SPHERE_TRIGGER_HEALTH then
			if BossManager:GetCurrentPhase() == BOSS_PHASE_PRESENT then
				if boss_health <= 7500 and BossManager:GetEonDropCount() < 1 then
					BossManager:IncrementEonDropCount()

					local position = BossManager:GetCurrentMapCenter() + 0.01 * RandomInt(0, 90) * (keys.attacker:GetAbsOrigin() - BossManager:GetCurrentMapCenter())

					PowerupManager:SpawnPowerUp(keys.unit:GetAbsOrigin(), position, "item_mario_star")
				end
			end

			if BossManager:GetCurrentPhase() == BOSS_PHASE_PAST then
				if boss_health <= 7000 and BossManager:GetEonDropCount() < 3 then
					BossManager:IncrementEonDropCount()

					local position = BossManager:GetCurrentMapCenter() + 0.01 * RandomInt(0, 90) * (keys.attacker:GetAbsOrigin() - BossManager:GetCurrentMapCenter())

					PowerupManager:SpawnPowerUp(keys.unit:GetAbsOrigin(), position, "item_mario_star")
				elseif boss_health <= 9000 and BossManager:GetEonDropCount() < 2 then
					BossManager:IncrementEonDropCount()

					local position = BossManager:GetCurrentMapCenter() + 0.01 * RandomInt(0, 90) * (keys.attacker:GetAbsOrigin() - BossManager:GetCurrentMapCenter())

					PowerupManager:SpawnPowerUp(keys.unit:GetAbsOrigin(), position, "item_mario_star")
				end
			end

			if BossManager:GetCurrentPhase() == BOSS_PHASE_FUTURE then
				if boss_health <= 6000 and BossManager:GetEonDropCount() < 5 then
					BossManager:IncrementEonDropCount()

					local position = BossManager:GetCurrentMapCenter() + 0.01 * RandomInt(0, 90) * (keys.attacker:GetAbsOrigin() - BossManager:GetCurrentMapCenter())

					PowerupManager:SpawnPowerUp(keys.unit:GetAbsOrigin(), position, "item_mario_star")
				elseif boss_health <= 9000 and BossManager:GetEonDropCount() < 4 then
					BossManager:IncrementEonDropCount()

					local position = BossManager:GetCurrentMapCenter() + 0.01 * RandomInt(0, 90) * (keys.attacker:GetAbsOrigin() - BossManager:GetCurrentMapCenter())

					PowerupManager:SpawnPowerUp(keys.unit:GetAbsOrigin(), position, "item_mario_star")
				end
			end
		end

		CustomGameEventManager:Send_ServerToAllClients("boss_health", {health = boss_health})
	end
end

function modifier_boss_health_controller:OnDeath(keys)
	if keys.unit == self:GetParent() then
		EmitAnnouncerSound("awolnation_01.music.battle_01_end")

		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	end
end





ability_ressurrect_channel = class({})

function ability_ressurrect_channel:IsHiddenAbilityCastable()
	return true
end

function ability_ressurrect_channel:GetIntrinsicModifierName()
	return "modifier_ressurrect_progress_counter"
end

function ability_ressurrect_channel:GetChannelAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

function ability_ressurrect_channel:GetPlaybackRateOverride()
	return 1.0
end

function ability_ressurrect_channel:OnSpellStart()
	self.channeled_time = 0.0

	local target = self:GetCursorTarget()

	if not target then return end

	local progress = target:GetModifierStackCount("modifier_boss_crawling", target)

	self:GetCaster():FindModifierByName("modifier_ressurrect_progress_counter"):SetStackCount(progress)
end

function ability_ressurrect_channel:OnChannelThink(interval)
	self.channeled_time = self.channeled_time + interval

	if self.channeled_time > 0.05 then
		self.channeled_time = self.channeled_time - 0.05

		local target = self:GetCursorTarget()

		if target then
			local modifier = target:FindModifierByName("modifier_boss_crawling")

			if modifier then modifier:IncrementStackCount() end
		end
	end
end

function ability_ressurrect_channel:GetChannelTime()
	local caster = self:GetCaster()

	local channel_progress = (caster:GetModifierStackCount("modifier_ressurrect_progress_counter", caster)) or 0

	return 5.0 - 0.05 * channel_progress
end

function ability_ressurrect_channel:OnChannelFinish(interrupted)
	if interrupted then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	target:SetHealth(target:GetMaxHealth())

	target:RemoveModifierByName("modifier_boss_crawling")
	caster:FindModifierByName("modifier_ressurrect_progress_counter"):SetStackCount(0)
end



LinkLuaModifier("modifier_ressurrect_progress_counter", "abilities/chronobeast", LUA_MODIFIER_MOTION_NONE)

modifier_ressurrect_progress_counter = class({})

function modifier_ressurrect_progress_counter:IsHidden() return true end
function modifier_ressurrect_progress_counter:IsDebuff() return false end
function modifier_ressurrect_progress_counter:IsPurgable() return false end





--------------------------------------
-- UTILITY
--------------------------------------

function PlayRandomClawEffect(target)
	if RollPercentage(50) then
		local claw_right_pfx = ParticleManager:CreateParticle("particles/boss/swipe_right_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(claw_right_pfx)
	else
		local claw_left_pfx = ParticleManager:CreateParticle("particles/boss/swipe_left_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(claw_left_pfx)
	end
end

function PlayDoubleClawEffect(target)
	local claw_right_pfx = ParticleManager:CreateParticle("particles/boss/swipe_right_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(claw_right_pfx)

	local claw_left_pfx = ParticleManager:CreateParticle("particles/boss/swipe_left_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(claw_left_pfx)
end

function PlayBloodSplatter(target)
	local blood_pfx = ParticleManager:CreateParticle("particles/boss/blood_splatter.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(blood_pfx)
end

function TogglePastPhase(caster)
	if caster:HasModifier("modifier_chronobeast_phase_past") then
		caster:RemoveModifierByName("modifier_chronobeast_phase_past")
	else
		caster:AddNewModifier(caster, self, "modifier_chronobeast_phase_past", {})
	end
end

function ToggleFuturePhase(caster)
	if caster:HasModifier("modifier_chronobeast_phase_future") then
		caster:RemoveModifierByName("modifier_chronobeast_phase_future")
	else
		caster:AddNewModifier(caster, self, "modifier_chronobeast_phase_future", {})
	end
end

function Knockback(caster, target, params)
	local distance = 90 * (params.distance or 1)
	local duration = params.duration or 0.15 + 0.0005 * distance
	local height = params.height or 40 + 0.2 * distance

	local knockback_direction = params.direction or (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	local knockback_origin = target:GetAbsOrigin() - 200 * knockback_direction

	local knockback = {
		center_x = knockback_origin.x,
		center_y = knockback_origin.y,
		center_z = knockback_origin.z,
		knockback_duration = duration,
		knockback_distance = distance,
		knockback_height = height,
		should_stun = 1,
		duration = duration
	}

	target:RemoveModifierByName("modifier_knockback")
	target:AddNewModifier(caster, nil, "modifier_knockback", knockback)
end