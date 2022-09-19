knight_storm_bolt = class({})

function knight_storm_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local projectile_speed = self:GetSpecialValueFor("projectile_speed")
	
	local stun_projectile = {
		Ability 			= self,
		Target 				= target,
		Source 				= caster,
		iSourceAttachment	= DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		EffectName 			= "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
		iMoveSpeed			= projectile_speed,
		vSourceLoc 			= caster:GetAbsOrigin(),
		bDrawsOnMinimap 	= false,
		bDodgeable 			= true,
		bIsAttack 			= false,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		flExpireTime 		= GameRules:GetGameTime() + 10,
		bProvidesVision 	= false
	}

	ProjectileManager:CreateTrackingProjectile(stun_projectile)

	caster:EmitSound("Hero_Sven.StormBolt")
end

function knight_storm_bolt:CastFilterResultTarget(target)
	local caster = self:GetCaster()

	if caster:GetTeamNumber() ~= target:GetTeamNumber() and target:HasModifier("modifier_tower_state") then return UF_SUCCESS end

	return UF_FAIL_CUSTOM
end

function knight_storm_bolt:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()

	if caster:GetTeamNumber() ~= target:GetTeamNumber() and target:HasModifier("modifier_tower_state") then return nil end

	return "#error_not_lane_tower"
end

function knight_storm_bolt:OnProjectileHit(target, location)
	local caster = self:GetCaster()

	if self and (not self:IsNull()) and caster and (not caster:IsNull()) and target and (not target:IsNull()) then
		local stun_duration = self:GetSpecialValueFor("stun_duration")

		target:AddNewModifier(caster, self, "modifier_stunned", {duration = stun_duration})

		target:EmitSound("Hero_Sven.StormBoltImpact")
	end

	return true
end