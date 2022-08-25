_G.PassiveGold = PassiveGold or {}

GOLD_TICK_INTERVAL = 3
GOLD_PER_TICK = 10
EXP_PER_TICK = 20

PassiveGold.ticks_until_gold = GOLD_TICK_INTERVAL

function PassiveGold:Tick()
	self.ticks_until_gold = self.ticks_until_gold - 1

	if self.ticks_until_gold <= 0 then
		self:GiveGoldToAllPlayers(GOLD_PER_TICK, EXP_PER_TICK)

		self.ticks_until_gold = GOLD_TICK_INTERVAL
	end
end

function PassiveGold:GiveGoldToAllPlayers(gold, exp)
	for id = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(id) then
			local hero = PlayerResource:GetSelectedHeroEntity(id)

			hero:ModifyGold(gold, false, DOTA_ModifyGold_BountyRune)
			hero:AddExperience(exp, DOTA_ModifyXP_Outpost, false, true)
		end
	end
end

function PassiveGold:GiveGoldToPlayersInTeam(team, gold, exp)
	for id = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(id) and PlayerResource:GetTeam(id) == team then
			local hero = PlayerResource:GetSelectedHeroEntity(id)

			SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, hero, gold, nil)
			hero:ModifyGold(gold, false, DOTA_ModifyGold_GameTick)
			hero:AddExperience(exp, DOTA_ModifyXP_Outpost, false, true)
		end
	end
end

function PassiveGold:GiveGoldFromPickup(unit, gold)
	local allies = FindUnitsInRadius(
		unit:GetTeam(),
		unit:GetAbsOrigin(),
		nil,
		GOLD_SHARING_RADIUS,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		FIND_ANY_ORDER,
		false
	)

	local gold_share = gold / (1 + #allies)

	for _, ally in pairs(allies) do
		local ally_bounty = gold_share

		if ally == unit then ally_bounty = gold_share * 2 end

		ally:ModifyGold(ally_bounty, false, DOTA_ModifyGold_CreepKill)

		for _, nearby_ally in pairs(allies) do
			local player = nearby_ally:GetPlayerOwner()

			if player then SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, ally, ally_bounty, nil) end
		end
	end
end