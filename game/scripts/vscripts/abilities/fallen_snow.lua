fallen_snow_ice_bolt = class({})

function fallen_snow_ice_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local radius = self:GetSpecialValueFor("radius")
	local speed = self:GetSpecialValueFor("speed")
	local distance = self:GetSpecialValueFor("distance")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local ice_projectile = {
		Ability				= self,
		EffectName			= "particles/fallen_snow/ice_bolt_projectile.vpcf",
		vSpawnOrigin		= caster:GetAbsOrigin(),
		fDistance			= distance,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime 		= GameRules:GetGameTime() + distance / speed + 0.01,
		bDeleteOnHit		= false,
		vVelocity			= speed * Vector(direction.x, direction.y, 0),
		bProvidesVision		= false,
		iVisionRadius 		= 0,
		iVisionTeamNumber 	= caster:GetTeam(),
	}

	ProjectileManager:CreateLinearProjectile(ice_projectile)

	caster:EmitSound("Hero_Ancient_Apparition.ChillingTouch.Cast")
end

function fallen_snow_ice_bolt:OnProjectileHit(target, location)
	if target then
		target:EmitSound("Hero_Ancient_Apparition.ChillingTouch.Target")

		ApplyDamage({attacker = self:GetCaster(), victim = target, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL})

		return true
	end
end



fallen_snow_frost_nova = class({})

function fallen_snow_frost_nova:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector()

	local distance = self:GetSpecialValueFor("distance")
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")

	local destination = origin + distance * forward

	while (distance > 0) and (not GridNav:IsTraversable(destination)) do
		distance = math.max(0, distance - 50)
		destination = origin + distance * forward
	end

	FindClearSpaceForUnit(caster, destination, true)

	EmitSoundOnLocationWithCaster(origin, "Hero_VoidSpirit.AstralStep.Start", caster)
	EmitSoundOnLocationWithCaster(destination, "Hero_VoidSpirit.AstralStep.End", caster)

	local step_pfx = ParticleManager:CreateParticle("particles/fallen_snow/nova_path.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(step_pfx, 0, origin)
	ParticleManager:SetParticleControl(step_pfx, 1, destination)
	ParticleManager:SetParticleControl(step_pfx, 2, destination)
	ParticleManager:ReleaseParticleIndex(step_pfx)

	local remaining_duration = duration

	Timers:CreateTimer(0, function()
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
			enemy:AddNewModifier(caster, self, "modifier_fallen_snow_nova_slow", {duration = duration})
		end

		remaining_duration = remaining_duration - 0.1

		if remaining_duration > 0 then return 0.1 end
	end)
end



LinkLuaModifier("modifier_fallen_snow_nova_slow", "abilities/fallen_snow", LUA_MODIFIER_MOTION_NONE)

modifier_fallen_snow_nova_slow = class({})

function modifier_fallen_snow_nova_slow:IsHidden() return false end
function modifier_fallen_snow_nova_slow:IsDebuff() return true end
function modifier_fallen_snow_nova_slow:IsPurgable() return false end

function modifier_fallen_snow_nova_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_fallen_snow_nova_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end





fallen_snow_unleash_the_blade = class({})

function fallen_snow_unleash_the_blade:OnSpellStart()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")

	caster:EmitSound("FallenSnow.Ult.Cast")

	local cast_pfx = ParticleManager:CreateParticle("particles/fallen_snow/fallen_snow_ult_cast.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(cast_pfx, 0, caster_loc)
	ParticleManager:ReleaseParticleIndex(cast_pfx)

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
		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	end

	caster:SwapAbilities("fallen_snow_unleash_the_blade", "fallen_snow_unleash_the_blade_slash", false, true)
end





fallen_snow_unleash_the_blade_slash = class({})

function fallen_snow_unleash_the_blade_slash:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector()

	local damage = self:GetSpecialValueFor("secondary_damage")
	local length = self:GetSpecialValueFor("length")
	local radius = self:GetSpecialValueFor("secondary_radius")

	local destination = origin + length * forward

	caster:EmitSound("FallenSnow.Ult.Strike")

	local strike_pfx = ParticleManager:CreateParticle("particles/fallen_snow/fallen_snow_ult.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(strike_pfx, 0, origin)
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

	for _, enemy in pairs(enemies) do
		ApplyDamage({attacker = caster, victim = enemy, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
	end

	caster:SwapAbilities("fallen_snow_unleash_the_blade_slash", "fallen_snow_unleash_the_blade", false, true)
end