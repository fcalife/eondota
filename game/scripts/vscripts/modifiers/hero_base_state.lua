modifier_hero_base_state = class({})

function modifier_hero_base_state:IsHidden() return true end
function modifier_hero_base_state:IsDebuff() return false end
function modifier_hero_base_state:IsPurgable() return false end
function modifier_hero_base_state:RemoveOnDeath() return false end
function modifier_hero_base_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_base_state:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	self:SetStackCount((NIGHTMARE_MODE and 600) or (HARD_MODE and 1000) or 1600)

	parent:CalculateStatBonus(true)

	self:StartIntervalThink(0.03)
end

function modifier_hero_base_state:OnIntervalThink()
	local parent = self:GetParent()
	local parent_loc = parent:GetAbsOrigin()
	local player = parent:GetPlayerOwner()

	if (not player) then return end

	local found_ally = false
	for _, ally in pairs(HeroList:GetAllHeroes()) do
		if (ally:HasModifier("modifier_boss_crawling") or parent:HasModifier("modifier_boss_crawling")) and parent ~= ally then
			found_ally = true

			local ally_loc = ally:GetAbsOrigin()
			local ally_distance = (ally_loc - parent_loc):Length2D()

			if ally_distance > 500 then
				local arrow_loc = parent_loc + math.min(1000, ally_distance - 225) * (ally_loc - parent_loc):Normalized()

				if self.ally_pfx then
					ParticleManager:SetParticleControl(self.ally_pfx, 1, parent_loc)
					ParticleManager:SetParticleControl(self.ally_pfx, 2, arrow_loc)
				else
					self.ally_pfx = ParticleManager:CreateParticleForPlayer("particles/boss/boss_arrow.vpcf", PATTACH_CUSTOMORIGIN, nil, player)
					ParticleManager:SetParticleControl(self.ally_pfx, 1, parent_loc)
					ParticleManager:SetParticleControl(self.ally_pfx, 2, arrow_loc)
					ParticleManager:SetParticleControl(self.ally_pfx, 3, Vector(86, 40, 0))
					ParticleManager:SetParticleControl(self.ally_pfx, 4, Vector(35, 255, 15))
					ParticleManager:SetParticleControl(self.ally_pfx, 6, Vector(1, 1, 1))
				end
			else
				if self.ally_pfx then
					ParticleManager:DestroyParticle(self.ally_pfx, true)
					ParticleManager:ReleaseParticleIndex(self.ally_pfx)
					self.ally_pfx = nil
				end
			end
		end
	end

	if (not found_ally) then
		if self.ally_pfx then
			ParticleManager:DestroyParticle(self.ally_pfx, true)
			ParticleManager:ReleaseParticleIndex(self.ally_pfx)
			self.ally_pfx = nil
		end
	end
end

-- function modifier_hero_base_state:CheckState()
-- 	return { [MODIFIER_STATE_DISARMED] = true }
-- end

function modifier_hero_base_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
			MODIFIER_EVENT_ON_ABILITY_END_CHANNEL
		}
	else
		return {
			MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
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

function modifier_hero_base_state:GetModifierExtraHealthPercentage()
	return 100 * math.max(0, self:GetStackCount() - 1)
end

function modifier_hero_base_state:OnAbilityEndChannel(keys)
	if keys.unit and keys.unit == self:GetParent() then
		if keys.ability and keys.ability:GetAbilityName() == "abyssal_underlord_portal_warp" then
			if keys.ability:GetChannelStartTime() <= (GameRules:GetGameTime() - keys.ability:GetChannelTime() + 0.01) then
				Portals:OnUnitUsedPortal(keys.unit)
			end
		end
	end
end



modifier_hero_revive_state = class({})

function modifier_hero_revive_state:IsHidden() return true end
function modifier_hero_revive_state:IsDebuff() return false end
function modifier_hero_revive_state:IsPurgable() return false end
function modifier_hero_revive_state:RemoveOnDeath() return false end
function modifier_hero_revive_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_revive_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_MIN_HEALTH,
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
	else
		return {
			MODIFIER_PROPERTY_MIN_HEALTH
		}
	end
end

function modifier_hero_revive_state:GetMinHealth()
	return 1
end

function modifier_hero_revive_state:OnTakeDamage(keys)
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