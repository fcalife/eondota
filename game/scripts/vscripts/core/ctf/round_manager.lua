_G.RoundManager = RoundManager or {}

function RoundManager:Init()
	self.current_round = 1

	self.respawn_positions = {}

	for i = 1, 12 do
		table.insert(self.respawn_positions, RotatePosition(Vector(0, 0, 0), QAngle( 0, (i - 1) * 30, 0), Vector(0, 1075, 0)))
	end
end

function RoundManager:InitializeRound()
	local live_heroes = ScoreManager:GetAllRemainingHeroes()
	local random_respawns = self:GetRoundRespawnPositions()

	for _, hero in pairs(live_heroes) do
		self:RespawnAndPrepareHero(hero, table.remove(random_respawns))
		hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = ROUND_PREPARATION_TIME})

		LockPlayerCameraOnTarget(hero, hero, (not CAMERA_LOCK))

		for i = 0, 10 do
			local ability = hero:GetAbilityByIndex(i)

			if ability then
				ability:EndCooldown()
			end
		end
	end

	if (not SMASH_BROS_MODE) then Walls:OnRoundStart() end

	GlobalMessages:Send("Round "..self.current_round.." will start in 10 seconds!")

	local countdown = 3

	Timers:CreateTimer(7, function()
		if countdown > 0 then
			GlobalMessages:Send("Round "..self.current_round.." starts in "..countdown.."...")

			countdown = countdown - 1

			return 1
		else
			GlobalMessages:SendAnimated("Round "..self.current_round.." is starting!")

			GameManager:SetGamePhase(GAME_STATE_BATTLE)
			PowerupManager:OnRoundStart()
		end
	end)
end

function RoundManager:RespawnAndPrepareHero(hero, respawn_point)
	hero:RespawnHero(false, false)
	hero:RemoveModifierByName("modifier_fountain_invulnerability")
	hero:FadeGesture(ACT_DOTA_FLAIL)
	hero:Stop()
	hero:SetHealth(hero:GetMaxHealth())

	FindClearSpaceForUnit(hero, respawn_point, true)

	LockPlayerCameraOnTarget(hero, hero, (not CAMERA_LOCK))

	for i = 0, 10 do
		local ability = hero:GetAbilityByIndex(i)

		if ability then
			ability:EndCooldown()
		end
	end
end

function RoundManager:GetRoundRespawnPositions()
	local remaining_players = ScoreManager:GetRemainingPlayerCount()
	local respawn_distance = 12 / remaining_players
	local respawn_offset = RandomInt(1, respawn_distance) - 1
	local round_spawn_positions = {}

	for i = 1, remaining_players do
		table.insert(round_spawn_positions, self.respawn_positions[1 + respawn_distance * (i - 1) + respawn_offset])
	end

	return table.shuffled(round_spawn_positions)
end

function RoundManager:OnUnitKilled(killed_unit)
	if GameManager:GetGamePhase() ~= GAME_STATE_BATTLE then return end

	UnlockPlayerCamera(killed_unit)

	local killed_team = killed_unit:GetTeam()

	ScoreManager:OnTeamLoseRound(killed_team)

	if SMASH_BROS_MODE then
		if ScoreManager:GetRemainingLives(killed_team) > 0 then
			self:RespawnAndPrepareHero(killed_unit, Vector(0, 0, 0))

			killed_unit:AddNewModifier(killed_unit, nil, "modifier_respawn_grace_period", {duration = SMASH_BROS_GRACE_PERIOD})
		else
			ScoreManager:CheckForWinner()
		end
	else
		local all_heroes = HeroList:GetAllHeroes()
		local alive_heroes = {}

		for _, hero in pairs(all_heroes) do
			if hero:IsRealHero() and hero:IsAlive() then
				table.insert(alive_heroes, hero)
			end
		end

		if alive_heroes[1] and #alive_heroes == 1 then
			self:SetRoundWinner(alive_heroes[1]:GetTeam())
		end
	end
end

function RoundManager:SetRoundWinner(team)
	Walls:OnRoundEnd()
	PowerupManager:OnRoundEnd()

	GlobalMessages:NotifyTeamWonRound(team)

	GameManager:SetGamePhase(GAME_STATE_INIT)

	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = 3})
	end

	self.current_round = self.current_round + 1

	Timers:CreateTimer(3, function() self:InitializeRound() end)
end