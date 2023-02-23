_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

ALL_TEAMS = {
	DOTA_TEAM_GOODGUYS,
	DOTA_TEAM_BADGUYS,
	DOTA_TEAM_CUSTOM_1,
	DOTA_TEAM_CUSTOM_2
}

function ScoreManager:Init()
	self.score = {}
	self.fire_wall = false

	for _, team in pairs(ALL_TEAMS) do
		self.score[team] = 0
	end

	self:UpdateScores()
end

function ScoreManager:InitializeLives()
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do self.score[hero:GetTeam()] = (SMASH_BROS_MODE and SMASH_BROS_LIVES or INITIAL_LIVES) end

	self:UpdateScores()
end

function ScoreManager:UpdateScores()
	CustomNetTables:SetTableValue("score", "scoreboard", self.score)
end

function ScoreManager:OnTeamLoseRound(team)
	if self.score[team] then self.score[team] = self.score[team] - 1 end

	self:UpdateScores()

	self:CheckForWinner()
end

function ScoreManager:CheckForWinner()
	local remaining_teams = {}

	for _, team in pairs(ALL_TEAMS) do
		if self:GetRemainingLives(team) > 0 then
			table.insert(remaining_teams, team)
		end
	end

	if remaining_teams[1] and #remaining_teams == 2 and (not self.fire_wall) then
		self.fire_wall = true
		--RoundWall(INITIAL_CIRCLE_RADIUS, 0, 30, FINAL_CIRCLE_RADIUS)
	end

	if remaining_teams[1] and #remaining_teams == 1 then
		GameManager:EndGameWithWinner(remaining_teams[1])
	end
end

function ScoreManager:OnTeamWinRound(team)
	GlobalMessages:NotifyTeamWonRound(team)
end

function ScoreManager:GetRemainingLives(team)
	return (self.score and self.score[team] or 0)
end

function ScoreManager:GetAllAliveHeroes()
	local live_heroes = {}

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:IsAlive() then
			table.insert(live_heroes, hero)
		end
	end

	return live_heroes
end

function ScoreManager:GetAllRemainingHeroes()
	local live_heroes = {}

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if self:GetRemainingLives(hero:GetTeam()) > 0 then
			table.insert(live_heroes, hero)
		end
	end

	return live_heroes
end

function ScoreManager:GetRemainingPlayerCount()
	local live_heroes = {}

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if self:GetRemainingLives(hero:GetTeam()) > 0 then
			table.insert(live_heroes, hero)
		end
	end

	return #live_heroes
end