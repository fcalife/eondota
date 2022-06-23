_G.GlobalMessages = GlobalMessages or {}

function GlobalMessages:Send(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message})
end

function GlobalMessages:SendAnimated(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message, animate = true})
end

function GlobalMessages:NotifyTeamScored(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "Radiant" or "Dire").." delivered an Eon Stone!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.score" or "dire.score")
end