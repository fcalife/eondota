_G.GameManager = GameManager or {}

CustomGameEventManager:RegisterListener("host_options_updated", function(_, event)
	GameManager:OnHostSelectedOption(event)
end)



function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	--Flags:Init()
	--RuneSpawners:Init()
	--RoundManager:Init()
	ScoreManager:Init()
	RespawnManager:Init()
	EnemyManager:Init()
	--BrushManager:Init()
	--LaneCreeps:Init()
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:InitializeHero(hero)
	hero:AddNewModifier(hero, nil, "modifier_hero_base_state", {duration = 20})
	hero:HeroLevelUp(false)
	hero:HeroLevelUp(false)

	for i = 0, 10 do
		if hero:GetAbilityByIndex(i) then
			if hero:GetAbilityByIndex(i):GetAbilityType() == ABILITY_TYPE_BASIC then
				hero:GetAbilityByIndex(i):SetLevel(1)
			end
		end
	end

	hero:AddItemByName("item_bonfire")

	for i = 1, 59 do
		hero:AddItemByName("item_tpscroll")
	end

	hero:SetAbilityPoints(0)
	hero:AddNewModifier(hero, nil, "modifier_hero_boosted_mana_regen", {})

	if IsInToolsMode() then
		hero:ModifyGold(50000, true, DOTA_ModifyGold_GameTick)
		hero:AddItemByName("item_dev_blink")
		hero:AddItemByName("item_dev_dagon")
	else
		hero:AddNewModifier(hero, nil, "modifier_stunned", {})
	end
end

function GameManager:EndGameWithWinner(team)
	self:SetGamePhase(GAME_STATE_END)

	GameRules:SetGameWinner(team)
end

function GameManager:OnHostSelectedOption(event)
	ITEM_SHOP_ENABLED = (event.item_shop == 1)
end