_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.score = {}
	self.score[DOTA_TEAM_GOODGUYS] = 0
	self.score[DOTA_TEAM_BADGUYS] = 0

	self.tower_charge = {}
	self.tower_charge[DOTA_TEAM_GOODGUYS] = 0
	self.tower_charge[DOTA_TEAM_BADGUYS] = 0

	self.tower_charge_target = {}
	self.tower_charge_target[DOTA_TEAM_GOODGUYS] = CHARGE_TOWER_BASE_CHARGE
	self.tower_charge_target[DOTA_TEAM_BADGUYS] = CHARGE_TOWER_BASE_CHARGE

	--self:UpdateScores()
	self:UpdateChargeScoreboard()
end

function ScoreManager:UpdateScores()
	local game_mode_entity = GameRules:GetGameModeEntity()

	game_mode_entity:SetCustomRadiantScore(self.score[DOTA_TEAM_GOODGUYS])
	game_mode_entity:SetCustomDireScore(self.score[DOTA_TEAM_BADGUYS])
end

function ScoreManager:CheckForPointWin()
	if self:GetTotalScore(DOTA_TEAM_GOODGUYS) >= ROUNDS_TO_WIN then
		GameManager:EndGameWithWinner(DOTA_TEAM_GOODGUYS)
	end
	if self:GetTotalScore(DOTA_TEAM_BADGUYS) >= ROUNDS_TO_WIN then
		GameManager:EndGameWithWinner(DOTA_TEAM_BADGUYS)
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

function ScoreManager:UpdateChargeScoreboard()
	CustomNetTables:SetTableValue("charge", "radiant", {charge = 100 * self.tower_charge[DOTA_TEAM_GOODGUYS] / self.tower_charge_target[DOTA_TEAM_GOODGUYS]})
	CustomNetTables:SetTableValue("charge", "dire", {charge = 100 * self.tower_charge[DOTA_TEAM_BADGUYS] / self.tower_charge_target[DOTA_TEAM_BADGUYS]})
end

function ScoreManager:OnGainCharge(team)
	self.tower_charge[team] = self.tower_charge[team] + 1
	self:UpdateChargeScoreboard()

	if self.tower_charge[team] >= self.tower_charge_target[team] then
		self.tower_charge[team] = 0
		self.tower_charge_target[team] = self.tower_charge_target[team] + CHARGE_TOWER_CHARGE_INCREMENT

		self:ActivateChargeTowers(team)

		Timers:CreateTimer(8, function()
			self:UpdateChargeScoreboard()
		end)
	else
		GlobalMessages:NotifyTeamGotCharge(team)
	end
end

function ScoreManager:ActivateChargeTowers(team)
	for _, tower in pairs(Towers:GetTeamTowers(team)) do
		tower:Activate()
	end

	GlobalMessages:NotifyTeamActivatedCharge(team)
end

function ScoreManager:OnTeamKillSpider(team)
	self.tower_charge[ENEMY_TEAM[team]] = math.max(0, self.tower_charge[ENEMY_TEAM[team]] - math.max(1, math.floor(0.5 * self.tower_charge[ENEMY_TEAM[team]])))

	self:UpdateChargeScoreboard()

	GlobalMessages:NotifyTeamKilledSpider(team)
end