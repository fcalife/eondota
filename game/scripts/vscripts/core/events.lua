_G.GameEvents = GameEvents or {}

GameEvents.verbose_events = false

function GameEvents:DebugPrint(message)
	if self.verbose_events then print("[GAME EVENTS] "..message) end
end

function GameEvents:OnGameStateChange()
	self:DebugPrint("The game state has changed")

	local new_state = GameRules:State_Get()

	if new_state == DOTA_GAMERULES_STATE_PRE_GAME then
		GameEvents:OnPreGameStart()
	elseif new_state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameEvents:OnGameStart()
	elseif new_state == DOTA_GAMERULES_STATE_POST_GAME then
		GameEvents:OnPostGameStart()
	end
end

function GameEvents:OnPreGameStart()
	self:DebugPrint("New state: pregame")
end

function GameEvents:OnGameStart()
	self:DebugPrint("New state: game start")

	GameClock:Start()
end

function GameEvents:OnPostGameStart()
	self:DebugPrint("New state: postgame")
end

function GameEvents:OnPlayerConnect(keys)
	self:DebugPrint("A player has connected to the game")

	local player_id = keys.PlayerID
	local user_id = keys.userid
end

function GameEvents:OnPlayerDisconnect(keys)
	self:DebugPrint("A player has disconnected from the game")

	local player_id = keys.PlayerID
	local user_id = keys.userid
	local network_id = keys.networkid
end

function GameEvents:OnPlayerReconnect(keys)
	self:DebugPrint("A player has reconnected to the game")

	local player_id = keys.PlayerID
	local user_id = keys.userid
end

function GameEvents:OnPlayerPickHero(keys)
	self:DebugPrint("A player has picked their hero")

	local player = keys.player
	local hero_name = keys.hero
	local hero = keys.heroindex and EntIndexToHScript(keys.heroindex) or nil

	GameManager:InitializeHero(hero)
end

function GameEvents:OnPlayerNameChange(keys)
	self:DebugPrint("A player has changed their name")
end

function GameEvents:OnPlayerChat(keys)
	self:DebugPrint("A player has sent a chat message")

	local player_id = keys.playerid
	local user_id = keys.userid
	local allies_only = keys.teamonly and keys.teamonly == 1
	local text = keys.text
end

function GameEvents:OnUnitSpawn(keys)
	self:DebugPrint("A unit has spawned in the game")

	local unit = EntIndexToHScript(keys.entindex)
end

-- This event does not reference the illusion itself; it has to be caught on the OnUnitSpawn event
function GameEvents:OnIllusionSpawn(keys)
	self:DebugPrint("A illusion has spawned in the game")

	local source_unit = EntIndexToHScript(keys.original_entindex)
end

function GameEvents:OnEntityKilled(keys)
	self:DebugPrint("An entity has died somewhere")

	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local killed_unit = EntIndexToHScript(keys.entindex_killed)

	RoundManager:OnUnitKilled(killed_unit)
end

function GameEvents:OnTreeCut(keys)
	self:DebugPrint("A tree has been cut")

	local player_id = keys.killerID
	local tree_loc = GetGroundPosition(Vector(keys.tree_x, keys.tree_y, 0), nil)
end

function GameEvents:OnItemPickedUp(keys)
	self:DebugPrint("An item has been picked up")

	local unit = EntIndexToHScript(keys.HeroEntityIndex)
	local item = EntIndexToHScript(keys.ItemEntityIndex)
	local player_id = keys.PlayerID
	local item_name = keys.itemname
end

function GameEvents:OnCursorPositionReceived(keys)
	local player_id = keys.PlayerID
	local position = Vector(keys.x, keys.y, keys.z)

	if not position then return end
end

function GameEvents:OnPlayerKilled(keys)
	self:DebugPrint("A hero was killed by an enemy")

	local killed_id = keys.PlayerID
	local hero_kill = keys.HeroKill
end
