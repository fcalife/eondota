_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	self.next_eon_stone_spawn = self.game_start_time + EON_STONE_SPAWN_TIME

	GameManager:SetGamePhase(GAME_STATE_BATTLE)

	Timers:CreateTimer(1, function()
		self:Tick()
	end)
end

function GameClock:Tick()
	PassiveGold:Tick()

	if GameRules:GetGameTime() - self.game_start_time >= GAME_MAX_DURATION then
		ScoreManager:OnGameTimeOver()
	end

	if GameRules:GetGameTime() >= self.next_eon_stone_spawn then
		GameManager:StartEonStoneCountdown()
		self.next_eon_stone_spawn = self.next_eon_stone_spawn + EON_STONE_SPAWN_TIME
	end

	if GameManager:GetGamePhase() < GAME_STATE_END then
		Timers:CreateTimer(1, function()
			GameClock:Tick()
		end)
	end
end