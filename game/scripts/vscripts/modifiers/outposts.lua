modifier_fountain_outpost_thinker = class({})

function modifier_fountain_outpost_thinker:IsHidden() return false end
function modifier_fountain_outpost_thinker:IsDebuff() return false end
function modifier_fountain_outpost_thinker:IsPurgable() return false end

function modifier_fountain_outpost_thinker:IsAura() return true end
function modifier_fountain_outpost_thinker:GetModifierAura() return "modifier_fountain_outpost_buff" end
function modifier_fountain_outpost_thinker:GetAuraRadius() return 350 end
function modifier_fountain_outpost_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_fountain_outpost_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_fountain_outpost_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end



modifier_fountain_outpost_buff = class({})

function modifier_fountain_outpost_buff:IsHidden() return false end
function modifier_fountain_outpost_buff:IsDebuff() return false end
function modifier_fountain_outpost_buff:IsPurgable() return false end

function modifier_fountain_outpost_buff:GetTexture() return "rune_regen" end

function modifier_fountain_outpost_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_fountain_outpost_buff:GetModifierHealthRegenPercentage()
	return 5
end

function modifier_fountain_outpost_buff:GetModifierConstantManaRegen()
	return 0.07 * self:GetParent():GetMaxMana()
end



modifier_not_on_minimap_for_enemies = class({})

function modifier_not_on_minimap_for_enemies:IsHidden() return true end
function modifier_not_on_minimap_for_enemies:IsDebuff() return false end
function modifier_not_on_minimap_for_enemies:IsPurgable() return false end
function modifier_not_on_minimap_for_enemies:RemoveOnDeath() return false end
function modifier_not_on_minimap_for_enemies:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_not_on_minimap_for_enemies:CheckState()
	return { [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true }
end



modifier_outpost_state = class({})

function modifier_outpost_state:IsHidden() return true end
function modifier_outpost_state:IsDebuff() return false end
function modifier_outpost_state:IsPurgable() return false end
function modifier_outpost_state:RemoveOnDeath() return false end
function modifier_outpost_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_outpost_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true
	}
end



ability_outpost_defense = class({})

function ability_outpost_defense:GetIntrinsicModifierName()
	return "modifier_outpost_defense"
end

function ability_outpost_defense:OnProjectileHit(target, location)
	if target and (not target:IsNull()) and target:IsAlive() then
		ApplyDamage({attacker = self:GetCaster(), victim = target, damage = 30 + 0.06 * target:GetMaxHealth() + 10 * target:GetLevel(), damage_type = DAMAGE_TYPE_PHYSICAL})
	end
end



modifier_outpost_defense = class({})

function modifier_outpost_defense:IsHidden() return true end
function modifier_outpost_defense:IsDebuff() return false end
function modifier_outpost_defense:IsPurgable() return false end

function modifier_outpost_defense:OnCreated(keys)
	if IsServer() then self:StartIntervalThink(1.0) end
end

function modifier_outpost_defense:OnIntervalThink()
	local ability = self:GetAbility()
	local attacker = self:GetParent()
	local team = attacker:GetTeam()

	if team == DOTA_TEAM_CUSTOM_3 then return end

	local attack_projectile = {
		Ability 			= ability,
		Target 				= attacker,
		Source 				= nil,
		iSourceAttachment	= DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		EffectName 			= "particles/base_attacks/ranged_tower_good.vpcf",
		iMoveSpeed			= 1400,
		vSourceLoc 			= attacker:GetAbsOrigin() + Vector(0, 0, 250),
		bDrawsOnMinimap 	= false,
		bDodgeable 			= true,
		bIsAttack 			= true,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		flExpireTime 		= GameRules:GetGameTime() + 10,
		bProvidesVision 	= false
	}

	local enemies = FindUnitsInRadius(
		team,
		attacker:GetAbsOrigin(),
		nil,
		825,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
		FIND_ANY_ORDER,
		false
	)

	for _, enemy in pairs(enemies) do
		if enemy:GetTeam() ~= DOTA_TEAM_CUSTOM_3 then
			attack_projectile.Target = enemy
			ProjectileManager:CreateTrackingProjectile(attack_projectile)
		end
	end
end



modifier_outpost_guardian_thinker = class({})

function modifier_outpost_guardian_thinker:IsHidden() return true end
function modifier_outpost_guardian_thinker:IsDebuff() return false end
function modifier_outpost_guardian_thinker:IsPurgable() return false end

function modifier_outpost_guardian_thinker:OnCreated(keys)
	if IsClient() then return end

	if keys.x and keys.y then
		self.origin = GetGroundPosition(Vector(keys.x, keys.y, 0), nil)

		self:StartIntervalThink(1.0)
	end
end

function modifier_outpost_guardian_thinker:OnIntervalThink()
	local parent = self:GetParent()

	if (not parent) or parent:IsNull() or (not parent:IsAlive()) then return end
	
	local location = parent:GetAbsOrigin()

	if (location - self.origin):Length2D() > 1200 then
		parent:Heal(99999, nil)

		ExecuteOrderFromTable({
			UnitIndex = parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = self.origin,
			Queue = false,
		})
	elseif (location - self.origin):Length2D() < 200 then
		ExecuteOrderFromTable({
			UnitIndex = parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = location,
			Queue = false,
		})
	end
end