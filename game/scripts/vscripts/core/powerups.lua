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

function PowerupManager:SpawnPowerUp(origin, destination, item_type)
	if (not self.current_powerups) then self.current_powerups = {} end

	table.insert(self.current_powerups, Powerup(origin, destination, item_type))
end

function PowerupManager:CleanPowerups()
	if self.current_powerups then
		for _, powerup in pairs(self.current_powerups) do
			powerup:Destroy()
		end
	end

	self.current_powerups = {}
end

function PowerupManager:MovePowerupsToNextArena()
	if self.current_powerups then
		for _, powerup in pairs(self.current_powerups) do
			if powerup.drop and (not powerup.drop:IsNull()) then
				local current_loc = powerup.drop:GetAbsOrigin()
				local new_loc = Vector(current_loc.x + 8192, current_loc.y, current_loc.z)

				powerup.drop:SetAbsOrigin(new_loc)

				if powerup.trigger then powerup.trigger:MoveTo(new_loc) end
			end
		end
	end
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

function Powerup:constructor(origin, destination, item_type)
	self.origin = origin
	self.destination = destination
	self.item_type = item_type

	self.item = CreateItem(self.item_type, nil, nil)
	self.drop = CreateItemOnPositionForLaunch(self.origin, self.item)
	self.item:LaunchLootInitialHeight(false, 25, 200, 0.7, self.destination)

	if item_type == "item_health_potion" then
		self.drop:SetModelScale(2.4)
	elseif item_type == "item_mario_star" then
		self.drop:SetModelScale(0.9)
	end

	self.drop:EmitSound("KnockbackArena.Powerup.Pop")

	Timers:CreateTimer(0.7, function()
		self.trigger = MapTrigger(self.destination, TRIGGER_TYPE_CIRCLE, {
			radius = 140
		}, {
			trigger_team = DOTA_TEAM_BADGUYS,
			team_filter = DOTA_UNIT_TARGET_TEAM_ENEMY,
			unit_filter = DOTA_UNIT_TARGET_HERO,
			flag_filter = DOTA_UNIT_TARGET_FLAG_NONE,
			find_order = FIND_CLOSEST,
		}, function(units)
			self:Tick(units)
		end, {
			tick_when_empty = true,
		})
	end)
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
		target:Heal(0.2 * target:GetMaxHealth(), nil)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, 0.2 * target:GetMaxHealth(), nil)

		target:EmitSound("KnockbackArena.Powerup.Health")
	elseif self.item_type == "item_mario_star" then
		target:EmitSound("Drop.EonStone")
		target:AddNewModifier(target, nil, "modifier_eon_stone_carrier", {})

	-- elseif self.item_type == "item_power_boots" then
	-- 	target:AddNewModifier(target, nil, "modifier_powerup_boots", {duration = 4})

	-- 	target:EmitSound("KnockbackArena.Powerup.Boots")
	-- elseif self.item_type == "item_power_bull" then
	-- 	target:AddNewModifier(target, nil, "modifier_powerup_bull", {duration = 4})

	-- 	target:EmitSound("KnockbackArena.Powerup.Bull")
	-- elseif self.item_type == "item_power_shield" then
	-- 	target:AddNewModifier(target, nil, "modifier_powerup_shield", {})

	-- 	target:EmitSound("KnockbackArena.Powerup.Shield")
	-- elseif self.item_type == "item_power_metal" then
	-- 	target:AddNewModifier(target, nil, "modifier_powerup_metal", {duration = 8})

	-- 	target:EmitSound("KnockbackArena.Powerup.Metal")
	-- elseif self.item_type == "item_power_refresh" then
	-- 	target:AddNewModifier(target, nil, "modifier_powerup_refresh", {})

	-- 	target:EmitSound("KnockbackArena.Powerup.Refresh")
	-- elseif self.item_type == "item_power_invis" then
	-- 	target:AddNewModifier(target, nil, "modifier_powerup_invis", {duration = 3})

	-- 	target:EmitSound("KnockbackArena.Powerup.Invis")
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