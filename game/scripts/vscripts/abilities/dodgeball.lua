ability_dodgeball_throw = class({})

function ability_dodgeball_throw:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local speed = self:GetSpecialValueFor("speed")

	self:ThrowBall(caster, target, speed)

	caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
end

function ability_dodgeball_throw:ThrowBall(thrower, target, speed)
	local radius = self:GetSpecialValueFor("radius")

	local direction = (target - thrower:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/basic_throw.vpcf",
		vSpawnOrigin		= thrower:GetAttachmentOrigin(thrower:ScriptLookupAttachment("attach_attack1")),
		fDistance			= 3000,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= thrower,
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
		iVisionTeamNumber 	= thrower:GetTeam(),
	}

	ProjectileManager:CreateLinearProjectile(projectile)
end

function ability_dodgeball_throw:OnProjectileHit(target, location)
	local caster = self:GetCaster()

	if target then
		if target:HasModifier("modifier_dodgeball_throwback") and caster:GetTeam() ~= target:GetTeam() then
			self:ThrowBall(target, caster:GetAbsOrigin(), 1800)

			target:EmitSound("Item.LotusOrb.Activate")
		else
			ApplyDamage({attacker = self:GetCaster(), victim = target, damage = 1000, damage_type = DAMAGE_TYPE_PURE})

			target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		end

		return true
	end
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



ability_dodgeball_big_throw = class({})

function ability_dodgeball_big_throw:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local speed = self:GetSpecialValueFor("speed")

	self:ThrowBall(caster, target, speed)

	caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
end

function ability_dodgeball_big_throw:ThrowBall(thrower, target, speed)
	local radius = self:GetSpecialValueFor("radius")

	local direction = (target - thrower:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/mega_throw.vpcf",
		vSpawnOrigin		= thrower:GetAttachmentOrigin(thrower:ScriptLookupAttachment("attach_attack1")),
		fDistance			= 3000,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= thrower,
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
		iVisionTeamNumber 	= thrower:GetTeam(),
	}

	ProjectileManager:CreateLinearProjectile(projectile)
end

function ability_dodgeball_big_throw:OnProjectileHit(target, location)
	local caster = self:GetCaster()

	if target then
		if target:HasModifier("modifier_dodgeball_throwback") and caster:GetTeam() ~= target:GetTeam() then
			self:ThrowBall(target, caster:GetAbsOrigin(), 1800)

			target:EmitSound("Item.LotusOrb.Activate")
		else
			ApplyDamage({attacker = self:GetCaster(), victim = target, damage = 1000, damage_type = DAMAGE_TYPE_PURE})

			target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		end

		return true
	end
end