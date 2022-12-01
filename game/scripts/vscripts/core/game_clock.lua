_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	self.next_rune_spawn = self.game_start_time
	self.next_creep_spawn = self.game_start_time

	GameRules:GetGameModeEntity():SetFogOfWarDisabled(FOG_OF_WAR_DISABLED)

	NeutralCamps:StartSpawning()

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

	if current_time >= self.next_creep_spawn then
		LaneCreeps:SpawnWave()

		self.next_creep_spawn = self.next_creep_spawn + LANE_CREEP_RESPAWN_DELAY
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