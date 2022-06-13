_G.ScoreManager = ScoreManager or {}

function ScoreManager:Init()
	self.game_score = {}
	self.game_score[DOTA_TEAM_GOODGUYS] = 0
	self.game_score[DOTA_TEAM_BADGUYS] = 0

	self:UpdateScores()
end

function ScoreManager:Score(team)
	self.game_score[team] = self.game_score[team] + 1

	self:UpdateScores()

	GameManager:ConsumeEonStone()

	if self.game_score[team] >= 10 then
		GameRules:SetGameWinner(team)
	end
end

function ScoreManager:UpdateScores()
	CustomNetTables:SetTableValue("score", "scoreboard", self.game_score)
end

function ScoreManager:OnGameTimeOver()
	if self.game_score[DOTA_TEAM_GOODGUYS] >= self.game_score[DOTA_TEAM_BADGUYS] then
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	else
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
	end
end