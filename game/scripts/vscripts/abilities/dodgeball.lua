function ThrowBall(caster, ability, speed, radius, target, particle_name, extra_data)
	local caster_loc = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()

	if target ~= caster_loc then
		direction = (target - caster:GetAbsOrigin()):Normalized()
	end

	local projectile = {
		Ability				= ability,
		EffectName			= particle_name,
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1")),
		fDistance			= 3000,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO,
		fExpireTime 		= GameRules:GetGameTime() + 5.0,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x, direction.y, 0) * speed,
		bProvidesVision		= true,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
	}

	ProjectileManager:CreateLinearProjectile(projectile)
end


ability_dodgeball_throw = class({})

function ability_dodgeball_throw:OnSpellStart()
	ThrowBall(self:GetCaster(), self, self:GetSpecialValueFor("speed"), self:GetSpecialValueFor("radius"), self:GetCursorPosition(), "particles/dodgeball/basic_throw.vpcf", {})

	self:GetCaster():EmitSound("Hero_VengefulSpirit.MagicMissile")
end

function ability_dodgeball_throw:OnProjectileHit(target, location)
	if target then
		local caster = self:GetCaster()
		local target_ability = target:FindAbilityByName("ability_dodgeball_throw")

		if target:GetTeam() ~= caster:GetTeam() then
			if target:HasModifier("modifier_dodgeball_phantom") then
				return false
			elseif target:HasModifier("modifier_dodgeball_throwback") and target_ability then
				local throwback_ability = target:FindAbilityByName("ability_dodgeball_throwback")
				local speed_multiplier = 1 + 0.01 * (throwback_ability and throwback_ability:GetSpecialValueFor("bonus_speed") or 0)
				ThrowBall(target, target_ability, speed_multiplier * target_ability:GetSpecialValueFor("speed"), target_ability:GetSpecialValueFor("radius"), caster:GetAbsOrigin(), "particles/dodgeball/basic_throw.vpcf", {})

				target:EmitSound("Counter.Proc")

				return true
			elseif target:FindAbilityByName("ability_dodgeball_reincarnation") and target:FindAbilityByName("ability_dodgeball_reincarnation"):IsActivated() then
				ApplyDamage({attacker = self:GetCaster(), victim = target, damage = 1000, damage_type = DAMAGE_TYPE_PURE})

				return false
			else
				ApplyDamage({attacker = self:GetCaster(), victim = target, damage = 1000, damage_type = DAMAGE_TYPE_PURE})

				target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")

				return true
			end
		end

		return false
	end
end



ability_dodgeball_throwback = class({})

function ability_dodgeball_throwback:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_dodgeball_throwback", {duration = self:GetSpecialValueFor("duration")})

	caster:EmitSound("Counter.Up")
end



LinkLuaModifier("modifier_dodgeball_throwback", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

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



ability_dodgeball_ice_shield = class({})

function ability_dodgeball_ice_shield:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_dodgeball_ice_shield", {duration = self:GetSpecialValueFor("duration")})

	caster:EmitSound("Ice.Shield")
end



LinkLuaModifier("modifier_dodgeball_ice_shield", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

modifier_dodgeball_ice_shield = class({})

function modifier_dodgeball_ice_shield:IsHidden() return false end
function modifier_dodgeball_ice_shield:IsDebuff() return false end
function modifier_dodgeball_ice_shield:IsPurgable() return false end

function modifier_dodgeball_ice_shield:GetEffectName()
	return "particles/dodgeball/ice_block_buff.vpcf"
end

function modifier_dodgeball_ice_shield:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_dodgeball_ice_shield:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_FROZEN] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		}
	end
end

function modifier_dodgeball_ice_shield:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_PROPERTY_DISABLE_TURNING
	}
end

function modifier_dodgeball_ice_shield:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_dodgeball_ice_shield:GetAbsoluteNoDamageMagical() return 1 end
function modifier_dodgeball_ice_shield:GetAbsoluteNoDamagePure() return 1 end
function modifier_dodgeball_ice_shield:GetModifierDisableTurning() return 1 end



