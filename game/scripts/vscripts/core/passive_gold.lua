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