_G.PowerupManager = PowerupManager or {}

MIN_DROP_TIME = 10
MAX_DROP_TIME = 20

POWERUP_LIST = {
	"item_health_potion",
	"item_mario_star",
}

function PowerupManager:OnRoundStart()
	if EXPERIMENTAL_POWERUPS then
		MIN_DROP_TIME = 8
		MAX_DROP_TIME = 16

		POWERUP_LIST = {
			"item_health_potion",
			"item_mario_star",
			--"item_power_boots",
			"item_power_bull",
			"item_power_shield",
			"item_power_metal",
			"item_power_refresh",
			"item_power_invis",
		}
	end

	self.timer = Timers:CreateTimer(RandomInt(MIN_DROP_TIME, MAX_DROP_TIME), function()
		self:SpawnPowerUp()

		return RandomInt(MIN_DROP_TIME, MAX_DROP_TIME)
	end)
end

function PowerupManager:OnRoundEnd()
	if self.timer then Timers:RemoveTimer(self.timer) end
end

function PowerupManager:SpawnPowerUp()
	local live_heroes = ScoreManager:GetAllAliveHeroes()
	local spawn_center = Vector(0, 0, 0)
	local max_radius = 0

	if #live_heroes > 0 then
		local hero_weight = 1 / #live_heroes

		for _, hero in pairs(live_heroes) do
			spawn_center = spawn_center + hero_weight * hero:GetAbsOrigin()
		end

		for _, hero in pairs(live_heroes) do
			local hero_radius = (hero:GetAbsOrigin() - spawn_center):Length2D()
			max_radius = math.max(max_radius, hero_radius)
		end
	end

	local spawn_point = spawn_center + RandomVector(RandomFloat(0, max_radius))
	local attempts = 1

	while attempts < 10 and (not self:IsSpawnPointValid(spawn_point)) do
		attempts = attempts + 1
		spawn_point = spawn_point + RandomVector(300)
	end

	if self:IsSpawnPointValid(spawn_point) then	Powerup(spawn_point) end
end

function PowerupManager:IsSpawnPointValid(position)
	if position:Length2D() > ARENA_RADIUS then return false end
	if position:Length2D() > Walls:GetCurrentWallRadius() then return false end

	local live_heroes = ScoreManager:GetAllAliveHeroes()

	for _, hero in pairs(live_heroes) do
		if (hero:GetAbsOrigin() - position):Length2D() < 325 then return false end
	end

	return true
end



if Powerup == nil then Powerup = class({}) end

function Powerup:constructor(location)
	self.location = location
	self.item_type = POWERUP_LIST[RandomInt(1, #POWERUP_LIST)]

	self.item = CreateItem(self.item_type, nil, nil)
	self.drop = CreateItemOnPositionForLaunch(self.location, self.item)

	self.drop:SetModelScale(1.4)

	self.drop:EmitSound("KnockbackArena.Powerup.Pop")

	self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
		radius = 140
	}, {
		trigger_team = DOTA_TEAM_NEUTRALS,
		team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		find_order = FIND_CLOSEST,
	}, function(units)
		self:Tick(units)
	end, {
		tick_when_empty = true,
	})
end

function Powerup:Tick(units)
	if GameManager:GetGamePhase() ~= GAME_STATE_BATTLE then self:Destroy() end

	if units and units[1] then
		self:Activate(units[1])
		self:Destroy()
	end
end

function Powerup:Activate(target)
	if self.item_type == "item_health_potion" then
		target:Heal(4, nil)

		target:EmitSound("KnockbackArena.Powerup.Health")
	elseif self.item_type == "item_mario_star" then
		target:AddNewModifier(target, nil, "modifier_powerup_star", {duration = 2.5})

		target:EmitSound("KnockbackArena.Powerup.Star")
	elseif self.item_type == "item_power_boots" then
		target:AddNewModifier(target, nil, "modifier_powerup_boots", {duration = 4})

		target:EmitSound("KnockbackArena.Powerup.Boots")
	elseif self.item_type == "item_power_bull" then
		target:AddNewModifier(target, nil, "modifier_powerup_bull", {duration = 4})

		target:EmitSound("KnockbackArena.Powerup.Bull")
	elseif self.item_type == "item_power_shield" then
		target:AddNewModifier(target, nil, "modifier_powerup_shield", {})

		target:EmitSound("KnockbackArena.Powerup.Shield")
	elseif self.item_type == "item_power_metal" then
		target:AddNewModifier(target, nil, "modifier_powerup_metal", {duration = 8})

		target:EmitSound("KnockbackArena.Powerup.Metal")
	elseif self.item_type == "item_power_refresh" then
		target:AddNewModifier(target, nil, "modifier_powerup_refresh", {})

		target:EmitSound("KnockbackArena.Powerup.Refresh")
	elseif self.item_type == "item_power_invis" then
		target:AddNewModifier(target, nil, "modifier_powerup_invis", {duration = 3})

		target:EmitSound("KnockbackArena.Powerup.Invis")
	end

	local pickup_pfx = ParticleManager:CreateParticle("particles/dodgeball/powerup_pickup.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pickup_pfx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pickup_pfx)
end

function Powerup:Destroy()
	if self.item and (not self.item:IsNull()) then self.item:Destroy() end
	if self.drop and (not self.drop:IsNull()) then self.drop:Destroy() end

	if self.trigger then self.trigger:Stop() end
end