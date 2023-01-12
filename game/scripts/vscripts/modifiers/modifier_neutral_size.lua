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
		if keys.unit:HasModifier("modifier_boss_alert_cooldown") then return end

		local location = keys.unit:GetAbsOrigin()

		local alerts = 3

		GlobalMessages:NotifyBossUnderAttack(keys.unit)

		Timers:CreateTimer(0, function()
			MinimapEvent(DOTA_TEAM_GOODGUYS, keys.unit, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 10)
			MinimapEvent(DOTA_TEAM_BADGUYS, keys.unit, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 10)
			MinimapEvent(DOTA_TEAM_CUSTOM_1, keys.unit, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 10)
			MinimapEvent(DOTA_TEAM_CUSTOM_2, keys.unit, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 10)

			alerts = alerts - 1

			if alerts > 0 then return 3 end
		end)

		keys.unit:AddNewModifier(keys.unit, nil, "modifier_boss_alert_cooldown", {duration = 30})
	end
end



modifier_boss_alert_cooldown = class({})

function modifier_boss_alert_cooldown:IsHidden() return true end
function modifier_boss_alert_cooldown:IsDebuff() return false end
function modifier_boss_alert_cooldown:IsPurgable() return false end