_G.Ducks = Ducks or {}

DUCK_HEIGHT = {}
DUCK_HEIGHT[1] = -100
DUCK_HEIGHT[2] = 200
DUCK_HEIGHT[3] = 500
DUCK_HEIGHT[4] = 800

BASE_DUCKS_PER_LEVEL = 20
DUCKS_PER_LEVEL_PER_LEVEL = 5

GRACE_PERIOD_DUCKS = 5

BASE_DUCK_INTERVAL = 1.5
DUCK_INTERVAL_FACTOR = 0.8
MIN_DUCK_INTERVAL = 0.3

MAP_EDGE = 1400
MAP_CENTER = 50

function Ducks:StartSpawning()
	self.next_duck = GameRules:GetGameTime()
	self.current_interval = BASE_DUCK_INTERVAL
	self.duck_count = 0
	self.current_level = 1
	self.grace_period = false
end

function Ducks:Tick()
	local current_time = GameRules:GetGameTime()

	while self.next_duck < current_time do
		self:RandomizeDuck()
	end
end

function Ducks:RandomizeDuck()
	local tier = RandomInt(1, 2)

	if RollPercentage(20) then tier = 3 end
	if RollPercentage(8) then tier = 4 end

	local bonus_speed = 25 * (self.current_level - 1)

	local duck_type = RandomInt(1, 100) + (self.grace_period and (2 * self.current_level) or 0)

	duck_type = duck_type - 45

	if duck_type <= 0 then
		duck_type = "minion"
	else
		duck_type = duck_type - 25

		if duck_type <= 0 then
			duck_type = "speed"
		else
			duck_type = duck_type - 20

			if duck_type <= 0 then
				duck_type = "tough"
			else
				duck_type = duck_type - 8

				if duck_type <= 0 then
					duck_type = "nested"
				else
					duck_type = "boss"
				end
			end
		end
	end

	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		self:SpawnDuck(team, DUCK_HEIGHT[tier], bonus_speed, duck_type)
	end

	self.duck_count = self.duck_count + 1

	if self.duck_count >= (BASE_DUCKS_PER_LEVEL + DUCKS_PER_LEVEL_PER_LEVEL * (self.current_level - 1)) then
		self.grace_period = true
		self.duck_count = 0
		self.current_interval = math.max(self.current_interval * DUCK_INTERVAL_FACTOR, MIN_DUCK_INTERVAL)
	end

	if self.grace_period then
		if self.duck_count >= GRACE_PERIOD_DUCKS then
			self.grace_period = false
			self.duck_count = 0
			self.current_level = self.current_level + 1
		end

		self.next_duck = self.next_duck + BASE_DUCK_INTERVAL
	else
		self.next_duck = self.next_duck + self.current_interval
	end
end

function Ducks:SpawnDuck(team, y, bonus_speed, duck_type)
	local spawn = Vector(MAP_EDGE, y, 0)

	if team == DOTA_TEAM_GOODGUYS then spawn = Vector((-1) * MAP_EDGE, y, 0) end

	local duck = CreateUnitByName("npc_duck_"..duck_type, spawn, true, nil, nil, ENEMY_TEAM[team])
	duck:AddNewModifier(duck, nil, "modifier_duck", {speed = bonus_speed})
end