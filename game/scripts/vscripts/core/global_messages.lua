_G.GlobalMessages = GlobalMessages or {}

function GlobalMessages:Send(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message})
end

function GlobalMessages:SendAnimated(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message, animate = true})
end

function GlobalMessages:SendStartingWithTeamName(team, message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message, team = team})
end

function GlobalMessages:NotifyTeamWonRound(team)
	local message = " has won the round!"

	self:SendStartingWithTeamName(team, message)

	EmitGlobalSound("radiant.round")
end

function GlobalMessages:NotifyTeamDeliveredFlag(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has delivered a flag!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.flag" or "dire.flag")
end

function GlobalMessages:SendToAllButUnit(unit, message)
	for player_id = 0, 2 do
		if unit:GetPlayerOwnerID() ~= player_id then
			local player = PlayerResource:GetPlayer(player_id)

			if player then
				CustomGameEventManager:Send_ServerToPlayer(player, "new_message", {text = message, animate = true})
			end
		end
	end
end