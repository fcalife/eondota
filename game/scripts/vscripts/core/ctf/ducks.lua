_G.Ducks = Ducks or {}

DUCK_HEIGHT = {}
DUCK_HEIGHT[1] = -100
DUCK_HEIGHT[2] = 200
DUCK_HEIGHT[3] = 500
DUCK_HEIGHT[4] = 800

BASE_DUCK_SPEED = 200
DUCK_SPEED_INC = 2
MAX_DUCK_SPEED = 750

BASE_DUCK_INTERVAL = 1.5
DUCK_INTERVAL_FACTOR = 0.96
MIN_DUCK_INTERVAL = 0.24

MIDDLE_DUCK = 50
EDGE_DUCK = 1400

function Ducks:StartSpawning()
	self.next_duck = GameRules:GetGameTime()
	self.current_interval = BASE_DUCK_INTERVAL
	self.duck_count = 0
end

function Ducks:Tick()
	local current_time = GameRules:GetGameTime()

	while self.next_duck < current_time do
		self:RandomizeDuck()
	end
end

function Ducks:RandomizeDuck()
	local tier = RandomInt(1, 2)
	local big = false

	if RollPercentage(20) then tier = 3 end
	if RollPercentage(8) then tier = 4 end

	local speed = (BASE_DUCK_SPEED + self.duck_count * DUCK_SPEED_INC) * (RandomFloat(0.8, 1.4) + 0.2 * tier)
	speed = math.min(speed, MAX_DUCK_SPEED)

	local points = 1 + tier + math.floor(0.01 * (speed - 200))
	local spawn = (RollPercentage(50) and MIDDLE_DUCK) or EDGE_DUCK

	if RollPercentage(2) then
		big = true
		speed = 200
		points = 40
	end

	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		self:SpawnDuck(team, spawn, DUCK_HEIGHT[tier], speed, points, big)
	end

	self.duck_count = self.duck_count + 1
	self.current_interval = math.max(self.current_interval * DUCK_INTERVAL_FACTOR, MIN_DUCK_INTERVAL)
	self.next_duck = self.next_duck + self.current_interval
end

function Ducks:SpawnDuck(team, x, y, speed, points, big)
	local spawn = Vector(x, y, 0)

	if team == DOTA_TEAM_GOODGUYS then spawn = Vector((-1) * x, y, 0) end

	local duck = CreateUnitByName((big and "npc_big_duck") or "npc_duck", spawn, true, nil, nil, ENEMY_TEAM[team])
	duck:AddNewModifier(duck, nil, "modifier_duck", {speed = speed, points = points})
end


function Ducks:OnDuckDied(killer, duck, points)
	local team = killer:GetTeam()

	ScoreManager:Score(killer:GetTeam(), points)

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:GetTeam() == team then
			local player = hero:GetPlayerOwner()
			if player then SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, duck, points, player) end
		end
	end
end