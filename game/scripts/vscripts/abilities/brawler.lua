brawler_shotgun = class({})

function brawler_shotgun:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)
end

function brawler_shotgun:FireOnPosition(target)
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local max_range = self:GetSpecialValueFor("max_range")

	local direction = (target - caster_loc):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/brawler/rock_throw.vpcf",
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

	for i = 1, 3 do
		projectile.vSpawnOrigin = caster_loc + 125 * (i - 2) * Vector(direction.y, (-1) * direction.x, 0) + Vector(0, 0, 100)

		ProjectileManager:CreateLinearProjectile(projectile)
	end

	caster:EmitSound("Brawler.Shotgun.Fire")
end

function brawler_shotgun:OnProjectileHit_ExtraData(target, location, data)
	if target then
		KnockbackArena:Knockback(self:GetCaster(), target, data.x, data.y, 1)

		target:EmitSound("Brawler.Shotgun.Hit")

		return true
	end
end



brawler_reflect = class({})

LinkLuaModifier("modifier_brawler_reflect", "abilities/brawler", LUA_MODIFIER_MOTION_NONE)

function brawler_reflect:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_brawler_reflect", {duration = self:GetSpecialValueFor("duration")})

	caster:EmitSound("Brawler.Reflect")
end



modifier_brawler_reflect = class({})

function modifier_brawler_reflect:IsHidden() return false end
function modifier_brawler_reflect:IsDebuff() return false end
function modifier_brawler_reflect:IsPurgable() return false end

function modifier_brawler_reflect:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end

function modifier_brawler_reflect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



brawler_smash = class({})

function brawler_smash:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Brawler.Smash.Charge")
end

function brawler_smash:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Brawler.Smash.Charge")
end

function brawler_smash:OnSpellStart()
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

	local smash_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_primal_beast/primal_beast_pulverize_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(smash_pfx, 0, location)
	ParticleManager:SetParticleControl(smash_pfx, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(smash_pfx)

	caster:EmitSound("Brawler.Smash.Cast")
end