_G.GlobalMessages = GlobalMessages or {}

function GlobalMessages:Send(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message})
end

function GlobalMessages:SendAnimated(message)
	CustomGameEventManager:Send_ServerToAllClients("new_message", {text = message, animate = true})
end

function GlobalMessages:NotifyTeamWonRound(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has won the round!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.round" or "dire.round")
end

function GlobalMessages:NotifyTeamDeliveredFlag(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has delivered a flag!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.flag" or "dire.flag")
end

function GlobalMessages:NotifyTeamGotCharge(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." is charging up their towers!"

	self:Send(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.flag" or "dire.flag")
end

function GlobalMessages:NotifyTeamActivatedCharge(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").."'s towers are now active for 2 minutes!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.round" or "dire.round")
end

function GlobalMessages:NotifyTeamKilledSpider(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has killed the spider!"

	self:Send(message)

	message = ((team == DOTA_TEAM_BADGUYS) and "BLUE" or "RED").."'s towers lose some charge!"

	self:Send(message)

	EmitGlobalSound((team == DOTA_TEAM_BADGUYS) and "radiant.round" or "dire.round")
end