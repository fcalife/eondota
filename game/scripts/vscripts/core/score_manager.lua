_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

POINTS_TO_WIN = 350

DUCK_VALUE = {}
DUCK_VALUE["npc_duck_minion"] = 1
DUCK_VALUE["npc_duck_speed"] = 1
DUCK_VALUE["npc_duck_tough"] = 2
DUCK_VALUE["npc_duck_nestling"] = 1
DUCK_VALUE["npc_duck_nested"] = 5
DUCK_VALUE["npc_duck_boss"] = 5

function ScoreManager:Init()
	self.score = {}
	self.score[DOTA_TEAM_GOODGUYS] = 100
	self.score[DOTA_TEAM_BADGUYS] = 100

	self:UpdateScores()
end

function ScoreManager:OnDuckReachTarget(duck)
	local team = ENEMY_TEAM[duck:GetTeam()]
	local duck_name = duck:GetUnitName()

	self.score[team] = self.score[team] - DUCK_VALUE[duck_name]

	self:UpdateScores()

	self:CheckForPointWin()
end

function ScoreManager:UpdateScores()
	local game_mode_entity = GameRules:GetGameModeEntity()

	game_mode_entity:SetCustomRadiantScore(self.score[DOTA_TEAM_GOODGUYS])
	game_mode_entity:SetCustomDireScore(self.score[DOTA_TEAM_BADGUYS])
end

function ScoreManager:Score(team, points)
	self.score[team] = math.min(self.score[team] + points, POINTS_TO_WIN)

	self:UpdateScores()

	self:CheckForPointWin()
end

function ScoreManager:CheckForPointWin()
	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		if self:GetTotalScore(team) <= 0 then
			GameManager:EndGameWithWinner(ENEMY_TEAM[team])
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