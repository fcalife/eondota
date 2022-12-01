_G.GameManager = GameManager or {}

CustomGameEventManager:RegisterListener("host_options_updated", function(_, event)
	GameManager:OnHostSelectedOption(event)
end)



function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	Flags:Init()
	RuneSpawners:Init()
	--RoundManager:Init()
	ScoreManager:Init()
	BrushManager:Init()
	--LaneCreeps:Init()

	if TOWERS_ENABLED then Towers:Init() end
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:InitializeHero(hero)
	hero:AddNewModifier(hero, nil, "modifier_hero_base_state", {duration = 15})
	hero:HeroLevelUp(false)
	hero:HeroLevelUp(false)

	for i = 0, 10 do
		if hero:GetAbilityByIndex(i) then
			if hero:GetAbilityByIndex(i):GetAbilityType() == ABILITY_TYPE_BASIC then
				hero:GetAbilityByIndex(i):SetLevel(1)
			end
		end
	end

	hero:SetAbilityPoints(0)

	hero:AddNewModifier(hero, nil, "modifier_stunned", {})

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
	REVERSE_CTF = (event.reverse_ctf == 1)
	TOWERS_ENABLED = (event.enable_towers == 1)
	LANE_CREEPS_ENABLED = (event.enable_creeps == 1)
	FOG_OF_WAR_DISABLED = (event.disable_fog == 1)
end