_G.GlobalMessages = GlobalMessages or {}

function GlobalMessages:Send(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message})
end

function GlobalMessages:SendAnimated(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message, animate = true})
end

function GlobalMessages:NotifyTeamScored(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." scored a big goal!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.score" or "dire.score")
end

function GlobalMessages:NotifyTeamReachedCartGoal(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has delivered one of the carts!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.score" or "dire.score")
end

function GlobalMessages:NotifyDragon(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has slain the Kraken!"

	self:SendAnimated(message)

	EmitGlobalSound("dragons_activate")
end

function GlobalMessages:NotifySamurai(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE has slain Larry the Samurai!" or "RED has slain Jerry the Samurai!")

	self:SendAnimated(message)

	EmitGlobalSound("knights_activate")
end

function GlobalMessages:NotifyKnights(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has recruited the Ethereal Knights!"

	self:SendAnimated(message)

	EmitGlobalSound("knights_activate")
end

function GlobalMessages:NotifyTeamScoredGreed(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." transmuted a stone into +100 teamwide gold!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.score" or "dire.score")
end

function GlobalMessages:NotifyTeamScoredPower(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." scored a small goal!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.score" or "dire.score")
end