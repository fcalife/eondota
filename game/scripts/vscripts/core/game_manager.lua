_G.GameManager = GameManager or {}

function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	for _, radiant_goal in pairs(Entities:FindAllByName("radiant_goal")) do
		local radiant_goal_trigger = MapTrigger(
			radiant_goal:GetAbsOrigin(),
			TRIGGER_TYPE_CIRCLE,
			{
				radius = 300
			},
			{
				trigger_team = DOTA_TEAM_GOODGUYS,
				team_filter = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				unit_filter = DOTA_UNIT_TARGET_HERO,
				flag_filter = DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
			},
			function(units)
				for _, unit in pairs(units) do
					if unit:FindItemInInventory("item_eon_stone") then GameManager:OnEonStoneTouchGoal(unit) end
				end
			end
		)

		radiant_goal_trigger:Start()
	end

	for _, dire_goal in pairs(Entities:FindAllByName("dire_goal")) do
		local dire_goal_trigger = MapTrigger(
			dire_goal:GetAbsOrigin(),
			TRIGGER_TYPE_CIRCLE,
			{
				radius = 300
			},
			{
				trigger_team = DOTA_TEAM_BADGUYS,
				team_filter = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				unit_filter = DOTA_UNIT_TARGET_HERO,
				flag_filter = DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
			},
			function(units)
				for _, unit in pairs(units) do
					if unit:FindItemInInventory("item_eon_stone") then GameManager:OnEonStoneTouchGoal(unit) end
				end
			end
		)

		dire_goal_trigger:Start()
	end

	self.eon_stone_spawn_locations = Entities:FindAllByName("eon_stone_spawn")
	
	for i = 1, MAX_EON_STONES do
		self:SpawnEonStone()
	end
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:SpawnEonStone(location)
	if (not location) then

	end

	local container = CreateItemOnPositionForLaunch(location, CreateItem("item_eon_stone", nil, nil))
	local item = container:GetContainedItem()

	item.radiant_viewer = AddFOWViewer(DOTA_TEAM_GOODGUYS, location, 750, -1, false)
	item.dire_viewer = AddFOWViewer(DOTA_TEAM_BADGUYS, location, 750, -1, false)
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
	local charges = stone:GetCurrentCharges()

	ScoreManager:Score(unit:GetTeam(), charges)

	for i = 1, charges do
		Timers:CreateTimer(15, function()
			self:SpawnEonStone()
		end)
	end

	stone:Destroy()
end