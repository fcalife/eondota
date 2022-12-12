_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.score = {}
	self.score[DOTA_TEAM_GOODGUYS] = 0
	self.score[DOTA_TEAM_BADGUYS] = 0

	self.essence = {}
	self.essence[DOTA_TEAM_GOODGUYS] = 0
	self.essence[DOTA_TEAM_BADGUYS] = 0

	self.essence_target = {}
	self.essence_target[DOTA_TEAM_GOODGUYS] = FIRE_ESSENCE_BASE
	self.essence_target[DOTA_TEAM_BADGUYS] = FIRE_ESSENCE_BASE

	self:UpdateEssenceScoreboard()
end

function ScoreManager:UpdateEssenceScoreboard()
	CustomNetTables:SetTableValue("charge", "radiant", {current = self.essence[DOTA_TEAM_GOODGUYS], target = self.essence_target[DOTA_TEAM_GOODGUYS]})
	CustomNetTables:SetTableValue("charge", "dire", {current = self.essence[DOTA_TEAM_BADGUYS], target = self.essence_target[DOTA_TEAM_BADGUYS]})
end

function ScoreManager:AddEssence(team, amount)
	self.essence[team] = math.min(self.essence[team] + amount, self.essence_target[team])
	self:UpdateEssenceScoreboard()

	if self.essence[team] >= self.essence_target[team] then
		self.essence_target[team] = self.essence_target[team] + FIRE_ESSENCE_INCREMENT
		self.essence[team] = 0

		Firelord:Bombard(ENEMY_TEAM[team])

		GlobalMessages:NotifyTeamBribedFireGuardian(team)
	else
		GlobalMessages:NotifyTeamDeliveredEssence(team)
	end
end