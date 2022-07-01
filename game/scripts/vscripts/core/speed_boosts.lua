_G.SpeedBoosts = SpeedBoosts or {}

function SpeedBoosts:Init()
	for _, speed_boost in pairs(Entities:FindAllByName("speed_boost")) do
		self:SpawnSpeedBoost(speed_boost:GetAbsOrigin())
	end
end

function SpeedBoosts:SpawnSpeedBoost(position)
	MapTrigger(position, TRIGGER_TYPE_CIRCLE, {
		radius = 225
	}, {
		trigger_team = DOTA_TEAM_NEUTRALS,
		team_filter = DOTA_UNIT_TARGET_TEAM_BOTH,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	}, function(units)
		for _, unit in pairs(units) do
			unit:AddNewModifier(unit, nil, "modifier_speed_bonus", {duration = 6})
		end
	end)
end