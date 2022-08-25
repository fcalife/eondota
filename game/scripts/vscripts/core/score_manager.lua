_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.nexus = {}

	self.eon_points = {}
	self.eon_points[DOTA_TEAM_GOODGUYS] = 100
	self.eon_points[DOTA_TEAM_BADGUYS] = 100

	self:UpdateScores()
end

function ScoreManager:OnNexusHealth(team, health)
	if health < self.eon_points[team] then
		self.eon_points[team] = health
		self:UpdateScores()
	end
end

function ScoreManager:Score(team, points)
	--self.eon_points[team] = math.min(self.eon_points[team] + points, GAME_TARGET_SCORE)
	if self.nexus[team] and self.nexus[ENEMY_TEAM[team]] then
		local damage = self.nexus[ENEMY_TEAM[team]]:GetMaxHealth() * EON_STONE_NEXUS_DAMAGE
		ApplyDamage({attacker = self.nexus[team], victim = self.nexus[ENEMY_TEAM[team]], damage = damage, damage_type = DAMAGE_TYPE_PURE})

		self.eon_points[ENEMY_TEAM[team]] = math.ceil(100 * self.nexus[ENEMY_TEAM[team]]:GetHealth() / self.nexus[ENEMY_TEAM[team]]:GetMaxHealth())
		self:UpdateScores()
	end

	GlobalMessages:NotifyTeamScored(team)

	PassiveGold:GiveGoldToPlayersInTeam(team, EON_STONE_GOLD_REWARD, 0)

	Timers:CreateTimer(math.max(0, EON_STONE_RESPAWN_TIME - EON_STONE_COUNTDOWN_TIME), function()
		GameManager:StartEonStoneCountdown()
	end)
end

function ScoreManager:UpdateScores()
	local game_mode_entity = GameRules:GetGameModeEntity()

	game_mode_entity:SetCustomRadiantScore(self.eon_points[DOTA_TEAM_GOODGUYS])
	game_mode_entity:SetCustomDireScore(self.eon_points[DOTA_TEAM_BADGUYS])

	--self:CheckForPointWin()
end

function ScoreManager:CheckForPointWin()
	if self:GetTotalScore(DOTA_TEAM_GOODGUYS) >= GAME_TARGET_SCORE then
		GameManager:EndGameWithWinner(DOTA_TEAM_GOODGUYS)
	end
	if self:GetTotalScore(DOTA_TEAM_BADGUYS) >= GAME_TARGET_SCORE then
		GameManager:EndGameWithWinner(DOTA_TEAM_BADGUYS)
	end
end

function ScoreManager:GetHandicap(team)
	return math.max(0, self:GetTotalScore(ENEMY_TEAM[team]) - self:GetTotalScore(team))
end