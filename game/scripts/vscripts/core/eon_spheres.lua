_G.EonSpheres = EonSpheres or {}

function EonSpheres:Init()
	self.spheres = {}

	self.spheres[DOTA_TEAM_GOODGUYS] = 0
	self.spheres[DOTA_TEAM_BADGUYS] = 0

	self:UpdateCount()
end

function EonSpheres:GiveTeamSpheres(team, amount)
	if self.spheres[team] then
		self.spheres[team] = self.spheres[team] + amount

		self:UpdateCount()
	end
end

function EonSpheres:SpendTeamSpheres(team, amount)
	if self.spheres[team] and self.spheres[team] >= amount then
		self.spheres[team] = self.spheres[team] - amount

		self:UpdateCount()

		return true
	else
		return false
	end
end

function EonSpheres:UpdateCount()
	CustomNetTables:SetTableValue("score", "scoreboard", self.spheres)
end