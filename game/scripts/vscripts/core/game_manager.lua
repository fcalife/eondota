_G.GameManager = GameManager or {}

CustomGameEventManager:RegisterListener("host_options_updated", function(_, event)
	GameManager:OnHostSelectedOption(event)
end)



function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	self.player_cursors = {}

	--Flags:Init()
	--RuneSpawners:Init()
	--RoundManager:Init()
	ScoreManager:Init()
	--BrushManager:Init()

	-- if TOWERS_ENABLED then Towers:Init() end
	--if LANE_CREEPS_ENABLED then LaneCreeps:Init() end
end

function GameManager:OnMatchStarted()
	if CAMERA_LOCK then
		self.camera_dummies = {}
		self.camera_dummies[DOTA_TEAM_GOODGUYS] = CreateUnitByName("npc_flag_dummy", GetGroundPosition(Vector(-704, -300, 0), nil), true, nil, nil, DOTA_TEAM_NEUTRALS)
		self.camera_dummies[DOTA_TEAM_BADGUYS] = CreateUnitByName("npc_flag_dummy", GetGroundPosition(Vector(704, -300, 0), nil), true, nil, nil, DOTA_TEAM_NEUTRALS)

		self.camera_dummies[DOTA_TEAM_GOODGUYS]:AddNewModifier(self.camera_dummies[DOTA_TEAM_GOODGUYS], nil, "modifier_dummy_state", {})
		self.camera_dummies[DOTA_TEAM_BADGUYS]:AddNewModifier(self.camera_dummies[DOTA_TEAM_BADGUYS], nil, "modifier_dummy_state", {})

		for _, hero in pairs(HeroList:GetAllHeroes()) do
			LockPlayerCameraOnTarget(hero, self.camera_dummies[hero:GetTeam()], false)
		end
	end

	Ducks:StartSpawning()
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase

	if phase == GAME_STATE_BATTLE then self:OnMatchStarted() end
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

	local basic_shot = hero:FindAbilityByName("ability_dodgeball_throw")
	if basic_shot then basic_shot:ToggleAutoCast() end

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
end

function GameManager:OnCursorPositionReceived(keys)
	if self.player_cursors then self.player_cursors[keys.PlayerID] = Vector(keys.x, keys.y, keys.z) end
end

function GameManager:GetPlayerCursorPosition(hero)
	local id = hero:GetPlayerID()

	return (self.player_cursors[id] or Vector(0, 0, 0))
end