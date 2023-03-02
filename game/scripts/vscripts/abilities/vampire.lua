vampire_shot = class({})

function vampire_shot:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)

	if self:GetCaster():HasModifier("modifier_vampire_hunger") then
		ApplyDamage({victim = self:GetCaster(), attacker = self:GetCaster(), damage = 1, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
	end
end

function vampire_shot:FireOnPosition(target)
	local caster = self:GetCaster()

	local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("radius")
	local max_range = self:GetSpecialValueFor("max_range")

	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local projectile = {
		Ability				= self,
		EffectName			= "particles/dodgeball/vampire/vampire_shot.vpcf",
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

function vampire_shot:OnProjectileHit_ExtraData(target, location, data)
	if target then
		KnockbackArena:Knockback(self:GetCaster(), target, data.x, data.y, 1)

		target:EmitSound("KnockbackArena.LightHit")

		if self:GetCaster():HasModifier("modifier_vampire_hunger") then
			self:GetCaster():Heal(2, self)
		end

		return true
	end
end



vampire_rain = class({})

function vampire_rain:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function vampire_rain:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")
	local formation_time = self:GetSpecialValueFor("formation_time")
	local radius = self:GetSpecialValueFor("radius")

	if caster:HasModifier("modifier_vampire_hunger") then
		ApplyDamage({victim = caster, attacker = caster, damage = 1, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
	end

	caster:EmitSound("Vampire.Rain.Cast")

	local blood_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_ring.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(blood_pfx, 0, target)
	ParticleManager:SetParticleControl(blood_pfx, 1, Vector(radius, 0, 0))

	Timers:CreateTimer(formation_time, function()
		local trigger = MapTrigger(target, TRIGGER_TYPE_CIRCLE, {
			radius = radius
		}, {
			trigger_team = caster:GetTeam(),
			team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
			unit_filter = DOTA_UNIT_TARGET_HERO,
			flag_filter = DOTA_UNIT_TARGET_FLAG_NONE,
		}, function(units)
			self:OnEnemyInRange(units, target)
		end, {})

		Timers:CreateTimer(duration, function()
			caster:EmitSound("Vampire.Rain.Pop")
			ParticleManager:DestroyParticle(blood_pfx, false)
			trigger:Stop()
		end)
	end)
end

function vampire_rain:OnEnemyInRange(units, origin)
	for _, unit in pairs(units) do
		if (not unit:HasModifier("modifier_knockback")) then
			local direction = (unit:GetAbsOrigin() - origin):Normalized()

			KnockbackArena:Knockback(self:GetCaster(), unit, direction.x, direction.y, 1)

			if self:GetCaster():HasModifier("modifier_vampire_hunger") then
				self:GetCaster():Heal(2, self)
			end
		end
	end
end



vampire_mist = class({})

LinkLuaModifier("modifier_vampire_mist", "abilities/vampire", LUA_MODIFIER_MOTION_NONE)

function vampire_mist:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_vampire_mist", {duration = self:GetSpecialValueFor("duration")})

	caster:EmitSound("Vampire.Mist")

	if caster:HasModifier("modifier_vampire_hunger") then
		ApplyDamage({victim = caster, attacker = caster, damage = 1, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
	end
end



modifier_vampire_mist = class({})

function modifier_vampire_mist:IsHidden() return false end
function modifier_vampire_mist:IsDebuff() return false end
function modifier_vampire_mist:IsPurgable() return false end
function modifier_vampire_mist:RemoveOnDeath() return false end
function modifier_vampire_mist:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_vampire_mist:GetStatusEffectName()
	return "particles/status_fx/status_effect_rupture.vpcf"
end

function modifier_vampire_mist:GetEffectName()
	return "particles/dodgeball/vampire/vampire_mist.vpcf"
end

function modifier_vampire_mist:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_vampire_mist:CheckState()
	return {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_SILENCED] = true,
	}
end



vampire_hunger = class({})

LinkLuaModifier("modifier_vampire_hunger", "abilities/vampire", LUA_MODIFIER_MOTION_NONE)

function vampire_hunger:OnToggle()
	local caster = self:GetCaster()

	if self:GetToggleState() then
		caster:EmitSound("Vampire.Hunger")
		caster:AddNewModifier(caster, self, "modifier_vampire_hunger", {})
	else
		caster:RemoveModifierByName("modifier_vampire_hunger")
	end
end



modifier_vampire_hunger = class({})

function modifier_vampire_hunger:IsHidden() return false end
function modifier_vampire_hunger:IsDebuff() return false end
function modifier_vampire_hunger:IsPurgable() return false end
function modifier_vampire_hunger:RemoveOnDeath() return false end
function modifier_vampire_hunger:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_vampire_hunger:GetEffectName()
	return "particles/dodgeball/vampire/vampire_hunger.vpcf"
end

function modifier_vampire_hunger:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end