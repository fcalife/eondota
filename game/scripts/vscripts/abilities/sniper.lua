sniper_shot = class({})

function sniper_shot:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)
end

function sniper_shot:FireOnPosition(target)
	local caster = self:GetCaster()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local max_range = self:GetSpecialValueFor("max_range")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/sniper/sniper_shot.vpcf",
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

function sniper_shot:OnProjectileHit_ExtraData(target, location, data)
	if target then
		KnockbackArena:Knockback(self:GetCaster(), target, data.x, data.y, 1)

		target:EmitSound("KnockbackArena.LightHit")

		return true
	end
end



sniper_longshot = class({})

function sniper_longshot:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)
end

function sniper_longshot:FireOnPosition(target)
	local caster = self:GetCaster()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local max_range = self:GetSpecialValueFor("max_range")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/sniper/sniper_shot.vpcf",
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

function sniper_longshot:OnProjectileHit_ExtraData(target, location, data)
	if target then
		KnockbackArena:Knockback(self:GetCaster(), target, data.x, data.y, 1)

		target:EmitSound("KnockbackArena.LightHit")

		return true
	end
end



sniper_run = class({})

LinkLuaModifier("modifier_sniper_run", "abilities/sniper", LUA_MODIFIER_MOTION_NONE)

function sniper_run:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_sniper_run", {duration = self:GetSpecialValueFor("duration")})

	caster:EmitSound("Sniper.Run")
end



modifier_sniper_run = class({})

function modifier_sniper_run:IsHidden() return false end
function modifier_sniper_run:IsDebuff() return false end
function modifier_sniper_run:IsPurgable() return false end

function modifier_sniper_run:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_sniper_run:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_sniper_run:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
	}
end

function modifier_sniper_run:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_bonus")
end

function modifier_sniper_run:GetModifierIgnoreMovespeedLimit()
	return 1
end



sniper_powershot = class({})

function sniper_powershot:OnAbilityPhaseStart()
	local target = self:GetCursorPosition()
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local team = caster:GetTeam()

	local radius = self:GetSpecialValueFor("radius")
	local length = 5000

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

	caster:EmitSound("Sniper.Powershot.Charge")
end

function sniper_powershot:OnAbilityPhaseInterrupted()
	if self.cast_pfx then
		ParticleManager:DestroyParticle(self.cast_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.cast_pfx)
	end

	self:GetCaster():StopSound("Sniper.Powershot.Charge")
end

function sniper_powershot:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)

	if self.cast_pfx then
		ParticleManager:DestroyParticle(self.cast_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.cast_pfx)
	end
end

function sniper_powershot:FireOnPosition(target)
	local caster = self:GetCaster()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_spell_powershot.vpcf",
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fDistance			= 10000,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO,
		fExpireTime 		= GameRules:GetGameTime() + 6.0,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x, direction.y, 0) * speed,
		bProvidesVision		= true,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
		ExtraData			= {x = direction.x, y = direction.y}
	}

	ProjectileManager:CreateLinearProjectile(projectile)

	caster:EmitSound("Sniper.Powershot.Shoot")
end

function sniper_powershot:OnProjectileHit_ExtraData(target, location, data)
	if target then
		KnockbackArena:Knockback(self:GetCaster(), target, data.x, data.y, 2)

		target:EmitSound("Sniper.Powershot.Hit")

		return true
	end
end