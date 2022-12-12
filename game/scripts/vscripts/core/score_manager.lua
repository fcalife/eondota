_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.score = {}
	self.score[DOTA_TEAM_GOODGUYS] = 0
	self.score[DOTA_TEAM_BADGUYS] = 0

	self.tower_charge = {}
	self.tower_charge[DOTA_TEAM_GOODGUYS] = CHARGE_TOWER_BASE_CHARGE
	self.tower_charge[DOTA_TEAM_BADGUYS] = CHARGE_TOWER_BASE_CHARGE

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

function ScoreManager:OnPickupCharge(team)
	self.tower_charge[ENEMY_TEAM[team]] = self.tower_charge[ENEMY_TEAM[team]] - 1
	self:UpdateChargeScoreboard()

	if self.tower_charge[ENEMY_TEAM[team]] <= 0 then
		self.tower_charge_target[ENEMY_TEAM[team]] = self.tower_charge_target[ENEMY_TEAM[team]] + CHARGE_TOWER_CHARGE_INCREMENT
		self.tower_charge[ENEMY_TEAM[team]] = self.tower_charge_target[ENEMY_TEAM[team]]

		self:DeactivateChargeTowers(ENEMY_TEAM[team])

		Timers:CreateTimer(8, function()
			self:UpdateChargeScoreboard()
		end)
	else
		GlobalMessages:NotifyTeamGotCharge(team)
	end
end

function ScoreManager:DeactivateChargeTowers(team)
	for _, tower in pairs(Towers:GetTeamTowers(team)) do
		tower:Deactivate()
	end

	GlobalMessages:NotifyTeamDeactivatedCharge(team)
end

function ScoreManager:OnTeamKillSpider(team)
	for _, tower in pairs(Towers:GetTeamTowers(team)) do
		tower.unit:RemoveModifierByName("modifier_deactivated_charge_tower")
	end

	GlobalMessages:NotifyTeamKilledSpider(team)
end