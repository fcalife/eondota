_G.RespawnManager = RespawnManager or {}

function RespawnManager:Init()
	self.respawn_points = {}
	self.original_respawn_points = {}
	self.current_respawn_outposts = {}

	self.available_respawn_points = Entities:FindAllByName("player_spawn_point")

	for key, respawn_point in pairs(self.available_respawn_points) do
		self.available_respawn_points[key] = respawn_point:GetAbsOrigin()
	end

	local shuffled_respawns = table.shuffled(self.available_respawn_points)

	self.respawn_points[DOTA_TEAM_GOODGUYS] = table.remove(shuffled_respawns)
	self.respawn_points[DOTA_TEAM_BADGUYS] = table.remove(shuffled_respawns)
	self.respawn_points[DOTA_TEAM_CUSTOM_1] = table.remove(shuffled_respawns)
	self.respawn_points[DOTA_TEAM_CUSTOM_2] = table.remove(shuffled_respawns)

	self.original_respawn_points[DOTA_TEAM_GOODGUYS] = self.respawn_points[DOTA_TEAM_GOODGUYS]
	self.original_respawn_points[DOTA_TEAM_BADGUYS] = self.respawn_points[DOTA_TEAM_BADGUYS]
	self.original_respawn_points[DOTA_TEAM_CUSTOM_1] = self.respawn_points[DOTA_TEAM_CUSTOM_1]
	self.original_respawn_points[DOTA_TEAM_CUSTOM_2] = self.respawn_points[DOTA_TEAM_CUSTOM_2]

	self:UpdateRespawnForTeam(DOTA_TEAM_GOODGUYS)
	self:UpdateRespawnForTeam(DOTA_TEAM_BADGUYS)
	self:UpdateRespawnForTeam(DOTA_TEAM_CUSTOM_1)
	self:UpdateRespawnForTeam(DOTA_TEAM_CUSTOM_2)
end

function RespawnManager:SetTeamRespawnPosition(team, position)
	self.respawn_points[team] = position

	self:UpdateRespawnForTeam(team)
end

function RespawnManager:SetTeamRespawnOutpost(team, outpost)
	if self.current_respawn_outposts[team] then
		if self.current_respawn_outposts[team] ~= outpost then
			self.current_respawn_outposts[team]:Reset()
		end
	end

	self.current_respawn_outposts[team] = outpost

	GridNav:DestroyTreesAroundPoint(outpost.location, 250, true)

	self:SetTeamRespawnPosition(team, outpost.location + RandomVector(200))
end

function RespawnManager:ResetTeamRespawnPosition(team)
	self.respawn_points[team] = self.original_respawn_points[team] or Vector(0, 0, 0)

	self:UpdateRespawnForTeam(team)
end

function RespawnManager:UpdateRespawnForTeam(team)
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		if hero:GetTeam() == team then
			hero:SetRespawnPosition(self.respawn_points[team])
		end
	end
end

function RespawnManager:RespawnAllHeroes()
	self:UpdateRespawnForTeam(DOTA_TEAM_GOODGUYS)
	self:UpdateRespawnForTeam(DOTA_TEAM_BADGUYS)
	self:UpdateRespawnForTeam(DOTA_TEAM_CUSTOM_1)
	self:UpdateRespawnForTeam(DOTA_TEAM_CUSTOM_2)

	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		hero:RespawnHero(false, false)
		CenterPlayerCameraOnHero(hero)
		ResolveNPCPositions(hero:GetAbsOrigin(), 128)
	end
end