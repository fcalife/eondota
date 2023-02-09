_G.GameManager = GameManager or {}

CustomGameEventManager:RegisterListener("host_options_updated", function(_, event)
	GameManager:OnHostSelectedOption(event)
end)



function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	--Flags:Init()
	--RuneSpawners:Init()
	RoundManager:Init()
	ScoreManager:Init()
	--BrushManager:Init()

	-- if TOWERS_ENABLED then Towers:Init() end
	--if LANE_CREEPS_ENABLED then LaneCreeps:Init() end
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:InitializeHero(hero)
	hero:AddNewModifier(hero, nil, "modifier_hero_base_state", {})

	for i = 0, 10 do
		if hero:GetAbilityByIndex(i) then
			hero:GetAbilityByIndex(i):SetLevel(1)
		end
	end

	hero:SetAbilityPoints(0)

	if IsInToolsMode() then
		hero:ModifyGold(50000, true, DOTA_ModifyGold_GameTick)
		hero:AddItemByName("item_dev_blink")
		--hero:AddItemByName("item_dev_dagon")
	end
end

function GameManager:EndGameWithWinner(team)
	self:SetGamePhase(GAME_STATE_END)

	GameRules:SetGameWinner(team)
end

function GameManager:OnHostSelectedOption(event)
	CAMERA_LOCK = (event.lock_camera == 1)
	SMASH_BROS_MODE = (event.smash_mode == 1)
	EXPERIMENTAL_POWERUPS = (event.extra_powerups == 1)
end