modifier_neutral_size = class({})

function modifier_neutral_size:IsHidden() return true end
function modifier_neutral_size:IsDebuff() return false end
function modifier_neutral_size:IsPurgable() return false end

function modifier_neutral_size:OnCreated(keys)
	if IsClient() then return end

	--if keys.scale then self:SetStackCount(keys.scale) end
end

function modifier_neutral_size:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE
		}
	end
end

function modifier_neutral_size:OnTakeDamage(keys)
	if keys.unit and keys.unit == self:GetParent() then
		local location = keys.unit:GetAbsOrigin()

		MinimapEvent(DOTA_TEAM_GOODGUYS, keys.unit, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 10)
		MinimapEvent(DOTA_TEAM_BADGUYS, keys.unit, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 10)
		MinimapEvent(DOTA_TEAM_CUSTOM_1, keys.unit, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 10)
		MinimapEvent(DOTA_TEAM_CUSTOM_2, keys.unit, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 10)

		keys.unit:RemoveModifierByName("modifier_neutral_size")
	end
end