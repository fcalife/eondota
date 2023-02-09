_G.Walls = Walls or {}

WALL_DIRECTION_UP = 1
WALL_DIRECTION_DOWN = 2

function Walls:OnRoundStart()
	self.current_wall = RoundWall(INITIAL_CIRCLE_RADIUS, CIRCLE_DELAY + 10, CIRCLE_SLIDE_TIME, FINAL_CIRCLE_RADIUS)
end

function Walls:OnRoundEnd()
	if self.current_wall then self.current_wall:Demolish() end
end

function Walls:GetCurrentWallRadius()
	return (self.current_wall and self.current_wall.current_radius or ARENA_RADIUS)
end



if RoundWall == nil then RoundWall = class({}) end

function RoundWall:constructor(initial_radius, activation_time, slide_time, final_radius)
	self.initial_radius = initial_radius
	self.activation_time = activation_time
	self.slide_time = slide_time
	self.final_radius = final_radius

	self.current_radius = initial_radius
	self.start_time = GameRules:GetGameTime()
	self.elapsed_time = 0

	self.timer = Timers:CreateTimer(0.03, function()
		self.elapsed_time = GameRules:GetGameTime() - self.start_time

		if self.elapsed_time > self.activation_time then
			if self.elapsed_time < (self.activation_time + self.slide_time) then
				self:UpdateRadius()
			end

			self:Tick()
		end

		return 0.03
	end)
end

function RoundWall:UpdateParticle()
	if self.wall_pfx then
		ParticleManager:SetParticleControl(self.wall_pfx, 1, Vector(self.current_radius, 0, 0))
	else
		self.wall_pfx = ParticleManager:CreateParticle("particles/knockback/flame_ring.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(self.wall_pfx, 0, Vector(0, 0, 50))
		ParticleManager:SetParticleControl(self.wall_pfx, 1, Vector(self.current_radius, 0, 0))
	end
end

function RoundWall:UpdateRadius()
	local interpolation = math.min(1, math.max(0, self.elapsed_time - self.activation_time) / self.slide_time)

	self.current_radius = self.initial_radius + interpolation * (self.final_radius - self.initial_radius)

	self:UpdateParticle()
end

function RoundWall:Tick()
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		local position = hero:GetAbsOrigin()
		local center_distance = position:Length2D()

		if hero:IsAlive() and center_distance > self.current_radius and (not (hero:HasModifier("modifier_knockback") or hero:HasModifier("modifier_thrown_out"))) then
			local distance = INITIAL_CIRCLE_RADIUS - center_distance + 100
			local duration = 0.2 + 0.0002 * distance

			local knockback = {
				center_x = 0,
				center_y = 0,
				center_z = 0,
				knockback_duration = duration,
				knockback_distance = distance,
				knockback_height = 50,
				should_stun = 1,
				duration = duration
			}

			hero:RemoveModifierByName("modifier_knockback")
			hero:AddNewModifier(hero, nil, "modifier_knockback", knockback)

			hero:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		end
	end
end

function RoundWall:Demolish()
	if self.wall_pfx then
		ParticleManager:DestroyParticle(self.wall_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.wall_pfx)
	end

	Timers:RemoveTimer(self.timer)
end



if Donut == nil then Donut = class({}) end

function Donut:constructor(radius)
	self.current_radius = radius

	self.wall_pfx = ParticleManager:CreateParticle("particles/knockback/flame_ring.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.wall_pfx, 0, Vector(0, 0, 50))
	ParticleManager:SetParticleControl(self.wall_pfx, 1, Vector(self.current_radius, 0, 0))

	self.timer = Timers:CreateTimer(0.03, function()
		self:Tick()

		return 0.03
	end)
end

function Donut:Tick()
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		local position = hero:GetAbsOrigin()
		local center_distance = position:Length2D()

		if hero:IsAlive() and center_distance < self.current_radius and (not hero:HasModifier("modifier_knockback")) then
			local distance = 400
			local duration = 0.2

			local knockback = {
				center_x = 0,
				center_y = 0,
				center_z = 0,
				knockback_duration = duration,
				knockback_distance = distance,
				knockback_height = 50,
				should_stun = 1,
				duration = duration
			}

			hero:RemoveModifierByName("modifier_knockback")
			hero:AddNewModifier(hero, nil, "modifier_knockback", knockback)

			hero:ReduceMana(1)
			hero:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		end
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