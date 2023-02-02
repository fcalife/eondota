_G.RoundManager = RoundManager or {}

function RoundManager:Init()
	self.current_round = 1

	self.flags = {}
	self.flags[DOTA_TEAM_GOODGUYS] = 0
	self.flags[DOTA_TEAM_BADGUYS] = 0

	self.camera_dummies = {}
	self.camera_dummies[DOTA_TEAM_GOODGUYS] = CreateUnitByName("npc_flag_dummy", GetGroundPosition(Vector(-275, 0, 0), nil), true, nil, nil, DOTA_TEAM_NEUTRALS)
	self.camera_dummies[DOTA_TEAM_BADGUYS] = CreateUnitByName("npc_flag_dummy", GetGroundPosition(Vector(275, 0, 0), nil), true, nil, nil, DOTA_TEAM_NEUTRALS)

	self.camera_dummies[DOTA_TEAM_GOODGUYS]:AddNewModifier(self.camera_dummies[DOTA_TEAM_GOODGUYS], nil, "modifier_dummy_state", {})
	self.camera_dummies[DOTA_TEAM_BADGUYS]:AddNewModifier(self.camera_dummies[DOTA_TEAM_BADGUYS], nil, "modifier_dummy_state", {})
end

function RoundManager:InitializeRound()
	self.flags[DOTA_TEAM_GOODGUYS] = 0
	self.flags[DOTA_TEAM_BADGUYS] = 0

	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		hero:RespawnHero(false, false)
		hero:Stop()
		hero:SetHealth(hero:GetMaxHealth())
		hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = 10})
		hero:RemoveModifierByName("modifier_fountain_invulnerability")

		if CAMERA_LOCK then LockPlayerCameraOnTarget(hero, hero, false) end

		for i = 0, 10 do
			local ability = hero:GetAbilityByIndex(i)

			if ability then
				ability:EndCooldown()

				if self.current_round >= MIN_ROUND_FOR_ULTIMATES and ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
					ability:SetLevel(1)
				end
			end
		end

		local ultimate = hero:FindAbilityByName("ability_dodgeball_big_throw")
		if ultimate then ultimate:StartCooldown(35) end
	end

	--RuneSpawners:OnInitializeRound()
	--Flags:OnInitializeRound()
	Walls:OnRoundStart()

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
		end
	end)
end

function RoundManager:OnTeamDeliverFlag(team)
	self.flags[team] = self.flags[team] + 1 

	GlobalMessages:NotifyTeamDeliveredFlag(team)

	GoldRewards:GiveGoldToPlayersInTeam(team, FLAG_DELIVERY_GOLD, 0)

	self:CheckForRoundEnd()
end

function RoundManager:CheckForRoundEnd()
	if self.flags[DOTA_TEAM_GOODGUYS] + self.flags[DOTA_TEAM_BADGUYS] >= 3 then
		if self.flags[DOTA_TEAM_GOODGUYS] > self.flags[DOTA_TEAM_BADGUYS] then
			self:SetRoundWinner(DOTA_TEAM_GOODGUYS)
		else
			self:SetRoundWinner(DOTA_TEAM_BADGUYS)
		end
	end
end

function RoundManager:OnUnitKilled(killed_unit)
	if GameManager:GetGamePhase() ~= GAME_STATE_BATTLE then return end

	UnlockPlayerCamera(killed_unit)

	local all_heroes = HeroList:GetAllHeroes()

	local radiant_dead = true
	local dire_dead = true

	for _, hero in pairs(all_heroes) do
		if hero:IsRealHero() and hero:IsAlive() then
			if hero:GetTeam() == DOTA_TEAM_GOODGUYS then radiant_dead = false end
			if hero:GetTeam() == DOTA_TEAM_BADGUYS then dire_dead = false end
		end
	end

	if radiant_dead then
		self:SetRoundWinner(DOTA_TEAM_BADGUYS)
	elseif dire_dead then
		self:SetRoundWinner(DOTA_TEAM_GOODGUYS)
	end
end

function RoundManager:SetRoundWinner(team)
	Walls:OnRoundEnd()

	ScoreManager:OnTeamWinRound(team)

	GameManager:SetGamePhase(GAME_STATE_INIT)

	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = 3})
	end

	self.current_round = self.current_round + 1

	Timers:CreateTimer(3, function() self:InitializeRound() end)
end