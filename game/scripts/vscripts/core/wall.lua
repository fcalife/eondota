_G.Walls = Walls or {}

WALL_DIRECTION_UP = 1
WALL_DIRECTION_DOWN = 2

function Walls:OnRoundStart()
	self.walls = {}

	table.insert(self.walls, Wall(1200, WALL_ACTIVATION_DELAY + 10, WALL_SLIDE_TIME, WALL_MIN_HEIGHT))
	table.insert(self.walls, Wall(-1200, WALL_ACTIVATION_DELAY + 10, WALL_SLIDE_TIME, -WALL_MIN_HEIGHT))
end

function Walls:OnRoundEnd()
	for _, wall in pairs(self.walls) do
		wall:Demolish()
	end
end


if Wall == nil then Wall = class({}) end

function Wall:constructor(initial_height, activation_time, slide_time, final_height)
	self.initial_height = initial_height
	self.activation_time = activation_time
	self.slide_time = slide_time
	self.final_height = final_height

	self.current_height = initial_height
	self.direction = (initial_height > 0 and WALL_DIRECTION_UP) or WALL_DIRECTION_DOWN
	self.start_time = GameRules:GetGameTime()
	self.elapsed_time = 0

	self:UpdateParticlePosition()

	self.timer = Timers:CreateTimer(0.03, function()
		self.elapsed_time = GameRules:GetGameTime() - self.start_time

		if self.elapsed_time > self.activation_time and self.elapsed_time < (self.activation_time + self.slide_time) then
			self:UpdateHeight()
		end

		self:Tick()

		return 0.03
	end)
end

function Wall:UpdateParticlePosition()
	local pfx_start = Vector(-1300, self.current_height, 128)
	local pfx_end = Vector(1300, self.current_height, 128)

	if self.wall_pfx then
		ParticleManager:DestroyParticle(self.wall_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.wall_pfx)
	end

	self.wall_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_wall_of_replica.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.wall_pfx, 0, pfx_start)
	ParticleManager:SetParticleControl(self.wall_pfx, 1, pfx_end)
	ParticleManager:SetParticleControl(self.wall_pfx, 2, Vector(0, 1, 0))
	ParticleManager:SetParticleControl(self.wall_pfx, 60, Vector(255, 90, 40))
	ParticleManager:SetParticleControl(self.wall_pfx, 61, Vector(1, 0, 0))
end

function Wall:UpdateHeight()
	local interpolation = math.min(1, math.max(0, self.elapsed_time - self.activation_time) / self.slide_time)

	self.current_height = self.initial_height + interpolation * (self.final_height - self.initial_height)

	self:UpdateParticlePosition()
end

function Wall:Tick()
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		local position = hero:GetAbsOrigin()

		if position.y > self.current_height and self.direction == WALL_DIRECTION_UP then
			FindClearSpaceForUnit(hero, Vector(position.x, self.current_height - 1, position.z), true)
		elseif position.y < self.current_height and self.direction == WALL_DIRECTION_DOWN then
			FindClearSpaceForUnit(hero, Vector(position.x, self.current_height + 1, position.z), true)
		end
	end
end

function Wall:Demolish()
	if self.wall_pfx then
		ParticleManager:DestroyParticle(self.wall_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.wall_pfx)
	end

	Timers:RemoveTimer(self.timer)
end