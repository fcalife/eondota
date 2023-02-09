_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	GameRules:GetGameModeEntity():SetFogOfWarDisabled(FOG_OF_WAR_DISABLED)

	ScoreManager:InitializeLives()

	GameManager:SetGamePhase(GAME_STATE_BATTLE)

	Flags:SpawnObjectives()

	RoundManager:InitializeRound()

	self:Tick()
end

function GameClock:Tick()
	GoldRewards:Tick()

	if GameManager:GetGamePhase() < GAME_STATE_END then
		Timers:CreateTimer(1, function()
			GameClock:Tick()
		end)
	end
end

function GameClock:GetActualGameTime()
	return (self.game_start_time and (GameRules:GetGameTime() - self.game_start_time)) or 0
end