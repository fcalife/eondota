modifier_nexus_state = class({})

function modifier_nexus_state:IsHidden() return true end
function modifier_nexus_state:IsDebuff() return false end
function modifier_nexus_state:IsPurgable() return false end

function modifier_nexus_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end

function modifier_nexus_state:DeclareFunctions()
	if IsServer() then
		return {
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
	return ACT_DOTA_CAPTURE
end

function modifier_nexus_state:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		GameManager:EndGameWithWinner(ENEMY_TEAM[keys.unit:GetTeam()])
	end
end



modifier_living_nexus_state = class({})

function modifier_living_nexus_state:IsHidden() return true end
function modifier_living_nexus_state:IsDebuff() return false end
function modifier_living_nexus_state:IsPurgable() return false end

function modifier_living_nexus_state:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end

function modifier_living_nexus_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_DEATH,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
		}
	else
		return {
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
		}
	end
end

function modifier_living_nexus_state:GetModifierProvidesFOWVision()
	return 1
end

function modifier_living_nexus_state:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		GameManager:EndGameWithWinner(ENEMY_TEAM[keys.unit:GetTeam()])
	end
end