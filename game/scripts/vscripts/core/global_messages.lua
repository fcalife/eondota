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