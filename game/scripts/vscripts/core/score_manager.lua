_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.eon_points = {}
	self.eon_points[DOTA_TEAM_GOODGUYS] = 0
	self.eon_points[DOTA_TEAM_BADGUYS] = 0

	self:UpdateScores()
end

function ScoreManager:GetTotalScore(team)
	return (self.eon_points and self.eon_points[team] or 0) + PlayerResource:GetTeamKills(team)
end

function ScoreManager:Score(team, points)
	self.eon_points[team] = math.min(self.eon_points[team] + points, GAME_TARGET_SCORE)

	GlobalMessages:NotifyTeamScored(team)

	self:UpdateScores()
end

function ScoreManager:UpdateScores()
	local game_mode_entity = GameRules:GetGameModeEntity()

	game_mode_entity:SetCustomRadiantScore(self:GetTotalScore(DOTA_TEAM_GOODGUYS))
	game_mode_entity:SetCustomDireScore(self:GetTotalScore(DOTA_TEAM_BADGUYS))

	self:CheckForPointWin()
end

function ScoreManager:CheckForPointWin()
	if self:GetTotalScore(DOTA_TEAM_GOODGUYS) >= GAME_TARGET_SCORE then
		GameManager:EndGameWithWinner(DOTA_TEAM_GOODGUYS)
	end
	if self:GetTotalScore(DOTA_TEAM_BADGUYS) >= GAME_TARGET_SCORE then
		GameManager:EndGameWithWinner(DOTA_TEAM_BADGUYS)
	end
end

function ScoreManager:OnGameTimeOver()
	self:CheckForPointWin()

	if self:GetTotalScore(DOTA_TEAM_GOODGUYS) > self:GetTotalScore(DOTA_TEAM_BADGUYS) then
		GameManager:EndGameWithWinner(DOTA_TEAM_GOODGUYS)
	elseif self:GetTotalScore(DOTA_TEAM_BADGUYS) > self:GetTotalScore(DOTA_TEAM_GOODGUYS) then
		GameManager:EndGameWithWinner(DOTA_TEAM_BADGUYS)
	end
end

function ScoreManager:GetHandicap(team)
	return math.max(0, self:GetTotalScore(ENEMY_TEAM[team]) - self:GetTotalScore(team))
end