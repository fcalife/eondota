-- Game entry point
_G.GameMode = GameMode or {}

-- Core files
require('core_declarations')
require('libraries/init')
require('core/init')

-- Static precache
-- This should only contain sounds, particles, etc. which will need to be loaded every game.
PRECACHE = require('precache')

function Precache(context)
	print("Performing pre-load static precache")
	
	for _, p in pairs(PRECACHE.particles) do
		PrecacheResource("particle", p, context)
	end

	for _, p in pairs(PRECACHE.particle_folders) do
		PrecacheResource("particle_folder", p, context)
	end

	for _, p in pairs(PRECACHE.models) do
		PrecacheResource("model", p, context)
	end

	for _, p in pairs(PRECACHE.model_folders) do
		PrecacheResource("model_folder", p, context)
	end

	for _, p in pairs(PRECACHE.sounds) do
		PrecacheResource("soundfile", p, context)
	end

	for _, p in pairs(PRECACHE.units) do
		PrecacheUnitByNameSync(p, context)
	end

	for _, p in pairs(PRECACHE.items) do
		PrecacheItemByNameSync(p, context)
	end
	
	print("Finished pre-load precache")
end

-- Activate the gamemode
function Activate()
	GameMode:InitGameMode()
end

function GameMode:InitGameMode()

	-- Initial gamemode setup
	GameRules:SetSameHeroSelectionEnabled(false)
	GameRules:SetHeroRespawnEnabled(true)
	GameRules:SetHeroSelectionTime(60)
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)
	GameRules:LockCustomGameSetupTeamAssignment(false)
	GameRules:EnableCustomGameSetupAutoLaunch(false)
	GameRules:SetPreGameTime(8)
	GameRules:SetStartingGold(0)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroMinimapIconScale(1)
	GameRules:SetTreeRegrowTime(9999)
	GameRules:SetFirstBloodActive(false)
	GameRules:SetHideKillMessageHeaders(false)
	GameRules:SetTimeOfDay(0.5)

	if IsInToolsMode() then
		GameRules:SetPreGameTime(3)
	end

	local game_mode_entity = GameRules:GetGameModeEntity()

	game_mode_entity:SetBuybackEnabled(false)
	-- game_mode_entity:SetFogOfWarDisabled(false)
	game_mode_entity:SetLoseGoldOnDeath(false)
	game_mode_entity:SetKillingSpreeAnnouncerDisabled(false)
	game_mode_entity:SetMaximumAttackSpeed(1000)
	game_mode_entity:SetDaynightCycleDisabled(false)
	game_mode_entity:SetCameraDistanceOverride(1250)
	game_mode_entity:SetFreeCourierModeEnabled(false)
	game_mode_entity:SetBotThinkingEnabled(false)
	game_mode_entity:SetAnnouncerDisabled(false)
	game_mode_entity:SetFixedRespawnTime(15)
	game_mode_entity:SetUnseenFogOfWarEnabled(true)

	-- Team configuration
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 3)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 3)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 3)
	--GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 3)

	for team = DOTA_TEAM_CUSTOM_2, DOTA_TEAM_CUSTOM_6 do
		GameRules:SetCustomGameTeamMaxPlayers(team, 0)
	end

	SetTeamCustomHealthbarColor(DOTA_TEAM_GOODGUYS, 64, 64, 208)
	SetTeamCustomHealthbarColor(DOTA_TEAM_BADGUYS, 208, 64, 64)
	SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_1, 64, 208, 64)
	SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_2, 208, 64, 208)

	local global_shop = SpawnDOTAShopTriggerRadiusApproximate(Vector(0,0,0), 50000)
	global_shop:SetShopType(DOTA_SHOP_HOME)

	-- Initialize modules
	GameManager:Init()
	Filters:Init()

	-- Event Hooks
	RegisterGameEventListener('player_connect_full', function(event) GameEvents:OnPlayerConnect(event) end)
	RegisterGameEventListener('player_disconnect', function(event) GameEvents:OnPlayerDisconnect(event) end)
	RegisterGameEventListener('player_reconnected', function(event) GameEvents:OnPlayerReconnect(event) end)
	RegisterGameEventListener('dota_item_picked_up', function(event) GameEvents:OnItemPickedUp(event) end)
	RegisterGameEventListener('entity_killed', function(event) GameEvents:OnEntityKilled(event) end)
	RegisterGameEventListener('player_changename', function(event) GameEvents:OnPlayerNameChange(event) end)
	RegisterGameEventListener('tree_cut', function(event) GameEvents:OnTreeCut(event) end)
	RegisterGameEventListener('game_rules_state_change', function(event) GameEvents:OnGameStateChange(event) end)
	RegisterGameEventListener('npc_spawned', function(event) GameEvents:OnUnitSpawn(event) end)
	RegisterGameEventListener('dota_player_pick_hero', function(event) GameEvents:OnPlayerPickHero(event) end)
	RegisterGameEventListener('dota_illusions_created', function(event) GameEvents:OnIllusionSpawn(event) end)
	RegisterGameEventListener('player_chat', function(event) GameEvents:OnPlayerChat(event) end)
	RegisterGameEventListener('dota_player_killed', function(event) GameEvents:OnPlayerKilled(event) end)

	-- Custom events
	RegisterCustomEventListener("cursor_checked", function(event) GameEvents:OnCursorPositionReceived(event) end)

	-- Custom console commands
	--Convars:RegisterCommand("runes_on", Dynamic_Wrap(GameMode, 'EnableAllRunes'), "Enables all runes", FCVAR_CHEAT)
end