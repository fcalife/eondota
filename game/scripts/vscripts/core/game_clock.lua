_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	self.next_eon_stone_spawn = self.game_start_time + EON_STONE_FIRST_SPAWN_TIME
	self.next_bounty_rune_spawn = self.game_start_time

	GameManager:SetGamePhase(GAME_STATE_BATTLE)

	self:Tick()
end

function GameClock:Tick()
	PassiveGold:Tick()

	if GameRules:GetGameTime() - self.game_start_time >= GAME_MAX_DURATION then
		ScoreManager:OnGameTimeOver()
	end

	if GameRules:GetGameTime() >= (self.next_eon_stone_spawn - EON_STONE_COUNTDOWN_TIME) then
		GameManager:StartEonStoneCountdown()
		self.next_eon_stone_spawn = self.next_eon_stone_spawn + EON_STONE_RESPAWN_TIME
	end

	if GameRules:GetGameTime() >= self.next_bounty_rune_spawn then
		RuneSpawner:SpawnBountyRunes()
		self.next_bounty_rune_spawn = self.next_bounty_rune_spawn + BOUNTY_RUNE_SPAWN_INTERVAL
	end

	if GameManager:GetGamePhase() < GAME_STATE_END_TIMER and GameRules:GetGameTime() - self.game_start_time >= (GAME_MAX_DURATION - GAME_END_WARNING_TIME) then
		GameManager:StartGameEndCountdown()
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