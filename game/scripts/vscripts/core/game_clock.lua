_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	self.next_eon_stone_spawn = self.game_start_time + EON_STONE_FIRST_SPAWN_TIME

	GameManager:SetGamePhase(GAME_STATE_BATTLE)

	NeutralCamps:StartSpawning()

	RuneSpawner:SpawnAllBountyRunes()

	self:Tick()
end

function GameClock:Tick()
	PassiveGold:Tick()

	if GameRules:GetGameTime() >= (self.next_eon_stone_spawn - EON_STONE_COUNTDOWN_TIME) then
		GameManager:StartEonStoneCountdown()
		self.next_eon_stone_spawn = self.next_eon_stone_spawn + EON_STONE_RESPAWN_TIME
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