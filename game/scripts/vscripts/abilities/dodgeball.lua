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