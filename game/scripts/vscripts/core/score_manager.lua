_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

TEAM_NAME = {}
TEAM_NAME[DOTA_TEAM_GOODGUYS] = "BLUE"
TEAM_NAME[DOTA_TEAM_BADGUYS] = "RED"
TEAM_NAME[DOTA_TEAM_CUSTOM_1] = "GREEN"
TEAM_NAME[DOTA_TEAM_CUSTOM_2] = "PINK"

function ScoreManager:Init()
	self.score = {}
	self.score[DOTA_TEAM_GOODGUYS] = 0
	self.score[DOTA_TEAM_BADGUYS] = 0
	self.score[DOTA_TEAM_CUSTOM_1] = 0
	self.score[DOTA_TEAM_CUSTOM_2] = 0
end

function ScoreManager:Score(team)
	self.score[team] = self.score[team] + 1
	GlobalMessages:Send(TEAM_NAME[team].." now has "..self.score[team].." out of 3 points!")

	if self.score[team] >= 3 then GameRules:SetGameWinner(team) end

	EmitGlobalSound("dire.round")
end