_G.GlobalMessages = GlobalMessages or {}

function GlobalMessages:Send(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message})
end

function GlobalMessages:SendAnimated(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message, animate = true})
end

function GlobalMessages:NotifyTeamScored(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." delivered an Eon Stone!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.score" or "dire.score")
end

function GlobalMessages:NotifyDragon(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has slain the Dragon!"

	self:SendAnimated(message)

	EmitGlobalSound("dragons_activate")
end

function GlobalMessages:NotifyKnights(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has recruited the Ethereal Knights!"

	self:SendAnimated(message)

	EmitGlobalSound("knights_activate")
end