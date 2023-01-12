_G.EnemyManager = EnemyManager or {}

ENEMY_SPAWN_DISTANCE = 1300
PATHFINDING_DISTANCE_LIMIT = 2100

MIN_ENCOUNTER_DELAY = 15
MAX_ENCOUNTER_DELAY = 25

function EnemyManager:Init()
	self.minions = {
		[1] = "npc_dota_neutral_kobold",
		[2] = "npc_dota_neutral_giant_wolf",
		[3] = "npc_dota_neutral_wildkin",
		[4] = "npc_dota_neutral_prowler_acolyte",
	}

	self.leaders = {
		[1] = "npc_dota_neutral_kobold_taskmaster",
		[2] = "npc_dota_neutral_alpha_wolf",
		[3] = "npc_dota_neutral_enraged_wildkin",
		[4] = "npc_dota_neutral_prowler_shaman",
	}
end

function EnemyManager:SpawnEnemyForTeam(team)
	local all_heroes = HeroList:GetAllHeroes()
	local team_heroes = {}

	for _, hero in pairs(all_heroes) do
		if hero:GetTeam() == team and hero:IsRealHero() then table.insert(team_heroes, hero) end
	end

	if #team_heroes <= 0 then return 1000 end

	local spawn_focus_hero = team_heroes[RandomInt(1, #team_heroes)]

	if (not spawn_focus_hero) or (not spawn_focus_hero:IsAlive()) then return 3 end

	local location = spawn_focus_hero:GetAbsOrigin()

	local encounter_power = self:RollEncounterDifficulty(spawn_focus_hero)
	local enemy_list = self:RollEncounterComposition(encounter_power)
	local spawn_locations = self:FindSpawnPointsForEnemyGroup(location, #enemy_list)

	if (not spawn_locations) then return 3 end

	if #enemy_list == #spawn_locations then
		for _, enemy in pairs(enemy_list) do
			self:SpawnEnemyForHero(enemy, spawn_focus_hero, table.remove(spawn_locations))
		end
	end

	return RandomInt(MIN_ENCOUNTER_DELAY, MAX_ENCOUNTER_DELAY)
end

function EnemyManager:RollEncounterDifficulty(hero)
	local team = hero:GetTeam()
	local team_level = 0
	local all_heroes = HeroList:GetAllHeroes()

	for _, other_hero in pairs(all_heroes) do
		if other_hero:GetTeam() == team and other_hero:IsRealHero() then team_level = team_level + other_hero:GetLevel() end
	end

	local position = hero:GetAbsOrigin()

	local position_danger = 0

	if position.x < 0 then position_danger = position_danger + 0.00025 * position.x end
	if position.y < 0 then position_danger = position_danger + 0.00025 * position.y end

	if position.x > 0 then position_danger = position_danger + 0.001 * position.x end
	if position.y > 0 then position_danger = position_danger + 0.001 * position.y end

	local test_print = RandomInt(1, 8)

	print("spawning encounter for team "..hero:GetTeam().." with difficulty "..math.max(1, math.floor(0.25 * team_level + position_danger + test_print)).." ("..test_print.." added from randomness)")

	return math.max(1, math.floor(0.3 * team_level + position_danger + test_print))
end

function EnemyManager:RollEncounterComposition(power)
	local enemy_list = {}
	local remaining_power = power

	local has_leader = RandomInt(1, 100) <= 40

	if has_leader then
		local leader_power = math.max(1, math.min(50, RandomInt(1 + math.floor(0.5 * power), power)))
		local leader_tier = math.min(4, 1 + math.floor(0.16 * leader_power))
		local leader_level = math.max(1, math.min(30, leader_power - (10 * (leader_tier - 1))))

		-- Chance to downgrade leader and give it +10 levels
		while (leader_tier > 1 and leader_level <= 20 and RandomInt(1, 100) <= 30) do
			leader_tier = leader_tier - 1
			leader_level = leader_level + 10
		end

		table.insert(enemy_list, {
			name = self.leaders[leader_tier],
			level = leader_level,
		})

		remaining_power = remaining_power - leader_power
	end

	local enemy_tier = math.max(1, math.min(4, math.ceil(0.2 * RandomInt(1 + math.floor(0.5 * remaining_power), remaining_power))))
	local enemy_count = (5 - enemy_tier) + math.max(0, math.floor(0.1 * (remaining_power + RandomInt(1, 50))))
	local enemy_power = enemy_count * (1 + (enemy_tier - 1) * 3)
	local bonus_levels = 0

	if enemy_power < remaining_power then bonus_levels = (remaining_power - enemy_power) end

	for i = 1, enemy_count do
		table.insert(enemy_list, {
			name = self.minions[enemy_tier],
			level = 1 + bonus_levels,
		})
	end

	return enemy_list
end

function EnemyManager:FindSpawnPointsForEnemyGroup(location, enemy_count)
	local remaining_spawns = enemy_count
	local remaining_attempts = 2 * remaining_spawns

	local spawn_points = {}

	while remaining_spawns > 0 and remaining_attempts > 0 do
		local random_spawn = location + RandomVector(ENEMY_SPAWN_DISTANCE)
		local path_length = GridNav:FindPathLength(random_spawn, location)

		if path_length >= 0 and path_length <= PATHFINDING_DISTANCE_LIMIT then
			table.insert(spawn_points, random_spawn)

			remaining_spawns = remaining_spawns - 1
		end

		remaining_attempts = remaining_attempts - 1
	end

	if remaining_spawns <= 0 then return spawn_points end

	return nil
end

function EnemyManager:SpawnEnemyForHero(enemy_data, hero, spawn_location)
	local creep = CreateUnitByName(enemy_data.name, spawn_location, true, nil, nil, DOTA_TEAM_CUSTOM_3)
	creep:AddNewModifier(creep, nil, "modifier_speed_bonus", {duration = 2.0})
	creep:AddNewModifier(creep, nil, "modifier_kill", {duration = 60})

	if enemy_data.level > creep:GetLevel() then creep:CreatureLevelUp(enemy_data.level - creep:GetLevel()) end

	ResolveNPCPositions(spawn_location, 100)

	Timers:CreateTimer(0.5, function()
		if hero:IsAlive() and creep and (not creep:IsNull()) and creep:IsAlive() then
			ExecuteOrderFromTable({
				UnitIndex = creep:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = hero:GetAbsOrigin(),
				Queue = false,
			})

			return 1
		end
	end)
end