tank_cleave = class({})

function tank_cleave:OnSpellStart()
	local target = self:GetCursorPosition()

	self:FireOnPosition(target)
end

function tank_cleave:FireOnPosition(target)
	local caster = self:GetCaster()

	local angle = self:GetSpecialValueFor("angle")
	local length = self:GetSpecialValueFor("length")

	local caster_loc = caster:GetAbsOrigin()
	local direction = (target - caster_loc):Normalized()
	local min_dot_product = math.cos(2 * angle * math.pi / 360)

	local strike_pfx = ParticleManager:CreateParticle("particles/dodgeball/tank/tank_cleave.vpcf", PATTACH_CUSTOMORIGIN, nil)
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
			KnockbackArena:Knockback(caster, enemy, direction.x, direction.y, 1)
			enemy:EmitSound("KnockbackArena.HeavyHit")
		end
	end

	caster:EmitSound("KnockbackArena.HeavyThrow")
end



tank_smash = class({})

function tank_smash:OnSpellStart()
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

	local smash_pfx = ParticleManager:CreateParticle("particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(smash_pfx, 0, location)
	ParticleManager:SetParticleControl(smash_pfx, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(smash_pfx)

	caster:EmitSound("KnockbackArena.Smash")
end



tank_shield = class({})

LinkLuaModifier("modifier_tank_shield", "abilities/tank", LUA_MODIFIER_MOTION_NONE)

function tank_shield:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_tank_shield", {duration = self:GetSpecialValueFor("duration")})

	caster:EmitSound("KnockbackArena.Powerup.Shield")
end



modifier_tank_shield = class({})

function modifier_tank_shield:IsHidden() return false end
function modifier_tank_shield:IsDebuff() return false end
function modifier_tank_shield:IsPurgable() return false end

function modifier_tank_shield:GetEffectName()
	return "particles/dodgeball/tank/tank_shield.vpcf"
end

function modifier_tank_shield:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end