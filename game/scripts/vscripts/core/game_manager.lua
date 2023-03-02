_G.GameManager = GameManager or {}

CustomGameEventManager:RegisterListener("host_options_updated", function(_, event)
	GameManager:OnHostSelectedOption(event)
end)

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS



function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	EonSpheres:Init()
	NexusManager:Spawn()
	Minerals:Spawn()
	Refineries:Spawn()
	UpgradeCenters:Spawn()
	BarracksManager:Spawn()

	LaneCreeps:Init()
	Towers:Init()
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:OnPreGameStart()
	print("New dota state: pregame")
end

function GameManager:OnGameStart()
	print("New dota state: game start")

	GameRules:GetGameModeEntity():SetFogOfWarDisabled(FOG_OF_WAR_DISABLED)

	self:SetGamePhase(GAME_STATE_BATTLE)

	Refineries:OnGameStart()
	UpgradeCenters:OnGameStart()
	BarracksManager:OnGameStart()
	LaneCreeps:OnGameStart()
	--Towers:OnGameStart()

	GameClock:Start()
end

function GameManager:OnPostGameStart()
	print("New dota state: postgame")
end

function GameManager:InitializeHero(hero)
	hero:AddNewModifier(hero, nil, "modifier_hero_base_state", {})

	for i = 0, 10 do
		local ability = hero:GetAbilityByIndex(i)
		if ability and ability:GetAbilityType() == ABILITY_TYPE_BASIC then
			ability:SetLevel(1)
		end
	end

	hero:HeroLevelUp(false)
	hero:HeroLevelUp(false)

	hero:SetAbilityPoints(0)

	if IsInToolsMode() then
		hero:ModifyGold(50000, true, DOTA_ModifyGold_GameTick)
		hero:AddItemByName("item_dev_blink")
		hero:AddItemByName("item_dev_dagon")
	end
end

function GameManager:EndGameWithWinner(team)
	self:SetGamePhase(GAME_STATE_END)

	GameRules:SetGameWinner(team)
end

function GameManager:OnHostSelectedOption(event)
	FOG_OF_WAR_DISABLED = (event.disable_fog == 1)
end

function GameManager:OnUnitKilled(attacker, killed_unit)
	if killed_unit.is_nexus then GameManager:EndGameWithWinner(ENEMY_TEAM[killed_unit:GetTeam()]) end
end

function GameManager:GetTeamPlayerID(team)
	for id = 0, (DOTA_MAX_PLAYERS - 1) do
		if PlayerResource:IsValidPlayer(id) and PlayerResource:GetTeam(id) == team then
			return id
		end
	end

	return nil
end

function GameManager:GetMapLocation(name)
	local target = Entities:FindByName(nil, name)

	return (target and target:GetAbsOrigin()) or Vector(0, 0, 0)
end