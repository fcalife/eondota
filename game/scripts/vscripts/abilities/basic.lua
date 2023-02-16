basic_throw = class({})

function basic_throw:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)
end

function basic_throw:FireOnPosition(target)
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

function basic_throw:OnProjectileHit_ExtraData(target, location, data)
	if target then
		KnockbackArena:Knockback(self:GetCaster(), target, data.x, data.y, 1)

		target:EmitSound("KnockbackArena.LightHit")

		return true
	end
end



basic_cleave = class({})

function basic_cleave:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)
end

function basic_cleave:FireOnPosition(target)
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



basic_mega_beam = class({})

function basic_mega_beam:OnAbilityPhaseStart()
	local target = self:GetCursorPosition()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local team = caster:GetTeam()

	local radius = self:GetSpecialValueFor("radius")
	local length = self:GetSpecialValueFor("length")

	local arrow_end = caster_loc + length * (target - caster_loc):Normalized()

	if self.cast_pfx then
		ParticleManager:DestroyParticle(self.cast_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.cast_pfx)
	end

	self.cast_pfx = ParticleManager:CreateParticle("particles/ui_mouseactions/range_finder_cone.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.cast_pfx, 0, caster_loc)
	ParticleManager:SetParticleControl(self.cast_pfx, 1, caster_loc)
	ParticleManager:SetParticleControl(self.cast_pfx, 2, arrow_end)
	ParticleManager:SetParticleControl(self.cast_pfx, 3, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(self.cast_pfx, 4, PLAYER_COLORS[team])

	caster:EmitSound("Megabeam.Buildup")
end

function basic_mega_beam:OnAbilityPhaseInterrupted()
	if self.cast_pfx then
		ParticleManager:DestroyParticle(self.cast_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.cast_pfx)
	end

	self:GetCaster():StopSound("Megabeam.Buildup")
end

function basic_mega_beam:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)

	if self.cast_pfx then
		ParticleManager:DestroyParticle(self.cast_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.cast_pfx)
	end
end

function basic_mega_beam:FireOnPosition(target)
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	local radius = self:GetSpecialValueFor("radius")
	local length = self:GetSpecialValueFor("length")

	local direction = (target - caster_loc):Normalized()
	local beam_end = caster_loc + length * direction

	local beam_pfx = ParticleManager:CreateParticle("particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(beam_pfx, 0, caster_loc)
	ParticleManager:SetParticleControl(beam_pfx, 1, beam_end)
	ParticleManager:ReleaseParticleIndex(beam_pfx)

	caster:EmitSound("Megabeam.Blast")

	local enemies = FindUnitsInLine(
		caster:GetTeam(),
		caster_loc,
		beam_end,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE
	)

	for _, enemy in pairs(enemies) do
		KnockbackArena:Knockback(caster, enemy, direction.x, direction.y, 2)
		enemy:EmitSound("Megabeam.Hit")
	end
end