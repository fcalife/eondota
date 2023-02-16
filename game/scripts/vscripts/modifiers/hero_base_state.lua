modifier_hero_base_state = class({})

function modifier_hero_base_state:IsHidden() return true end
function modifier_hero_base_state:IsDebuff() return false end
function modifier_hero_base_state:IsPurgable() return false end
function modifier_hero_base_state:RemoveOnDeath() return false end
function modifier_hero_base_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_base_state:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if (not IsInToolsMode()) then parent:AddNewModifier(parent, nil, "modifier_stunned", {duration = 15}) end

	self:StartIntervalThink(0.03)
end

function modifier_hero_base_state:OnIntervalThink()
	local parent = self:GetParent()
	local position = parent:GetAbsOrigin()
	local team = parent:GetTeam()

	if position.x > 0 and team == DOTA_TEAM_GOODGUYS then
		FindClearSpaceForUnit(parent, Vector(-100, position.y, position.z), true)
	elseif position.x < 0 and team == DOTA_TEAM_BADGUYS then
		FindClearSpaceForUnit(parent, Vector(100, position.y, position.z), true)
	end
end

-- function modifier_hero_base_state:CheckState()
-- 	return {
-- 		[MODIFIER_STATE_ROOTED] = true,
-- 	}
-- end

function modifier_hero_base_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
	}
end

function modifier_hero_base_state:GetModifierIgnoreCastAngle()
	return 1
end



modifier_duck = class({})

function modifier_duck:IsHidden() return true end
function modifier_duck:IsDebuff() return false end
function modifier_duck:IsPurgable() return false end

function modifier_duck:OnCreated(keys)
	if IsClient() then return end

	self.speed = keys.speed
	self:SetStackCount(self.speed - 200)

	local parent = self:GetParent()
	local team = parent:GetTeam()
	local position = parent:GetAbsOrigin()

	if RollPercentage(30) then
		position.x = RandomInt(MAP_CENTER, MAP_EDGE)

		if team == DOTA_TEAM_BADGUYS then position.x = (-1) * position.x end
	end

	self.destination = Vector(position.x, FINISH_LINE, 0)

	self:StartIntervalThink(0.2)
end

function modifier_duck:OnIntervalThink()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and self.destination then
		ExecuteOrderFromTable({
			unitIndex = parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = self.destination,
			Queue = false
		})

		local position = parent:GetAbsOrigin()

		if (position.y - self.destination.y) < 10 then
			ScoreManager:OnDuckReachTarget(parent)

			local blast_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/hero_snapfire_shells_impact.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(blast_pfx, 3, position + Vector(0, 0, 100))
			ParticleManager:ReleaseParticleIndex(blast_pfx)

			parent:EmitSound("Galaga.EnemyGoal")

			parent:AddNoDraw()
			parent:Kill(nil, parent)
		end
	end
end

function modifier_duck:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_UNSLOWABLE] = true,
	}
end

function modifier_duck:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
end

function modifier_duck:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end

function modifier_duck:GetModifierIgnoreMovespeedLimit()
	return 1
end



modifier_npc_powerup_cooldown = class({})

function modifier_npc_powerup_cooldown:IsHidden() return false end
function modifier_npc_powerup_cooldown:IsDebuff() return false end
function modifier_npc_powerup_cooldown:IsPurgable() return false end

function modifier_npc_powerup_cooldown:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_DEATH } end
end

function modifier_npc_powerup_cooldown:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() and keys.attacker then
		for _, hero in pairs(HeroList:GetAllHeroes()) do
			if hero:GetTeam() == keys.attacker:GetTeam() then hero:AddNewModifier(hero, nil, "modifier_powerup_cooldown", {duration = 8}) end
		end
	end
end



modifier_npc_powerup_triple = class({})

function modifier_npc_powerup_triple:IsHidden() return false end
function modifier_npc_powerup_triple:IsDebuff() return false end
function modifier_npc_powerup_triple:IsPurgable() return false end

function modifier_npc_powerup_triple:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_DEATH } end
end

function modifier_npc_powerup_triple:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() and keys.attacker then
		for _, hero in pairs(HeroList:GetAllHeroes()) do
			if hero:GetTeam() == keys.attacker:GetTeam() then hero:AddNewModifier(hero, nil, "modifier_powerup_triple", {duration = 8}) end
		end
	end
end



modifier_npc_powerup_double = class({})

function modifier_npc_powerup_double:IsHidden() return false end
function modifier_npc_powerup_double:IsDebuff() return false end
function modifier_npc_powerup_double:IsPurgable() return false end

function modifier_npc_powerup_double:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_DEATH } end
end

function modifier_npc_powerup_double:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() and keys.attacker then
		for _, hero in pairs(HeroList:GetAllHeroes()) do
			if hero:GetTeam() == keys.attacker:GetTeam() then hero:AddNewModifier(hero, nil, "modifier_powerup_double", {duration = 8}) end
		end
	end
end



modifier_powerup_cooldown = class({})

function modifier_powerup_cooldown:IsHidden() return false end
function modifier_powerup_cooldown:IsDebuff() return false end
function modifier_powerup_cooldown:IsPurgable() return false end

function modifier_powerup_cooldown:GetEffectName()
	return "particles/generic_gameplay/rune_arcane_owner.vpcf"
end

function modifier_powerup_cooldown:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_powerup_cooldown:DeclareFunctions()
	return { MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE }
end

function modifier_powerup_cooldown:GetModifierPercentageCooldown()
	return 50
end



modifier_powerup_triple = class({})

function modifier_powerup_triple:IsHidden() return false end
function modifier_powerup_triple:IsDebuff() return false end
function modifier_powerup_triple:IsPurgable() return false end

function modifier_powerup_triple:GetEffectName()
	return "particles/generic_gameplay/rune_haste_owner.vpcf"
end

function modifier_powerup_triple:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



modifier_powerup_double = class({})

function modifier_powerup_double:IsHidden() return false end
function modifier_powerup_double:IsDebuff() return false end
function modifier_powerup_double:IsPurgable() return false end

function modifier_powerup_double:GetEffectName()
	return "particles/generic_gameplay/rune_doubledamage_owner.vpcf"
end

function modifier_powerup_double:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end