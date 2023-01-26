_G.EnemyManager = EnemyManager or {}

ENEMY_SPAWN_DISTANCE = 1400
PATHFINDING_DISTANCE_LIMIT = 2000

MIN_ENCOUNTER_DELAY = 15
MAX_ENCOUNTER_DELAY = 25

SPAWNER_COOLDOWN = 120

MAX_ENCOUNTER_TIER = 3

EXP_BOUNTIES = {
	[1] = 60,
	[2] = 110,
	[3] = 200
}

GOLD_BOUNTIES = {
	[1] = 40,
	[2] = 70,
	[3] = 120
}

function EnemyManager:Init()
	self.creep_spawners = {}

	for _, biome in pairs(BIOME_LIST) do
		for tier = 1, MAX_ENCOUNTER_TIER do
			local spawn_points = Entities:FindAllByName("creep_spawn_"..biome.."_"..tier)

			for _, spawn_point in pairs(spawn_points) do
				table.insert(self.creep_spawners, Spawner(spawn_point:GetAbsOrigin(), biome, tier))
			end
		end
	end

	-- self.team_spawn_enabled = {}
	-- self.team_spawn_enabled[DOTA_TEAM_GOODGUYS] = true
	-- self.team_spawn_enabled[DOTA_TEAM_BADGUYS] = true
	-- self.team_spawn_enabled[DOTA_TEAM_CUSTOM_1] = true
	-- self.team_spawn_enabled[DOTA_TEAM_CUSTOM_2] = true

	-- print("spawner list and distance to world center:")
	-- for _, spawner in pairs(self.creep_spawners) do
	-- 	spawner:Describe()
	-- end
end

function EnemyManager:ActivateSpawnersAround(unit)
	local location = unit:GetAbsOrigin()
	local team = unit:GetTeam()

	for _, spawner in pairs(self.creep_spawners) do
		if spawner:IsReady() and spawner:IsInRangeOf(location) then
			spawner:ActivateOn(unit)
		end
	end
end



if Spawner == nil then Spawner = class({}) end

function Spawner:constructor(location, biome, tier)
	self.location = location
	self.biome = biome
	self.tier = tier

	self.ready = true
end

function Spawner:IsReady()
	return self.ready
end

function Spawner:Describe()
	print("tier "..self.tier.." "..self.biome.." spawner, "..(self.location - Vector(0, 0, 0)):Length2D().." distance from center")
end

function Spawner:IsInRangeOf(position)
	return (self.location - position):Length2D() < ENEMY_SPAWN_DISTANCE and GridNav:FindPathLength(self.location, position) < PATHFINDING_DISTANCE_LIMIT
end

function Spawner:ActivateOn(target)
	self:Spawn("enemy_"..self.biome.."_"..self.tier.."_leader", target)

	for i = 1, (2 + RandomInt(1, 5)) do
		self:Spawn("enemy_"..self.biome.."_"..self.tier.."_minion", target)
	end

	ResolveNPCPositions(self.location, 300)

	self.ready = false

	Timers:CreateTimer(SPAWNER_COOLDOWN, function() self.ready = true end)
end

function Spawner:Spawn(unit, target)
	local creep = CreateUnitByName(unit, self.location + RandomVector(200), true, nil, nil, DOTA_TEAM_CUSTOM_3)
	creep:AddNewModifier(creep, nil, "modifier_speed_bonus", {duration = 2.0})
	creep:AddNewModifier(creep, nil, "modifier_kill", {duration = 60})

	creep.spawner = self

	Timers:CreateTimer(0.5, function()
		if target:IsAlive() and creep and (not creep:IsNull()) and creep:IsAlive() then
			ExecuteOrderFromTable({
				UnitIndex = creep:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = target:GetAbsOrigin(),
				Queue = false,
			})

			return 1
		end
	end)
end

function Spawner:OnCreepDied(killer)
	GoldRewards:GiveGoldToPlayersInTeam(killer:GetTeam(), GOLD_BOUNTIES[self.tier], EXP_BOUNTIES[self.tier])
end