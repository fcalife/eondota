modifier_treasure_state = class({})

function modifier_treasure_state:IsHidden() return true end
function modifier_treasure_state:IsDebuff() return false end
function modifier_treasure_state:IsPurgable() return false end

function modifier_treasure_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_treasure_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
	else
		return {
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
	end
end

function modifier_treasure_state:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_treasure_state:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_treasure_state:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_treasure_state:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

function modifier_treasure_state:OnAttackLanded(keys)
	if keys.target and keys.target == self:GetParent() then
		local team = keys.target:GetTeam()

		if keys.attacker and keys.attacker:GetTeam() ~= team then
			for id = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
				if PlayerResource:IsValidPlayer(id) and PlayerResource:GetTeam(id) ~= team then
					PlayerResource:ModifyGold(id, TREASURE_GOLD_PER_HIT, false, DOTA_ModifyGold_GameTick)
				end
			end
		end
	end
end