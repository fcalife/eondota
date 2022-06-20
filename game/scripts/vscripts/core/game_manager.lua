_G.GameManager = GameManager or {}

function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	ListenToGameEvent("trigger_start_touch", Dynamic_Wrap(GameManager, "OnTriggerStartTouch"), self)
	ListenToGameEvent("trigger_end_touch", Dynamic_Wrap(GameManager, "OnTriggerEndTouch"), self)

	for _, spawn_location in pairs(Entities:FindAllByName("eon_stone_spawn")) do
		self:SpawnEonStone(spawn_location:GetAbsOrigin())
	end
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:SpawnEonStone(location)
	local container = CreateItemOnPositionForLaunch(location, CreateItem("item_eon_stone", nil, nil))
	local item = container:GetContainedItem()

	item.original_location = location

	item.fow_viewers = {
		AddFOWViewer(DOTA_TEAM_GOODGUYS, location, 750, -1, false),
		AddFOWViewer(DOTA_TEAM_BADGUYS, location, 750, -1, false)
	}
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

function GameManager:OnTriggerStartTouch(event)
	local trigger_name = event.trigger_name
	local unit = EntIndexToHScript(event.activator_entindex)

	print("TRIGGERED")
	if unit:FindItemInInventory("item_eon_stone") then print("MEGA TRIGGERED") end
end

function GameManager:OnTriggerEndTouch(event)
	local trigger_name = event.trigger_name
	local unit = EntIndexToHScript(event.activator_entindex)

	print("UNTRIGGERED")
end