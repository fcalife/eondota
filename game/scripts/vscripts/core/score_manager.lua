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

	CustomNetTables:SetTableValue("charge", "BLUE", {score = self.score[DOTA_TEAM_GOODGUYS]})
	CustomNetTables:SetTableValue("charge", "RED", {score = self.score[DOTA_TEAM_BADGUYS]})
	CustomNetTables:SetTableValue("charge", "GREEN", {score = self.score[DOTA_TEAM_CUSTOM_1]})
	CustomNetTables:SetTableValue("charge", "PINK", {score = self.score[DOTA_TEAM_CUSTOM_2]})
end

function ScoreManager:OnBossKilled(team, boss_name)
	self.score[team] = self.score[team] + 1

	GlobalMessages:Send(TEAM_NAME[team].." has killed "..LOCALIZED_BOSS_NAMES[boss_name].."!")

	CustomNetTables:SetTableValue("charge", TEAM_NAME[team], {score = self.score[team]})

	if self.score[team] >= 3 then GameRules:SetGameWinner(team) end

	EmitGlobalSound("radiant.round")
end