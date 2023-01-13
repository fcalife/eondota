-- Reset listeners on reload
for _, listener_id in ipairs(REGISTERED_CUSTOM_EVENT_LISTENERS or {}) do
	CustomGameEventManager:UnregisterListener(listener_id)
end

for _, listener_id in ipairs(REGISTERED_GAME_EVENT_LISTENERS or {}) do
	StopListeningToGameEvent(listener_id)
end

REGISTERED_CUSTOM_EVENT_LISTENERS = {}
REGISTERED_GAME_EVENT_LISTENERS = {}

function RegisterCustomEventListener(event_name, callback)
	local listener_id = CustomGameEventManager:RegisterListener(event_name, function(_, args)
		callback(args)
	end)

	table.insert(REGISTERED_CUSTOM_EVENT_LISTENERS, listener_id)
end

function RegisterGameEventListener(event_name, callback)
	local listener_id = ListenToGameEvent(event_name, callback, nil)
	table.insert(REGISTERED_GAME_EVENT_LISTENERS, listener_id)
end

-- Displays a custom error, with localization, on the usual spot for ability cast errors
function DisplayCustomError(player_id, message)
	local player = PlayerResource:GetPlayer(player_id)

	if player then CustomGameEventManager:Send_ServerToPlayer(player, "display_custom_error", {message = message}) end
end

-- Rounds a float towards the next integer
-- Uses round away from zero for halfway points
function RoundFloat(x)
	if x >= 0 then
		return math.floor(x + 0.5)
	else
		return math.ceil(x - 0.5)
	end
end

function CenterPlayerCameraOnHero(hero, release)
	local player = hero:GetPlayerOwner()
	if player then
		PlayerResource:SetCameraTarget(player:GetPlayerID(), hero)

		if release then
			Timers:CreateTimer(0.01, function() PlayerResource:SetCameraTarget(player:GetPlayerID(), nil) end)
		end
	end
end

function LockPlayerCameraOnTarget(hero, target, release)
	local player = hero:GetPlayerOwner()
	if player then
		PlayerResource:SetCameraTarget(player:GetPlayerID(), target)

		if release then
			Timers:CreateTimer(0.01, function() PlayerResource:SetCameraTarget(player:GetPlayerID(), nil) end)
		end
	end
end