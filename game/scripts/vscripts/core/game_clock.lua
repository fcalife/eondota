_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	self.eon_stone_spawn_time = self.game_start_time + EON_STONE_FIRST_SPAWN_TIME
	self.stone_spawned = false

	self.next_creep_spawn = self.game_start_time + LANE_CREEP_FIRST_SPAWN

	GameManager:SetGamePhase(GAME_STATE_BATTLE)

	NeutralCamps:StartSpawning()

	Portals:Spawn()

	--RuneSpawner:SpawnAllBountyRunes()

	if IS_LANE_MAP then TreasureChests:Spawn() end

	if IS_CART_MAP then Timers:CreateTimer(CART_INITIAL_SPAWN_DELAY - CART_COUNTDOWN_TIME, function() PushCarts:StartCountdown() end) end

	Timers:CreateTimer(SHRINE_INITIAL_SPAWN_DELAY, function() Shrines:Init() end)

	self:Tick()
end

function GameClock:Tick()
	PassiveGold:Tick()

	if GameRules:GetGameTime() >= (self.eon_stone_spawn_time - EON_STONE_COUNTDOWN_TIME) and (not self.stone_spawned) then
		GameManager:StartEonStoneCountdown()
		self.stone_spawned = true
	end

	if GameRules:GetGameTime() >= self.next_creep_spawn then
		self.next_creep_spawn = self.next_creep_spawn + LANE_CREEP_SPAWN_DELAY

		if IS_LANE_MAP then LaneCreeps:SpawnWave() end
	end

	if GameManager:GetGamePhase() < GAME_STATE_END then
		Timers:CreateTimer(1, function()
			GameClock:Tick()
		end)
	end
end

function GameClock:GetActualGameTime()
	return (self.game_start_time and (GameRules:GetGameTime() - self.game_start_time)) or 0
end