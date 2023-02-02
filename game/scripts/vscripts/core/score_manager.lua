_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.score = {}
	self.score[DOTA_TEAM_GOODGUYS] = 0
	self.score[DOTA_TEAM_BADGUYS] = 0
	self.score[DOTA_TEAM_CUSTOM_1] = 0
	self.score[DOTA_TEAM_CUSTOM_2] = 0
	self.score[DOTA_TEAM_CUSTOM_3] = 0
	self.score[DOTA_TEAM_CUSTOM_4] = 0
	self.score[DOTA_TEAM_CUSTOM_5] = 0
	self.score[DOTA_TEAM_CUSTOM_6] = 0
	self.score[DOTA_TEAM_CUSTOM_7] = 0
	self.score[DOTA_TEAM_CUSTOM_8] = 0

	CustomNetTables:SetTableValue("score", "scoreboard", self.score)

	self:UpdateScores()
end

function ScoreManager:UpdateScores()
	CustomNetTables:SetTableValue("score", "scoreboard", self.score)
end

function ScoreManager:CheckForPointWin()
	if self:GetTotalScore(DOTA_TEAM_GOODGUYS) >= ROUNDS_TO_WIN then
		GameManager:EndGameWithWinner(DOTA_TEAM_GOODGUYS)
	end
	if self:GetTotalScore(DOTA_TEAM_BADGUYS) >= ROUNDS_TO_WIN then
		GameManager:EndGameWithWinner(DOTA_TEAM_BADGUYS)
	end

	for team = DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_8 do
		if self:GetTotalScore(team) >= ROUNDS_TO_WIN then
			GameManager:EndGameWithWinner(team)
		end
	end
end

function ScoreManager:OnTeamWinRound(team)
	self.score[team] = self.score[team] + 1 

	self:UpdateScores()

	GlobalMessages:NotifyTeamWonRound(team)

	GoldRewards:GiveGoldToPlayersInTeam(team, ROUND_WIN_GOLD, 0)

	self:CheckForPointWin()
end

function ScoreManager:GetTotalScore(team)
	return (self.score and self.score[team] or 0)
end

function ScoreManager:Laser(start_position, end_position)
	local laser_pfx = ParticleManager:CreateParticle("particles/econ/items/tinker/tinker_ti10_immortal_laser/tinker_ti10_immortal_laser.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(laser_pfx, 9, start_position + Vector(0, 0, 150))
	ParticleManager:SetParticleControl(laser_pfx, 1, end_position + Vector(0, 0, 150))
	ParticleManager:ReleaseParticleIndex(laser_pfx)
end