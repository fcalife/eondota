_G.PaintableGrids = PaintableGrids or {}

GRID_RADIUS = 128
GRID_SIZE = 5

NEIGHBOR_SHAPE_CROSS = 1
NEIGHBOR_SHAPE_SQUARE = 2

TEAM_COLORS = {}

TEAM_COLORS[DOTA_TEAM_NEUTRALS] = Vector(1, 1, 1)
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = Vector(0.25, 0.25, 0.8)
TEAM_COLORS[DOTA_TEAM_BADGUYS] = Vector(0.8, 0.25, 0.25)
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = Vector(0.25, 0.8, 0.25)
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = Vector(0.8, 0.25, 0.8)

function PaintableGrids:Init()
	self.squares = {}

	for i = -GRID_SIZE, GRID_SIZE do
		self.squares[i] = {}

		for j = -GRID_SIZE, GRID_SIZE do
			self.squares[i][j] = GridSquare(Vector(2 * GRID_RADIUS * i, 2 * GRID_RADIUS * j, 0))
		end
	end
end

function PaintableGrids:OnRoundStart()
	for _, square_row in pairs(self.squares) do
		for _, square in pairs(square_row) do
			square:Reset()
		end
	end
end

function PaintableGrids:GetTeamScores()
	local scores = {}

	for _, square_row in pairs(self.squares) do
		for _, square in pairs(square_row) do
			local square_team = square:GetCurrentTeam()

			scores[square_team] = (scores[square_team] and scores[square_team] + 1) or 1
		end
	end

	return scores
end

function PaintableGrids:GetSquareClosestTo(position)
	local x = 1 + math.floor((position.x - GRID_RADIUS) / (2 * GRID_RADIUS))
	local y = 1 + math.floor((position.y - GRID_RADIUS) / (2 * GRID_RADIUS))

	if math.abs(x) <= GRID_SIZE and math.abs(y) <= GRID_SIZE then
		return self.squares[x][y]
	end

	return nil
end

function PaintableGrids:GetGridPositionClosestTo(position)
	local x = 1 + math.floor((position.x - GRID_RADIUS) / (2 * GRID_RADIUS))
	local y = 1 + math.floor((position.y - GRID_RADIUS) / (2 * GRID_RADIUS))

	if math.abs(x) <= GRID_SIZE and math.abs(y) <= GRID_SIZE then
		return Vector(x, y, 0)
	end

	return nil
end

function PaintableGrids:GetSquaresAround(x, y, shape)
	local squares = {}

	table.insert(squares, self.squares[x][y])

	if shape == NEIGHBOR_SHAPE_CROSS or shape == NEIGHBOR_SHAPE_SQUARE then
		if self.squares[x-1] and self.squares[x-1][y] then table.insert(squares, self.squares[x-1][y]) end
		if self.squares[x+1] and self.squares[x+1][y] then table.insert(squares, self.squares[x+1][y]) end
		if self.squares[x] and self.squares[x][y-1] then table.insert(squares, self.squares[x][y-1]) end
		if self.squares[x] and self.squares[x][y+1] then table.insert(squares, self.squares[x][y+1]) end
	end

	if shape == NEIGHBOR_SHAPE_SQUARE then
		if self.squares[x-1] and self.squares[x-1][y-1] then table.insert(squares, self.squares[x-1][y-1]) end
		if self.squares[x+1] and self.squares[x+1][y+1] then table.insert(squares, self.squares[x+1][y+1]) end
		if self.squares[x+1] and self.squares[x+1][y-1] then table.insert(squares, self.squares[x+1][y-1]) end
		if self.squares[x-1] and self.squares[x-1][y+1] then table.insert(squares, self.squares[x-1][y+1]) end
	end

	return squares
end



if GridSquare == nil then GridSquare = class({}) end

function GridSquare:constructor(location)
	self.location = GetGroundPosition(location, nil) + Vector(0, 0, 1)
	self.team = DOTA_TEAM_NEUTRALS
	self.release_time = GameRules:GetGameTime()
end

function GridSquare:GetCurrentTeam()
	return self.team or DOTA_TEAM_NEUTRALS
end

function GridSquare:GetLocation()
	return self.location or Vector(0, 0, 129)
end

function GridSquare:Reset()
	self.team = DOTA_TEAM_NEUTRALS
	self.release_time = GameRules:GetGameTime()

	if self.color_pfx then
		ParticleManager:DestroyParticle(self.color_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.color_pfx)
	end

	self.color_pfx = ParticleManager:CreateParticle("particles/econ/generic/generic_shape/projected_square.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.color_pfx, 2, self.location)
	ParticleManager:SetParticleControl(self.color_pfx, 3, Vector(GRID_RADIUS - 3, 0, 0))
	ParticleManager:SetParticleControl(self.color_pfx, 4, TEAM_COLORS[self.team])
end

function GridSquare:SetCurrentTeam(team, stickyness)
	if GameManager:GetGamePhase() < GAME_STATE_BATTLE then return end

	if self.team == team then
		self.release_time = math.max(self.release_time, GameRules:GetGameTime() + stickyness)

		return
	end

	if GameRules:GetGameTime() < self.release_time then return end

	self.release_time = math.max(self.release_time, GameRules:GetGameTime() + stickyness)
	self.team = team

	if self.color_pfx then
		ParticleManager:DestroyParticle(self.color_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.color_pfx)
	end

	self.color_pfx = ParticleManager:CreateParticle("particles/econ/generic/generic_shape/projected_square.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.color_pfx, 2, self.location)
	ParticleManager:SetParticleControl(self.color_pfx, 3, Vector(GRID_RADIUS - 3, 0, 0))
	ParticleManager:SetParticleControl(self.color_pfx, 4, TEAM_COLORS[self.team])

	RoundManager:UpdateScoreboard()
end