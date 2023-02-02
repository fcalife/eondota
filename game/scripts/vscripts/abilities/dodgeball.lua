ability_dodgeball_throw = class({})

function ability_dodgeball_throw:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/basic_throw.vpcf",
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fDistance			= 6000,
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

	caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
end

function ability_dodgeball_throw:OnProjectileHit(target, location)
	local caster = self:GetCaster()

	if caster and target then
		target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")

		ApplyDamage({attacker = caster, victim = target, damage = 1000, damage_type = DAMAGE_TYPE_PURE})

		return true
	end
end

function ability_dodgeball_throw:OnProjectileThinkHandle(projectile)
	local caster = self:GetCaster()
	local team = caster:GetTeam()
	local location = ProjectileManager:GetLinearProjectileLocation(projectile)

	if team == DOTA_TEAM_GOODGUYS and location.x > 0 then ProjectileManager:DestroyLinearProjectile(projectile) end
	if team == DOTA_TEAM_BADGUYS and location.x < 0 then ProjectileManager:DestroyLinearProjectile(projectile) end
end



ability_dodgeball_big_throw = class({})

function ability_dodgeball_big_throw:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/mega_throw.vpcf",
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fDistance			= 6000,
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

	caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
end

function ability_dodgeball_big_throw:OnProjectileHit(target, location)
	local caster = self:GetCaster()

	if caster and target then
		target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")

		ApplyDamage({attacker = caster, victim = target, damage = 1000, damage_type = DAMAGE_TYPE_PURE})

		return false
	end
end

function ability_dodgeball_big_throw:OnProjectileThinkHandle(projectile)
	local caster = self:GetCaster()
	local team = caster:GetTeam()
	local location = ProjectileManager:GetLinearProjectileLocation(projectile)

	if team == DOTA_TEAM_GOODGUYS and location.x > 0 then ProjectileManager:DestroyLinearProjectile(projectile) end
	if team == DOTA_TEAM_BADGUYS and location.x < 0 then ProjectileManager:DestroyLinearProjectile(projectile) end
end



LinkLuaModifier("modifier_dodgeball_throwback", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

ability_dodgeball_throwback = class({})

function ability_dodgeball_throwback:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_dodgeball_throwback", {duration = self:GetSpecialValueFor("duration")})

	caster:EmitSound("DOTA_Item.LinkensSphere.Activate")
end



modifier_dodgeball_throwback = class({})

function modifier_dodgeball_throwback:IsHidden() return false end
function modifier_dodgeball_throwback:IsDebuff() return false end
function modifier_dodgeball_throwback:IsPurgable() return false end

function modifier_dodgeball_throwback:GetEffectName()
	return "particles/dodgeball/throwback_buff.vpcf"
end

function modifier_dodgeball_throwback:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end