ability_dodgeball_magic_missile = class({})

function ability_dodgeball_magic_missile:OnSpellStart()
	local caster = self:GetCaster()
	local throw_ability = caster:FindAbilityByName("ability_dodgeball_throw")

	if not throw_ability then return end

	local speed = throw_ability:GetSpecialValueFor("speed")
	local radius = throw_ability:GetSpecialValueFor("radius")

	local targets = FindUnitsInRadius(caster:GetTeam(), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

	Timers:CreateTimer(0.0, function()
		local current_target = table.remove(targets)

		if current_target and current_target:IsAlive() then
			ThrowBall(caster, throw_ability, speed, radius, current_target:GetAbsOrigin() + RandomVector(RandomInt(40, 100)), "particles/dodgeball/basic_throw.vpcf", {})

			self:GetCaster():EmitSound("Hero_VengefulSpirit.MagicMissile")

			return 0.4
		end
	end)
end



LinkLuaModifier("modifier_dodgeball_hype_up", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

ability_dodgeball_hype_up = class({})

function ability_dodgeball_hype_up:GetIntrinsicModifierName() return "modifier_dodgeball_hype_up" end

modifier_dodgeball_hype_up = class({})

function modifier_dodgeball_hype_up:IsHidden() return false end
function modifier_dodgeball_hype_up:IsDebuff() return false end
function modifier_dodgeball_hype_up:IsPurgable() return false end

function modifier_dodgeball_hype_up:OnCreated(keys)
	if IsServer() then
		self.particles = {}
		self:StartIntervalThink(0.03)
	end
end

function modifier_dodgeball_hype_up:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()

		if parent and parent:IsAlive() and ability and ability:IsCooldownReady() and (not parent:HasModifier("modifier_dodgeball_berserk_buff")) and GameManager:GetGamePhase() == GAME_STATE_BATTLE then
			ability:UseResources(false, false, false, true)
			self:SetStackCount(self:GetStackCount() + 1)

			parent:EmitSound("Hype.Up")

			table.insert(self.particles, ParticleManager:CreateParticle("particles/dodgeball/hype_up.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent))
		end

		if GameManager:GetGamePhase() ~= GAME_STATE_BATTLE then
			self:SetStackCount(0)

			for _, current_particle in pairs(self.particles) do
				ParticleManager:DestroyParticle(current_particle, false)
				ParticleManager:ReleaseParticleIndex(current_particle)
			end

			self.particles = {}
		end
	end
end

function modifier_dodgeball_hype_up:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
end

function modifier_dodgeball_hype_up:GetModifierMoveSpeedBonus_Constant() return 12 * self:GetStackCount() end
function modifier_dodgeball_hype_up:GetModifierPercentageCooldown() return 100 * (1- 0.94 ^ self:GetStackCount()) end





LinkLuaModifier("modifier_dodgeball_berserk", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dodgeball_berserk_immortality", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dodgeball_berserk_buff", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

ability_dodgeball_berserk = class({})

function ability_dodgeball_berserk:GetIntrinsicModifierName() return "modifier_dodgeball_berserk" end

modifier_dodgeball_berserk = class({})

function modifier_dodgeball_berserk:IsHidden() return true end
function modifier_dodgeball_berserk:IsDebuff() return false end
function modifier_dodgeball_berserk:IsPurgable() return false end
function modifier_dodgeball_berserk:IsPermanent() return false end

function modifier_dodgeball_berserk:OnCreated(keys)
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_dodgeball_berserk_immortality", {})
	end
end

modifier_dodgeball_berserk_immortality = class({})

function modifier_dodgeball_berserk_immortality:IsHidden() return true end
function modifier_dodgeball_berserk_immortality:IsDebuff() return false end
function modifier_dodgeball_berserk_immortality:IsPurgable() return false end

function modifier_dodgeball_berserk_immortality:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
	end
end

function modifier_dodgeball_berserk_immortality:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_dodgeball_berserk_immortality:GetAbsoluteNoDamageMagical() return 1 end
function modifier_dodgeball_berserk_immortality:GetAbsoluteNoDamagePure() return 1 end

function modifier_dodgeball_berserk_immortality:OnTakeDamage(keys)
	if IsServer() and keys.unit == self:GetParent() then
		if keys.attacker and GameManager:GetGamePhase() == GAME_STATE_BATTLE then
			local parent = self:GetParent()
			local ability = self:GetAbility()

			parent:AddNewModifier(keys.attacker, ability, "modifier_dodgeball_berserk_buff", {duration = ability:GetSpecialValueFor("duration")})
			parent:EmitSound("Hype.Max")

			local pfx = ParticleManager:CreateParticle("particles/dodgeball/berserk.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pfx, 0, parent:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(pfx)

			local hype_modifier = parent:FindModifierByName("modifier_dodgeball_hype_up")

			if hype_modifier then hype_modifier:SetStackCount(hype_modifier:GetStackCount() + 2) end

			self:Destroy()
		end
	end
end

modifier_dodgeball_berserk_buff = class({})

function modifier_dodgeball_berserk_buff:IsHidden() return false end
function modifier_dodgeball_berserk_buff:IsDebuff() return false end
function modifier_dodgeball_berserk_buff:IsPurgable() return false end

function modifier_dodgeball_berserk_buff:GetHeroEffectName() return "particles/dodgeball/berserk_buff.vpcf" end

function modifier_dodgeball_berserk_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
end

function modifier_dodgeball_berserk_buff:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_dodgeball_berserk_buff:GetAbsoluteNoDamageMagical() return 1 end
function modifier_dodgeball_berserk_buff:GetAbsoluteNoDamagePure() return 1 end

function modifier_dodgeball_berserk_buff:OnDestroy()
	if IsServer() and GameManager:GetGamePhase() == GAME_STATE_BATTLE then
		self:GetParent():Kill(self:GetAbility(), self:GetCaster())
	end
end





ability_dodgeball_phantom = class({})

function ability_dodgeball_phantom:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_dodgeball_phantom", {duration = self:GetSpecialValueFor("duration")})

	caster:EmitSound("Phantom.Activate")
end



LinkLuaModifier("modifier_dodgeball_phantom", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

modifier_dodgeball_phantom = class({})

function modifier_dodgeball_phantom:IsHidden() return false end
function modifier_dodgeball_phantom:IsDebuff() return false end
function modifier_dodgeball_phantom:IsPurgable() return false end

function modifier_dodgeball_phantom:GetHeroEffectName() return "particles/dodgeball/phantom_buff.vpcf" end

function modifier_dodgeball_phantom:GetEffectName() return "particles/dodgeball/phantom_aura.vpcf" end

function modifier_dodgeball_phantom:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_dodgeball_phantom:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		}
	end
end

function modifier_dodgeball_phantom:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
end

function modifier_dodgeball_phantom:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_dodgeball_phantom:GetAbsoluteNoDamageMagical() return 1 end
function modifier_dodgeball_phantom:GetAbsoluteNoDamagePure() return 1 end





LinkLuaModifier("modifier_dodgeball_reincarnation", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

ability_dodgeball_reincarnation = class({})

function ability_dodgeball_reincarnation:GetIntrinsicModifierName() return "modifier_dodgeball_reincarnation" end

modifier_dodgeball_reincarnation = class({})

function modifier_dodgeball_reincarnation:IsHidden() return true end
function modifier_dodgeball_reincarnation:IsDebuff() return false end
function modifier_dodgeball_reincarnation:IsPurgable() return false end
function modifier_dodgeball_reincarnation:IsPermanent() return true end

function modifier_dodgeball_reincarnation:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
	end
end

function modifier_dodgeball_reincarnation:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_dodgeball_reincarnation:GetAbsoluteNoDamageMagical() return 1 end
function modifier_dodgeball_reincarnation:GetAbsoluteNoDamagePure() return 1 end

function modifier_dodgeball_reincarnation:OnTakeDamage(keys)
	if IsServer() and keys.unit == self:GetParent() then
		local parent = self:GetParent()
		local ability = self:GetAbility()

		if keys.attacker and GameManager:GetGamePhase() == GAME_STATE_BATTLE then
			if ability:IsActivated() then
				local phantom_ability = parent:FindAbilityByName("ability_dodgeball_phantom")

				parent:AddNewModifier(parent, phantom_ability, "modifier_dodgeball_phantom", {duration = phantom_ability:GetSpecialValueFor("duration")})
				parent:EmitSound("Phantom.Activate")

				ability:SetActivated(false)
			else
				parent:Kill(ability, keys.attacker)
			end
		end
	end
end





ability_dodgeball_smoke_and_mirrors = class({})

function ability_dodgeball_smoke_and_mirrors:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_dodgeball_smoke_and_mirrors", {duration = self:GetSpecialValueFor("max_duration")})

	if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
		self.channel_position = Vector(-700, -800 + RandomInt(0, 1600), 0)
	else
		self.channel_position = Vector(700, -800 + RandomInt(0, 1600), 0)
	end

	FindClearSpaceForUnit(caster, self.channel_position, true)

	caster:EmitSound("SmokeAndMirrors")

	self.pfx = ParticleManager:CreateParticle("particles/dodgeball/smoke_and_mirrors.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(275, 275, 275))

	self.channel_start_time = GameRules:GetGameTime()
end

function ability_dodgeball_smoke_and_mirrors:OnChannelFinish(interrupted)
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)

	local caster = self:GetCaster()
	local throw_ability = caster:FindAbilityByName("ability_dodgeball_throw")

	caster:RemoveModifierByName("modifier_dodgeball_smoke_and_mirrors")

	local channel_duration = GameRules:GetGameTime() - self.channel_start_time
	local balls_thrown = math.floor(1 + channel_duration / self:GetSpecialValueFor("seconds_per_shot"))

	local all_heroes = HeroList:GetAllHeroes()
	local enemy_heroes = {}

	for _, hero in pairs(all_heroes) do
		if hero:GetTeam() ~= caster:GetTeam() and hero:IsAlive() then
			table.insert(enemy_heroes, hero)
		end
	end

	while balls_thrown > 0 do
		local next_target = table.remove(enemy_heroes)

		if next_target then
			next_target = next_target:GetAbsOrigin() + Vector(0, RandomInt(0, 600) - 300, 0)
		else
			next_target = Vector(0, RandomInt(0, 1800) - 900, 0)
		end 

		ThrowBall(caster, throw_ability, 0.75 * throw_ability:GetSpecialValueFor("speed"), throw_ability:GetSpecialValueFor("radius"), next_target, "particles/dodgeball/basic_throw.vpcf", {})

		balls_thrown = balls_thrown - 1
	end

	caster:EmitSound("Hero_VengefulSpirit.MagicMissile")

	self.channel_start_time = 0
	self.channel_position = Vector(0, 0, 0)
end





LinkLuaModifier("modifier_dodgeball_smoke_and_mirrors", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

modifier_dodgeball_smoke_and_mirrors = class({})

function modifier_dodgeball_smoke_and_mirrors:IsHidden() return true end
function modifier_dodgeball_smoke_and_mirrors:IsDebuff() return false end
function modifier_dodgeball_smoke_and_mirrors:IsPurgable() return false end

function modifier_dodgeball_smoke_and_mirrors:OnCreated(keys)
	if IsServer() then
		self:GetParent():AddNoDraw()
	end
end

function modifier_dodgeball_smoke_and_mirrors:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
	end
end

function modifier_dodgeball_smoke_and_mirrors:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_OUT_OF_GAME] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		}
	end
end