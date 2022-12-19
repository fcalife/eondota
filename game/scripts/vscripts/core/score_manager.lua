_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.score = {}

	self:UpdateEssenceScoreboard()
end

function ScoreManager:UpdateEssenceScoreboard()
	for player_id, score in pairs(self.score) do
		CustomNetTables:SetTableValue("coins", "player"..player_id, {coins = score})
	end
end

function ScoreManager:AddEssence(hero, amount)
	local player_id = hero:GetPlayerID()

	if player_id and PlayerResource:IsValidPlayerID(player_id) then
		self.score[player_id] = (self.score[player_id] or 0) + amount
	end

	self:UpdateEssenceScoreboard()
end

function ScoreManager:TrySpendEssence(player_id, amount)
	if self.score[player_id] and self.score[player_id] >= amount then
		self.score[player_id] = self.score[player_id] - amount

		self:UpdateEssenceScoreboard()

		return true
	else
		local player = PlayerResource:GetPlayer(player_id)

		if player then CustomGameEventManager:Send_ServerToPlayer(player, "display_custom_error", {message = "Not enough coins!"}) end

		return false
	end
end

function ScoreManager:EvaluateWinner()
	if self.score[DOTA_TEAM_GOODGUYS] > self.score[DOTA_TEAM_BADGUYS] then
		Firelord:SummonNeutralsFor(DOTA_TEAM_GOODGUYS)

		self.score[DOTA_TEAM_GOODGUYS] = 0
		self.score[DOTA_TEAM_BADGUYS] = 0

		self:UpdateEssenceScoreboard()

		GameClock.next_archer_evaluation = GameRules:GetGameTime() + COIN_EVALUATION_TIME
		GameClock.archer_warning_60 = true
		GameClock.archer_warning_30 = true
		GameClock.archer_warning_10 = true
		GameClock.archer_warning_3 = true
		GameClock.archer_warning_2 = true
		GameClock.archer_warning_1 = true
		GameClock.archer_evaluating = true

	elseif self.score[DOTA_TEAM_GOODGUYS] < self.score[DOTA_TEAM_BADGUYS] then
		Firelord:SummonNeutralsFor(DOTA_TEAM_BADGUYS)

		self.score[DOTA_TEAM_GOODGUYS] = 0
		self.score[DOTA_TEAM_BADGUYS] = 0

		self:UpdateEssenceScoreboard()

		GameClock.next_archer_evaluation = GameRules:GetGameTime() + COIN_EVALUATION_TIME
		GameClock.archer_warning_60 = true
		GameClock.archer_warning_30 = true
		GameClock.archer_warning_10 = true
		GameClock.archer_warning_3 = true
		GameClock.archer_warning_2 = true
		GameClock.archer_warning_1 = true
		GameClock.archer_evaluating = true

	else
		Timers:CreateTimer(1.0, function() ScoreManager:EvaluateWinner() end)
	end
end