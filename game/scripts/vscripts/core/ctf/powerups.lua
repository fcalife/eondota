_G.Powerups = Powerups or {}

MIN_POWERUP_TIME = 10
MAX_POWERUP_TIME = 25

function Powerups:StartSpawning()
	Timers:CreateTimer(RandomInt(MIN_POWERUP_TIME, MAX_POWERUP_TIME), function()
		self:SpawnPowerup(DOTA_TEAM_GOODGUYS)

		return RandomInt(MIN_POWERUP_TIME, MAX_POWERUP_TIME)
	end)

	Timers:CreateTimer(RandomInt(MIN_POWERUP_TIME, MAX_POWERUP_TIME), function()
		self:SpawnPowerup(DOTA_TEAM_BADGUYS)

		return RandomInt(MIN_POWERUP_TIME, MAX_POWERUP_TIME)
	end)
end

function Powerups:SpawnPowerup(team)
	local powerups = {
		"npc_powerup_cooldown",
		"npc_powerup_triple",
		"npc_powerup_double",
	}

	local powerup_name = powerups[RandomInt(1, 3)]

	local position = Vector(RandomInt(MAP_CENTER, MAP_EDGE), RandomInt(-200, 800), 0)

	if team == DOTA_TEAM_GOODGUYS then position.x = (-1) * position.x end

	local powerup = CreateUnitByName(powerup_name, position, true, nil, nil, ENEMY_TEAM[team])
	powerup:AddNewModifier(powerup, nil, "modifier_"..powerup_name, {})
end