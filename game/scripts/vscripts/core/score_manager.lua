_G.ScoreManager = ScoreManager or {}

function ScoreManager:Init()
	self.game_score = {}
	self.game_score[DOTA_TEAM_GOODGUYS] = 0
	self.game_score[DOTA_TEAM_BADGUYS] = 0

	self:UpdateScores()
end

function ScoreManager:Score(team)
	self.game_score[team] = self.game_score[team] + 1

	self:UpdateScores(team)

	self:PlayTeamScoreSound(team)

	GameManager:ConsumeEonStone()

	if self.game_score[team] >= 10 then
		GameManager:EndGameWithWinner(team)
	end
end

function ScoreManager:UpdateScores(team)
	CustomNetTables:SetTableValue("score", "scoreboard", self.game_score)
	if team then CustomGameEventManager:Send_ServerToAllClients("point_scored", {team = team}) end
end

function ScoreManager:OnGameTimeOver()
	if self.game_score[DOTA_TEAM_GOODGUYS] > self.game_score[DOTA_TEAM_BADGUYS] then
		GameManager:EndGameWithWinner(DOTA_TEAM_GOODGUYS)
	elseif self.game_score[DOTA_TEAM_BADGUYS] > self.game_score[DOTA_TEAM_GOODGUYS] then
		GameManager:EndGameWithWinner(DOTA_TEAM_BADGUYS)
	end
end

function ScoreManager:PlayTeamScoreSound(team)
	local sound_name = (team == DOTA_TEAM_GOODGUYS) and "radiant.score" or "dire.score"

	EmitGlobalSound(sound_name)
end