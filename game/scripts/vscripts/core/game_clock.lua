_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	self.next_rune_spawn = self.game_start_time
	self.next_lane_creep_spawn = self.game_start_time
	self.catapult_counter = 1

	self.next_archer_evaluation = self.game_start_time + COIN_EVALUATION_TIME
	self.archer_warning_60 = true
	self.archer_warning_15 = true
	self.archer_warning_3 = true
	self.archer_warning_2 = true
	self.archer_warning_1 = true
	self.archer_evaluating = true

	GameRules:GetGameModeEntity():SetFogOfWarDisabled(FOG_OF_WAR_DISABLED)

	NeutralCamps:StartSpawning()

	if TOWERS_ENABLED then Towers:Init() end

	NexusManager:SpawnNexus()
	Firelord:Init()

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

	if self.archer_warning_60 and current_time >= (self.next_archer_evaluation - 60) then
		self.archer_warning_60 = false

		GlobalMessages:Send("A building will be constructed in 60 seconds!")
	end

	if self.archer_warning_10 and current_time >= (self.next_archer_evaluation - 15) then
		self.archer_warning_15 = false

		GlobalMessages:Send("A building will be constructed in 15 seconds!")
	end

	if self.archer_warning_3 and current_time >= (self.next_archer_evaluation - 3) then
		self.archer_warning_3 = false

		GlobalMessages:Send("3...")
	end

	if self.archer_warning_2 and current_time >= (self.next_archer_evaluation - 2) then
		self.archer_warning_2 = false

		GlobalMessages:Send("2...")
	end

	if self.archer_warning_1 and current_time >= (self.next_archer_evaluation - 1) then
		self.archer_warning_1 = false

		GlobalMessages:Send("1...")
	end

	if self.archer_evaluating and current_time >= self.next_archer_evaluation then
		self.archer_evaluating = false

		ScoreManager:EvaluateWinner()
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