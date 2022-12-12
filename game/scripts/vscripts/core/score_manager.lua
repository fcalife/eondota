_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.score = {}
	self.score[DOTA_TEAM_GOODGUYS] = 0
	self.score[DOTA_TEAM_BADGUYS] = 0

	self:UpdateEssenceScoreboard()
end

function ScoreManager:UpdateEssenceScoreboard()
	local max = math.max(1, self.score[DOTA_TEAM_GOODGUYS], self.score[DOTA_TEAM_BADGUYS])

	CustomNetTables:SetTableValue("charge", "radiant", {current = self.score[DOTA_TEAM_GOODGUYS], max = max})
	CustomNetTables:SetTableValue("charge", "dire", {current = self.score[DOTA_TEAM_BADGUYS], max = max})
end

function ScoreManager:AddEssence(team, amount)
	self.score[team] = self.score[team] + amount

	self:UpdateEssenceScoreboard()
end

function ScoreManager:EvaluateWinner()
	if self.score[DOTA_TEAM_GOODGUYS] > self.score[DOTA_TEAM_BADGUYS] then
		Firelord:SummonNeutralsFor(DOTA_TEAM_GOODGUYS)

		self.score[DOTA_TEAM_GOODGUYS] = 0
		self.score[DOTA_TEAM_BADGUYS] = 0

		self:UpdateEssenceScoreboard()

		GameClock.next_archer_evaluation = GameRules:GetGameTime() + COIN_EVALUATION_TIME
		GameClock.archer_warning_60 = true
		GameClock.archer_warning_30 = true
		GameClock.archer_warning_10 = true
		GameClock.archer_warning_3 = true
		GameClock.archer_warning_2 = true
		GameClock.archer_warning_1 = true
		GameClock.archer_evaluating = true

	elseif self.score[DOTA_TEAM_GOODGUYS] < self.score[DOTA_TEAM_BADGUYS] then
		Firelord:SummonNeutralsFor(DOTA_TEAM_BADGUYS)

		self.score[DOTA_TEAM_GOODGUYS] = 0
		self.score[DOTA_TEAM_BADGUYS] = 0

		self:UpdateEssenceScoreboard()

		GameClock.next_archer_evaluation = GameRules:GetGameTime() + COIN_EVALUATION_TIME
		GameClock.archer_warning_60 = true
		GameClock.archer_warning_30 = true
		GameClock.archer_warning_10 = true
		GameClock.archer_warning_3 = true
		GameClock.archer_warning_2 = true
		GameClock.archer_warning_1 = true
		GameClock.archer_evaluating = true

	else
		Timers:CreateTimer(1.0, function() ScoreManager:EvaluateWinner() end)
	end
end