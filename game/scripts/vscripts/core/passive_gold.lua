_G.PassiveGold = PassiveGold or {}

GOLD_TICK_INTERVAL = 3
GOLD_PER_TICK = 10

PassiveGold.ticks_until_gold = GOLD_TICK_INTERVAL

function PassiveGold:Tick()
	self.ticks_until_gold = self.ticks_until_gold - 1

	if self.ticks_until_gold <= 0 then
		self:GiveGoldToAllPlayers(GOLD_PER_TICK)

		self.ticks_until_gold = GOLD_TICK_INTERVAL
	end
end

function PassiveGold:GiveGoldToAllPlayers(gold)
	local all_players = {}

	for id = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(id) then PlayerResource:ModifyGold(id, gold, false, DOTA_ModifyGold_GameTick) end
	end
end