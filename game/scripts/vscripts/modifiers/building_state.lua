modifier_building_state = class({})

function modifier_building_state:IsHidden() return true end
function modifier_building_state:IsDebuff() return false end
function modifier_building_state:IsPurgable() return false end

function modifier_building_state:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}
end

function modifier_building_state:DeclareFunctions()
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

function modifier_building_state:GetModifierProvidesFOWVision()
	return 1
end

function modifier_building_state:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		if keys.unit.building_slot then keys.unit.building_slot:OnBuildingDestroyed() end
	end
end



modifier_neutral_building_state = class({})

function modifier_neutral_building_state:IsHidden() return true end
function modifier_neutral_building_state:IsDebuff() return false end
function modifier_neutral_building_state:IsPurgable() return false end


function modifier_neutral_building_state:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
end

function modifier_neutral_building_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	}
end

function modifier_neutral_building_state:GetModifierProvidesFOWVision()
	return 1
end

function modifier_neutral_building_state:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_neutral_building_state:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_neutral_building_state:GetAbsoluteNoDamagePure()
	return 1
end
