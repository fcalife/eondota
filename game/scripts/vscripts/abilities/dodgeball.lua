ability_dodgeball_throw = class({})

function ability_dodgeball_throw:OnSpellStart()
	local target = self:GetCursorPosition()

	self:ThrowBall(target)
end

function ability_dodgeball_throw:ThrowBall(target)
	local caster = self:GetCaster()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local max_range = self:GetSpecialValueFor("max_range")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/basic_throw.vpcf",
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fDistance			= max_range,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO,
		fExpireTime 		= GameRules:GetGameTime() + 5.0,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x, direction.y, 0) * speed,
		bProvidesVision		= true,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
		ExtraData			= {x = direction.x, y = direction.y}
	}

	ProjectileManager:CreateLinearProjectile(projectile)

	caster:EmitSound("KnockbackArena.LightThrow")
end

function ability_dodgeball_throw:OnProjectileHit_ExtraData(target, location, data)
	if target then
		KnockbackArena:Knockback(self:GetCaster(), target, data.x, data.y, 1)

		target:EmitSound("KnockbackArena.LightHit")

		return true
	end
end



ability_dodgeball_heavy_throw = class({})

function ability_dodgeball_heavy_throw:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireCone(target)
end

function ability_dodgeball_heavy_throw:FireCone(target)
	local caster = self:GetCaster()

	local angle = self:GetSpecialValueFor("angle")
	local length = self:GetSpecialValueFor("length")

	local caster_loc = caster:GetAbsOrigin()
	local direction = (target - caster_loc):Normalized()
	local min_dot_product = math.cos(2 * angle * math.pi / 360)

	local strike_pfx = ParticleManager:CreateParticle("particles/dodgeball/heavy_strike.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(strike_pfx, 0, caster_loc)
	ParticleManager:SetParticleControlOrientation(strike_pfx, 0, caster:GetForwardVector(), caster:GetRightVector(), caster:GetUpVector())
	ParticleManager:ReleaseParticleIndex(strike_pfx)

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		caster_loc,
		nil,
		length,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		local enemy_direction = (enemy:GetAbsOrigin() - caster_loc):Normalized()
		local dot_product = DotProduct(direction, enemy_direction)

		if dot_product >= min_dot_product then
			KnockbackArena:Knockback(caster, enemy, direction.x, direction.y, 2)
			enemy:EmitSound("KnockbackArena.HeavyHit")
		end
	end

	caster:EmitSound("KnockbackArena.HeavyThrow")
end



ability_dodgeball_smash = class({})

function ability_dodgeball_smash:OnSpellStart()
	local caster = self:GetCaster()
	local location = caster:GetAbsOrigin()

	local radius = self:GetSpecialValueFor("radius")

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		location,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		local direction = (enemy:GetAbsOrigin() - location):Normalized()

		KnockbackArena:Knockback(caster, enemy, direction.x, direction.y, 2)

		enemy:EmitSound("KnockbackArena.HeavyHit")
	end

	local smash_pfx = ParticleManager:CreateParticle("particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(smash_pfx, 0, location)
	ParticleManager:SetParticleControl(smash_pfx, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(smash_pfx)

	caster:EmitSound("KnockbackArena.Smash")
end



ability_dodgeball_mega_throw = class({})

function ability_dodgeball_mega_throw:OnSpellStart()
	local target = self:GetCursorPosition()

	self:ThrowBall(target)
end

function ability_dodgeball_mega_throw:ThrowBall(target)
	local caster = self:GetCaster()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local max_range = self:GetSpecialValueFor("max_range")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/mega_throw.vpcf",
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fDistance			= max_range,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO,
		fExpireTime 		= GameRules:GetGameTime() + 5.0,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x, direction.y, 0) * speed,
		bProvidesVision		= true,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
		ExtraData			= {x = direction.x, y = direction.y}
	}

	ProjectileManager:CreateLinearProjectile(projectile)

	caster:EmitSound("KnockbackArena.LongThrow")
end

function ability_dodgeball_mega_throw:OnProjectileHit_ExtraData(target, location, data)
	if target then
		KnockbackArena:Knockback(self:GetCaster(), target, data.x, data.y, 1)

		target:EmitSound("KnockbackArena.LightHit")

		return true
	end
end



ability_dodgeball_save = class({})

function ability_dodgeball_save:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf",
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fDistance			= 5000,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_BASIC,
		fExpireTime 		= GameRules:GetGameTime() + 5.0,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x, direction.y, 0) * speed,
		bProvidesVision		= true,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
	}

	ProjectileManager:CreateLinearProjectile(projectile)

	caster:EmitSound("Hero_Rattletrap.Hookshot.Fire")
end

function ability_dodgeball_save:OnProjectileHit(target, location)
	local caster = self:GetCaster()

	if target and target:HasModifier("modifier_save_pole") then
		local caster_loc = caster:GetAbsOrigin()
		local target_loc = target:GetAbsOrigin()
		local knockback_direction = (target_loc - caster_loc):Normalized()
		local knockback_origin = caster_loc - 100 * knockback_direction

		local distance = (target_loc - caster_loc):Length2D()
		local duration = distance / 3000

		local knockback = {
			center_x = knockback_origin.x,
			center_y = knockback_origin.y,
			center_z = knockback_origin.z,
			knockback_duration = duration,
			knockback_distance = distance,
			knockback_height = 0,
			should_stun = 1,
			duration = duration
		}

		caster:RemoveModifierByName("modifier_knockback")
		caster:AddNewModifier(caster, nil, "modifier_knockback", knockback)

		target:EmitSound("Hero_Rattletrap.Hookshot.Impact")

		return true
	end
end