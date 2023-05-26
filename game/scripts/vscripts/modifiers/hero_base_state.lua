modifier_hero_base_state = class({})

function modifier_hero_base_state:IsHidden() return true end
function modifier_hero_base_state:IsDebuff() return false end
function modifier_hero_base_state:IsPurgable() return false end
function modifier_hero_base_state:RemoveOnDeath() return false end
function modifier_hero_base_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_base_state:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	self:SetStackCount(1600)

	parent:CalculateStatBonus(true)
end

-- function modifier_hero_base_state:CheckState()
-- 	return { [MODIFIER_STATE_DISARMED] = true }
-- end

function modifier_hero_base_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MIN_HEALTH,
			MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
	else
		return {
			MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MIN_HEALTH,
			MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
		}
	end
end

function modifier_hero_base_state:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_hero_base_state:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_hero_base_state:GetMinHealth()
	return 1
end

function modifier_hero_base_state:GetModifierExtraHealthPercentage()
	return 100 * math.max(0, self:GetStackCount() - 1)
end

function modifier_hero_base_state:OnTakeDamage(keys)
	if keys.unit and keys.unit == self:GetParent() then
		if keys.unit:GetHealth() < 2 then
			keys.unit:AddNewModifier(keys.unit, nil, "modifier_boss_crawling", {})

			keys.unit:EmitSound("Tombstone.Spawn")

			-- Timers:CreateTimer(5, function()
			-- 	local new_item = CreateItem("item_eon_tombstone", keys.unit, keys.unit)
			-- 	new_item:SetPurchaseTime(0)
			-- 	new_item:SetPurchaser(keys.unit)

			-- 	local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
			-- 	tombstone:SetContainedItem(new_item)
			-- 	tombstone:SetAngles(0, RandomFloat(0, 360), 0)
			-- 	FindClearSpaceForUnit(tombstone, keys.unit:GetAbsOrigin(), true)

			-- 	local tombstone_loc = tombstone:GetAbsOrigin()
			-- 	tombstone_loc = Vector(tombstone_loc.x, tombstone_loc.y, GetGroundHeight(tombstone_loc, nil))

			-- 	local spawn_pfx = ParticleManager:CreateParticle("particles/boss/tombstone_spawn.vpcf", PATTACH_CUSTOMORIGIN, nil)
			-- 	ParticleManager:SetParticleControl(spawn_pfx, 0, tombstone_loc)
			-- 	ParticleManager:ReleaseParticleIndex(spawn_pfx)

			-- 	EmitSoundOnLocationForAllies(tombstone_loc, "Tombstone.Spawn", keys.unit)
			-- end)
		end
	end
end



modifier_fast_abilities = class({})

function modifier_fast_abilities:IsHidden() return true end
function modifier_fast_abilities:IsDebuff() return false end
function modifier_fast_abilities:IsPurgable() return false end
function modifier_fast_abilities:RemoveOnDeath() return false end
function modifier_fast_abilities:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_fast_abilities:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
end

function modifier_fast_abilities:GetModifierPercentageCooldown()
	return 25
end



modifier_faster_abilities = class({})

function modifier_faster_abilities:IsHidden() return true end
function modifier_faster_abilities:IsDebuff() return false end
function modifier_faster_abilities:IsPurgable() return false end
function modifier_faster_abilities:RemoveOnDeath() return false end
function modifier_faster_abilities:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_faster_abilities:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
end

function modifier_faster_abilities:GetModifierPercentageCooldown()
	return 50
end