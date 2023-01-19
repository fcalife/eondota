_G.GameClock = GameClock or {}

function GameClock:Start()
	self.game_start_time = GameRules:GetGameTime()

	--GameRules:GetGameModeEntity():SetFogOfWarDisabled(FOG_OF_WAR_DISABLED)

	RespawnManager:RespawnAllHeroes()
	NeutralCamps:StartSpawning()
	RespawnManager:DestroyUnusedOutposts()

	--if TOWERS_ENABLED then Towers:Init() end

	--NexusManager:SpawnNexus()
	--Firelord:Init()

	Timers:CreateTimer(5, function()
		for _, hero in pairs(HeroList:GetAllHeroes()) do hero:RemoveModifierByName("modifier_stunned") end
	end)

	GameManager:SetGamePhase(GAME_STATE_BATTLE)

	self:Tick()
end

function GameClock:Tick()
	local current_time = GameRules:GetGameTime()

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:IsAlive() then EnemyManager:ActivateSpawnersAround(hero) end
	end

	--GoldRewards:Tick()

	-- if current_time >= self.next_rune_spawn then
	-- 	RuneSpawners:OnInitializeRound()

	-- 	self.next_rune_spawn = self.next_rune_spawn + RUNE_RESPAWN_DELAY
	-- end

	-- if current_time >= self.next_creep_spawn then
	-- 	NeutralCamps:SpawnFireCamp()

	-- 	self.next_creep_spawn = self.next_creep_spawn + FIRE_SPIRIT_SPAWN_DELAY
	-- end

	-- if CHARGE_TOWERS_ENABLED and current_time >= self.next_essence_spawn then
	-- 	RuneSpawners:SpawnEssence()

	-- 	self.next_essence_spawn = self.next_essence_spawn + CHARGE_TOWER_ORB_SPAWN_INTERVAL
	-- end

	-- if (not self.creep_upgrade_announced) and current_time >= self.creep_upgrade_time then
	-- 	GlobalMessages:Send("The Fire Spirits have been upgraded!")

	-- 	EmitGlobalSound("stone.warning")

	-- 	self.creep_upgrade_announced = true
	-- end

	if GameManager:GetGamePhase() < GAME_STATE_END then
		Timers:CreateTimer(1, function()
			GameClock:Tick()
		end)
	end
end

function GameClock:GetActualGameTime()
	return (self.game_start_time and (GameRules:GetGameTime() - self.game_start_time)) or 0
end