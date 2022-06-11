_G.GameEvents = GameEvents or {}

function GameEvents:OnGameStateChange()
	print("[GAME EVENT] The game state has changed")

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
	print("[GAME EVENT] New state: pregame")
end

function GameEvents:OnGameStart()
	print("[GAME EVENT] New state: game start")
end

function GameEvents:OnPostGameStart()
	print("[GAME EVENT] New state: postgame")
end

function GameEvents:OnPlayerConnect(keys)
	print("[GAME EVENT] A player has connected to the game")

	local player_id = keys.PlayerID
	local user_id = keys.userid

	table.deepprint(keys)
end

function GameEvents:OnPlayerDisconnect(keys)
	print("[GAME EVENT] A player has disconnected from the game")

	local player_id = keys.PlayerID
	local user_id = keys.userid
	local network_id = keys.networkid

	table.deepprint(keys)
end

function GameEvents:OnPlayerReconnect(keys)
	print("[GAME EVENT] A player has reconnected to the game")

	local player_id = keys.PlayerID
	local user_id = keys.userid

	table.deepprint(keys)
end

function GameEvents:OnPlayerPickHero(keys)
	print("[GAME EVENT] A player has picked their hero")

	local player = keys.player
	local hero_name = keys.hero

	table.deepprint(keys)
end

function GameEvents:OnPlayerNameChange(keys)
	print("[GAME EVENT] A player has changed their name")
	table.deepprint(keys)
end

function GameEvents:OnPlayerChat(keys)
	print("[GAME EVENT] A player has sent a chat message")

	local player_id = keys.playerid
	local user_id = keys.userid
	local allies_only = keys.teamonly and keys.teamonly == 1
	local text = keys.text

	table.deepprint(keys)
end

function GameEvents:OnUnitSpawn(keys)
	print("[GAME EVENT] A unit has spawned in the game")

	local unit = EntIndexToHScript(keys.entindex)

	table.deepprint(keys)
end

-- This event does not reference the illusion itself; it has to be caught on the OnUnitSpawn event
function GameEvents:OnIllusionSpawn(keys)
	print("[GAME EVENT] A illusion has spawned in the game")

	local source_unit = EntIndexToHScript(keys.original_entindex)

	table.deepprint(keys)
end

function GameEvents:OnEntityKilled(keys)
	print("[GAME EVENT] An entity has died somewhere")

	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local killed_unit = EntIndexToHScript(keys.entindex_killed)

	table.deepprint(keys)
end

function GameEvents:OnTreeCut(keys)
	print("[GAME EVENT] A tree has been cut")

	local player_id = keys.killerID
	local tree_loc = GetGroundPosition(Vector(keys.tree_x, keys.tree_y, 0), nil)

	table.deepprint(keys)
end

function GameEvents:OnItemPickedUp(keys)
	print("[GAME EVENT] An item has been picked up")

	local unit = EntIndexToHScript(keys.HeroEntityIndex)
	local item = EntIndexToHScript(keys.ItemEntityIndex)
	local player_id = keys.PlayerID
	local item_name = keys.itemname

	table.deepprint(keys)
end

function GameEvents:OnCursorPositionReceived(keys)
	local player_id = keys.PlayerID
	local position = Vector(keys.x, keys.y, keys.z)

	if not position then return end
end