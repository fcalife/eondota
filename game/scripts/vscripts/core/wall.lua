_G.Walls = Walls or {}

function Walls:Init()
	self.walls = {}

	self.walls[DOTA_TEAM_GOODGUYS] = Wall(DOTA_TEAM_GOODGUYS)
	self.walls[DOTA_TEAM_BADGUYS] = Wall(DOTA_TEAM_BADGUYS)
end



if Wall == nil then Wall = class({}) end

function Wall:constructor(team)
	local wall_ends = Entities:FindAllByName(team == DOTA_TEAM_GOODGUYS and "radiant_wall_end" or "dire_wall_end")

	self.start_position = wall_ends[1]:GetAbsOrigin()
	self.end_position = wall_ends[2]:GetAbsOrigin()

	self.direction = (self.end_position - self.start_position):Normalized()
	self.length = (self.end_position - self.start_position):Length2D()

	self.blocker_radius = 100
	self.blocker_distance = 0.5 * self.blocker_radius

	self.blockers = {}

	local current_length = 0
	while current_length < self.length do
		table.insert(self.blockers, CreateModifierThinker(nil, nil, "modifier_wall_blocker", {}, self.start_position + current_length * self.direction, team, true))

		current_length = current_length + self.blocker_distance
	end

	self.wall_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_wall_of_replica.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.wall_pfx, 0, self.start_position)
	ParticleManager:SetParticleControl(self.wall_pfx, 1, self.end_position)
	ParticleManager:SetParticleControl(self.wall_pfx, 2, Vector(0, 1, 0))
	ParticleManager:SetParticleControl(self.wall_pfx, 60, Vector(255, 90, 40))
	ParticleManager:SetParticleControl(self.wall_pfx, 61, Vector(1, 0, 0))

	self.trigger = MapTrigger(self.start_position * 0.5 * self.length * self.direction, TRIGGER_TYPE_RECTANGLE, {
		start_pos = self.start_position,
		end_pos = self.end_position,
		height = 50,
	}, {
		trigger_team = ENEMY_TEAM[team],
		team_filter = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		unit_filter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		flag_filter = DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
	}, function(units)
		self:OnUnitsInWallRange(units)
	end, {
		tick_when_empty = false,
	})
end

function Wall:OnUnitsInWallRange(units)
	for _, unit in pairs(units) do
		unit:AddNewModifier(unit, nil, "modifier_ignore_wall", {duration = 0.1})
	end
end

function Wall:Demolish()
	if self.wall_pfx then
		ParticleManager:DestroyParticle(self.wall_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.wall_pfx)
	end

	for _, blocker in pairs(self.blockers) do
		blocker:Destroy()
	end

	self.trigger:Stop()
end