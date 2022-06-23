_G.GameManager = GameManager or {}

function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	for _, radiant_goal in pairs(Entities:FindAllByName("radiant_goal")) do
		self:SpawnGoalTrigger(radiant_goal:GetAbsOrigin(), DOTA_TEAM_GOODGUYS)
	end

	for _, dire_goal in pairs(Entities:FindAllByName("dire_goal")) do
		self:SpawnGoalTrigger(dire_goal:GetAbsOrigin(), DOTA_TEAM_BADGUYS)
	end

	self.eon_stone_spawn_points = {}

	for _, spawn_point in pairs(Entities:FindAllByName("eon_stone_spawn")) do
		table.insert(self.eon_stone_spawn_points, spawn_point:GetAbsOrigin())
	end

	self.spawned_stones = {}
end

function GameManager:SpawnGoalTrigger(position, team)
	MapTrigger(position, TRIGGER_TYPE_CIRCLE, {
		radius = EON_STONE_GOAL_RADIUS
	}, {
		trigger_team = team,
		team_filter = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
	}, function(units)
		for _, unit in pairs(units) do
			if unit:FindItemInInventory("item_eon_stone") then GameManager:OnEonStoneTouchGoal(unit) end
		end
	end)
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:StartEonStoneCountdown()
	local location = table.remove(self.eon_stone_spawn_points)

	if not location then return end

	EmitGlobalSound("stone.warning")

	GlobalMessages:Send("An Eon Stone will spawn in "..EON_STONE_COUNTDOWN_TIME.." seconds!")

	local minimap_dummy = CreateUnitByName("npc_stone_dummy", location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_dummy_state", {})
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_not_on_minimap", {})

	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		AddFOWViewer(team, location, 750, EON_STONE_COUNTDOWN_TIME, false)
		MinimapEvent(team, minimap_dummy, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, EON_STONE_COUNTDOWN_TIME)
	end

	local warning_pfx = ParticleManager:CreateParticle("particles/econ/events/fall_2021/teleport_end_fall_2021_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(warning_pfx, 0, location)
	ParticleManager:SetParticleControl(warning_pfx, 1, location)

	Timers:CreateTimer(3, function() EmitGlobalSound("stone.countdown") end)
	Timers:CreateTimer(5, function() GlobalMessages:Send("An Eon Stone will spawn in 10 seconds!") end)
	Timers:CreateTimer(10, function() GlobalMessages:Send("An Eon Stone will spawn in 5 seconds!") end)

	Timers:CreateTimer(15, function()
		ParticleManager:DestroyParticle(warning_pfx, false)
		ParticleManager:ReleaseParticleIndex(warning_pfx)

		StopGlobalSound("stone.countdown")
		EmitGlobalSound("stone.spawn")

		minimap_dummy:Destroy()

		self:SpawnEonStone(location)
	end)
end

function GameManager:SpawnEonStone(location)
	local container = CreateItemOnPositionForLaunch(location, CreateItem("item_eon_stone", nil, nil))
	local item = container:GetContainedItem()

	local stone_data = {}

	stone_data.location = location

	stone_data.dummy = CreateUnitByName("npc_stone_dummy", location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	stone_data.dummy:AddNewModifier(stone_data.dummy, nil, "modifier_dummy_state", {})

	stone_data.fow_viewers = {}
	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		table.insert(stone_data.fow_viewers, AddFOWViewer(team, location, 750, GAME_MAX_DURATION, false))
	end
	
	table.insert(self.spawned_stones, stone_data)
end

function GameManager:OnEonStonePickedUp(location)
	local id = 0
	local distance = 99999

	for stone_id, stone in pairs(self.spawned_stones) do
		local this_stone_distance = (stone.location - location):Length2D()
		if this_stone_distance < distance then
			distance = this_stone_distance
			id = stone_id
		end
	end

	if id > 0 and self.spawned_stones[id] then
		self.spawned_stones[id].dummy:Destroy()

		for _, viewer in pairs(self.spawned_stones[id].fow_viewers) do
			RemoveFOWViewer(DOTA_TEAM_GOODGUYS, viewer)
			RemoveFOWViewer(DOTA_TEAM_BADGUYS, viewer)
		end

		table.remove(self.spawned_stones, id)
	end
end


function GameManager:InitializeHero(hero)
	hero:AddNewModifier(hero, nil, "modifier_hero_base_state", {})

	for i = 1, 39 do
		hero:AddItemByName("item_tpscroll")
	end

	if IsInToolsMode() then
		hero:AddItemByName("item_dev_blink")
		hero:AddItemByName("item_dev_dagon")
	end
end

function GameManager:EndGameWithWinner(team)
	self:SetGamePhase(GAME_STATE_END)

	GameRules:SetGameWinner(team)
end

function GameManager:OnEonStoneTouchGoal(unit)
	local stone = unit:FindItemInInventory("item_eon_stone")

	if stone then
		ScoreManager:Score(unit:GetTeam(), EON_STONE_SCORE)
		stone:Destroy()
	end
end