_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	self.next_rune_spawn = self.game_start_time
	self.next_lane_creep_spawn = self.game_start_time
	self.next_coin_spawn = self.game_start_time + RandomInt(COIN_MIN_DELAY, COIN_MAX_DELAY)
	self.catapult_counter = 1

	GameRules:GetGameModeEntity():SetFogOfWarDisabled(FOG_OF_WAR_DISABLED)

	NeutralCamps:StartSpawning()

	if TOWERS_ENABLED then Towers:Init() end

	NexusManager:SpawnNexus()

	for _, hero in pairs(HeroList:GetAllHeroes()) do hero:RemoveModifierByName("modifier_stunned") end

	GameManager:SetGamePhase(GAME_STATE_BATTLE)

	self:Tick()
end

function GameClock:Tick()
	local current_time = GameRules:GetGameTime()

	GoldRewards:Tick()

	if current_time >= self.next_rune_spawn then
		RuneSpawners:OnInitializeRound()

		self.next_rune_spawn = self.next_rune_spawn + RUNE_RESPAWN_DELAY
	end

	if current_time >= self.next_lane_creep_spawn then
		local spawn_catapult = self.catapult_counter == WAVES_PER_CATAPULT

		LaneCreeps:SpawnWave(spawn_catapult)

		if spawn_catapult then self.catapult_counter = 1 else self.catapult_counter = self.catapult_counter + 1 end

		self.next_lane_creep_spawn = self.next_lane_creep_spawn + TIME_BETWEEN_LANE_CREEP_WAVES
	end

	if current_time >= self.next_coin_spawn then
		ArcherCoins:Spawn()

		self.next_coin_spawn = self.next_coin_spawn + RandomInt(COIN_MIN_DELAY, COIN_MAX_DELAY)
	end

	if GameManager:GetGamePhase() < GAME_STATE_END then
		Timers:CreateTimer(1, function()
			GameClock:Tick()
		end)
	end
end

function GameClock:GetActualGameTime()
	return (self.game_start_time and (GameRules:GetGameTime() - self.game_start_time)) or 0
end