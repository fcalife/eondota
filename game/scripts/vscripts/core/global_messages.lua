_G.GlobalMessages = GlobalMessages or {}

LOCALIZED_BOSS_NAMES = {
	boss_spawn_temple = "the Temple Guardian",
	boss_spawn_bear = "the Bear",
	boss_spawn_dragon = "the Dragon",
	boss_spawn_lava_golem = "the Lava Golem",
	boss_spawn_treant = "the Treant",
	boss_spawn_scorpion = "the Djinn",
	boss_spawn_revenant = "the Revenant",
	boss_spawn_spider = "the Spider"
}

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

function GlobalMessages:NotifyTeamKilledGolem(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." has recruited a Fire Golem!"

	self:Send(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.flag" or "dire.flag")
end

function GlobalMessages:NotifyTeamDeliveredEssence(team)
	local message = ((team == DOTA_TEAM_GOODGUYS) and "BLUE" or "RED").." delivered fire essence to the Fire Guardian!"

	self:SendAnimated(message)

	EmitGlobalSound((team == DOTA_TEAM_GOODGUYS) and "radiant.flag" or "dire.flag")
end

function GlobalMessages:NotifyTeamBribedFireGuardian(team)
	local message = "The Fire Guardian is bombarding "..((team == DOTA_TEAM_GOODGUYS) and "RED" or "BLUE").."'s Nexus!"

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

function GlobalMessages:NotifyBossUnderAttack(unit)
	local unit_name = unit:GetUnitName()

	local message = "A team has engaged "..LOCALIZED_BOSS_NAMES[unit_name].." in combat!"

	self:Send(message)

	EmitGlobalSound("dire.round")
end