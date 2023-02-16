ability_dodgeball_throw = class({})

LinkLuaModifier("modifier_throw_autocast", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

function ability_dodgeball_throw:GetIntrinsicModifierName()
	return "modifier_throw_autocast"
end

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

	if caster:HasModifier("modifier_powerup_triple") then
		Timers:CreateTimer(0, function()
			ProjectileManager:CreateLinearProjectile(projectile)
			caster:EmitSound("Galaga.BasicShot.Launch")
		end)

		Timers:CreateTimer(0.1, function()
			ProjectileManager:CreateLinearProjectile(projectile)
			caster:EmitSound("Galaga.BasicShot.Launch")
		end)

		Timers:CreateTimer(0.2, function()
			ProjectileManager:CreateLinearProjectile(projectile)
			caster:EmitSound("Galaga.BasicShot.Launch")
		end)
	else
		ProjectileManager:CreateLinearProjectile(projectile)
		caster:EmitSound("Galaga.BasicShot.Launch")
	end
end

function ability_dodgeball_throw:OnProjectileHit(target, location)
	local caster = self:GetCaster()

	if caster and target then
		target:EmitSound("Galaga.BasicShot.Hit")

		if caster:HasModifier("modifier_powerup_double") then
			ApplyDamage({attacker = caster, victim = target, damage = 2, damage_type = DAMAGE_TYPE_PURE})
		else
			ApplyDamage({attacker = caster, victim = target, damage = 1, damage_type = DAMAGE_TYPE_PURE})
		end

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



modifier_throw_autocast = class({})

function modifier_throw_autocast:IsHidden() return true end
function modifier_throw_autocast:IsDebuff() return false end
function modifier_throw_autocast:IsPurgable() return false end

function modifier_throw_autocast:OnCreated()
	if IsServer() then self:StartIntervalThink(0.03) end
end

function modifier_throw_autocast:OnIntervalThink()
	local ability = self:GetAbility()

	if ability:GetAutoCastState() and ability:IsCooldownReady() and GameManager:GetGamePhase() == GAME_STATE_BATTLE then
		local parent = self:GetParent()
		local player_cursor = GameManager:GetPlayerCursorPosition(parent)

		parent:SetCursorPosition(player_cursor)

		ability:OnSpellStart()
		ability:UseResources(true, true, true)
	end
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

	if caster:HasModifier("modifier_powerup_triple") then
		Timers:CreateTimer(0, function()
			ProjectileManager:CreateLinearProjectile(projectile)
			caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
		end)

		Timers:CreateTimer(0.1, function()
			ProjectileManager:CreateLinearProjectile(projectile)
			caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
		end)

		Timers:CreateTimer(0.2, function()
			ProjectileManager:CreateLinearProjectile(projectile)
			caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
		end)
	else
		ProjectileManager:CreateLinearProjectile(projectile)
		caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
	end
end

function ability_dodgeball_big_throw:OnProjectileHit(target, location)
	local caster = self:GetCaster()

	if caster and target then
		target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")

		if caster:HasModifier("modifier_powerup_double") then
			ApplyDamage({attacker = caster, victim = target, damage = 4, damage_type = DAMAGE_TYPE_PURE})
		else
			ApplyDamage({attacker = caster, victim = target, damage = 2, damage_type = DAMAGE_TYPE_PURE})
		end

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



duck_nested_explode = class({})

LinkLuaModifier("modifier_duck_nested_explode", "abilities/dodgeball", LUA_MODIFIER_MOTION_NONE)

function duck_nested_explode:GetIntrinsicModifierName()
	return "modifier_duck_nested_explode"
end



modifier_duck_nested_explode = class({})

function modifier_duck_nested_explode:IsHidden() return false end
function modifier_duck_nested_explode:IsDebuff() return false end
function modifier_duck_nested_explode:IsPurgable() return false end

function modifier_duck_nested_explode:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_DEATH } end
end

function modifier_duck_nested_explode:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		local x = keys.unit:GetAbsOrigin().x
		local y = keys.unit:GetAbsOrigin().y

		keys.unit:EmitSound("Galaga.Nested.Pop")

		for i = 1, 3 do
			Ducks:SummonDuck(keys.unit:GetTeam(), x + 125 * (i - 2), y + 150, "nestling")
		end
	end
end