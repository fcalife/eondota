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
	CustomNetTables:SetTableValue("coins", "radiant", {coins = self.score[DOTA_TEAM_GOODGUYS]})
	CustomNetTables:SetTableValue("coins", "dire", {coins = self.score[DOTA_TEAM_BADGUYS]})
end

function ScoreManager:AddEssence(hero, amount)
	local team = hero:GetTeam()

	self.score[team] = self.score[team] + amount

	self:UpdateEssenceScoreboard()
end

function ScoreManager:EvaluateWinner()
	if self.score[DOTA_TEAM_GOODGUYS] > self.score[DOTA_TEAM_BADGUYS] then
		Buildables:BuildForTeam(DOTA_TEAM_GOODGUYS)

		self.score[DOTA_TEAM_GOODGUYS] = 0
		self.score[DOTA_TEAM_BADGUYS] = 0

		self:UpdateEssenceScoreboard()

		GameClock.next_archer_evaluation = GameRules:GetGameTime() + COIN_EVALUATION_TIME
		GameClock.archer_warning_60 = true
		GameClock.archer_warning_15 = true
		GameClock.archer_warning_3 = true
		GameClock.archer_warning_2 = true
		GameClock.archer_warning_1 = true
		GameClock.archer_evaluating = true

	elseif self.score[DOTA_TEAM_GOODGUYS] < self.score[DOTA_TEAM_BADGUYS] then
		Buildables:BuildForTeam(DOTA_TEAM_BADGUYS)

		self.score[DOTA_TEAM_GOODGUYS] = 0
		self.score[DOTA_TEAM_BADGUYS] = 0

		self:UpdateEssenceScoreboard()

		GameClock.next_archer_evaluation = GameRules:GetGameTime() + COIN_EVALUATION_TIME
		GameClock.archer_warning_60 = true
		GameClock.archer_warning_15 = true
		GameClock.archer_warning_3 = true
		GameClock.archer_warning_2 = true
		GameClock.archer_warning_1 = true
		GameClock.archer_evaluating = true

	else
		Timers:CreateTimer(1.0, function() ScoreManager:EvaluateWinner() end)
	end
end