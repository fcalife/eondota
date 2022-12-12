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
	local message = ((team == DOTA_TEAM_GOODGUYS) and "RED" or "BLUE").."'s towers just lost some energy!"

	self:Send(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.flag" or "dire.flag")
end

function GlobalMessages:NotifyTeamDeactivatedCharge(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").."'s towers are now disabled for 90 seconds!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.round" or "dire.round")
end

function GlobalMessages:NotifyTeamKilledSpider(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has killed the spider!"

	self:Send(message)

	message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").."'s towers are operational again!"

	self:Send(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.round" or "dire.round")
end