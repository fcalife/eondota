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
	LaneCreeps:Init()
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:InitializeHero(hero)
	hero:AddNewModifier(hero, nil, "modifier_hero_base_state", {})
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
		--hero:ModifyGold(50000, true, DOTA_ModifyGold_GameTick)
		--hero:AddItemByName("item_dev_blink")
		--hero:AddItemByName("item_dev_dagon")
	end

	if hero:GetUnitName() == "npc_dota_hero_axe" then
		hero:AddItemByName("item_phase_boots")
		hero:AddItemByName("item_blade_mail")
		if EXTRA_WEAK_HERO_HEALTH then hero:AddNewModifier(hero, nil, "modifier_bonus_hero_health", {}) end
	elseif hero:GetUnitName() == "npc_dota_hero_primal_beast" then
		hero:AddItemByName("item_boots")
		hero:AddItemByName("item_vanguard")
		if EXTRA_WEAK_HERO_HEALTH then hero:AddNewModifier(hero, nil, "modifier_bonus_hero_health", {}) end
	elseif hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
		hero:AddItemByName("item_phase_boots")
		hero:AddItemByName("item_desolator")
		if EXTRA_WEAK_HERO_HEALTH then hero:AddNewModifier(hero, nil, "modifier_bonus_hero_health", {}) end
	elseif hero:GetUnitName() == "npc_dota_hero_jakiro" then
		hero:AddItemByName("item_boots")
		hero:AddItemByName("item_shivas_guard")
		if EXTRA_WEAK_HERO_HEALTH then hero:AddNewModifier(hero, nil, "modifier_bonus_hero_health", {}) end
	elseif hero:GetUnitName() == "npc_dota_hero_nevermore" then
		hero:AddItemByName("item_power_treads")
		hero:AddItemByName("item_yasha_and_kaya")
		if EXTRA_WEAK_HERO_HEALTH then hero:AddNewModifier(hero, nil, "modifier_bonus_hero_health", {}) end
	elseif hero:GetUnitName() == "npc_dota_hero_windrunner" then
		hero:AddItemByName("item_ultimate_scepter_2")
		hero:AddItemByName("item_aghanims_shard")
		hero:AddItemByName("item_monkey_king_bar")
		hero:AddItemByName("item_black_king_bar")
		hero:AddItemByName("item_mjollnir")
		hero:AddItemByName("item_hurricane_pike")

		Timers:CreateTimer(0.1, function()
			hero:AddItemByName("item_power_treads")
			hero:AddItemByName("item_overwhelming_blink")
		end)

		for i = 1, 27 do hero:HeroLevelUp(false) end

		for i = 0, 10 do
			if hero:GetAbilityByIndex(i) then
				hero:GetAbilityByIndex(i):SetLevel(hero:GetAbilityByIndex(i):GetMaxLevel())
			end
		end

		hero:SetAbilityPoints(8)
	end
end

function GameManager:EndGameWithWinner(team)
	self:SetGamePhase(GAME_STATE_END)

	GameRules:SetGameWinner(team)
end

function GameManager:OnHostSelectedOption(event)
	TOWERS_ENABLED = (event.enable_towers == 1)
	LANE_CREEPS_ENABLED = (event.enable_creeps == 1)
	FOG_OF_WAR_DISABLED = (event.disable_fog == 1)
	EXTRA_WEAK_HERO_HEALTH = (event.extra_hp == 1)
end