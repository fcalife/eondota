modifier_nexus_state = class({})

function modifier_nexus_state:IsHidden() return true end
function modifier_nexus_state:IsDebuff() return false end
function modifier_nexus_state:IsPurgable() return false end

function modifier_nexus_state:OnCreated(keys)
	if IsServer() then self:StartIntervalThink(3.0) end
end

function modifier_nexus_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_nexus_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_DEATH,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		}
	else
		return {
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		}
	end
end

function modifier_nexus_state:GetModifierProvidesFOWVision()
	return 1
end

function modifier_nexus_state:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

function modifier_nexus_state:OnAttackLanded(keys)
	if keys.target and keys.target == self:GetParent() then
		local team = keys.target:GetTeam()

		if keys.attacker and keys.attacker:GetTeam() ~= team then
			local health = math.ceil(100 * keys.target:GetHealth() / keys.target:GetMaxHealth())
			ScoreManager:OnNexusHealth(team, health)
		end
	end
end

function modifier_nexus_state:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		GameManager:EndGameWithWinner(ENEMY_TEAM[keys.unit:GetTeam()])
	end
end

function modifier_nexus_state:OnIntervalThink()
	local parent = self:GetParent()

	local enemies = FindUnitsInRadius(
		parent:GetTeam(),
		parent:GetAbsOrigin(),
		nil,
		900,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false
	)

	local plasma_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_plasmafield.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(plasma_pfx, 0, parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(plasma_pfx, 1, Vector(1800, 900, 0))

	parent:EmitSound("Nexus.Plasma")

	Timers:CreateTimer(0.3, function()
		ParticleManager:DestroyParticle(plasma_pfx, false)
		ParticleManager:ReleaseParticleIndex(plasma_pfx)
	end)

	for _, enemy in pairs(enemies) do
		if enemy:GetTeam() ~= DOTA_TEAM_NEUTRALS then
			local delay = 0.5 * (enemy:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() / 900
			Timers:CreateTimer(delay, function()
				enemy:EmitSound("Nexus.Plasma.Hit")

				ApplyDamage({attacker = parent, victim = enemy, damage = 45 + 0.1 * enemy:GetHealth(), damage_type = DAMAGE_TYPE_PURE})
			end)
		end
	end
end