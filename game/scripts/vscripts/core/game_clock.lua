_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	self:Tick()
end

function GameClock:Tick()
	if GameRules:GetGameTime() - self.game_start_time >= GAME_MAX_DURATION then
		ScoreManager:OnGameTimeOver()
	else
		Timers:CreateTimer(1, function()
			GameClock:Tick()
		end)
	end
end