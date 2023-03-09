_G.RoundManager = RoundManager or {}

ROUND_DURATION = 40

function RoundManager:Init()
	self.current_round = 1

	self.start_points = {}

	local start_point_entities = Entities:FindAllByName("start_point")
	for _, start_point_entity in pairs(start_point_entities) do
		table.insert(self.start_points, start_point_entity:GetAbsOrigin())
	end

	self.random_abilities = {
		"slark_pounce",
		"rattletrap_hookshot",
		"earth_spirit_rolling_boulder",
		"primal_beast_onslaught",
		"mirana_leap",
		"sandking_burrowstrike",
		"faceless_void_time_walk"
	}
end

function RoundManager:OnGameStart()
	self.alive_teams = {}

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		self.alive_teams[hero:GetTeam()] = true
	end

	self:InitializeRound()
end

function RoundManager:InitializeRound()
	local all_heroes = HeroList:GetAllHeroes()
	local random_ability = self.random_abilities[RandomInt(1, #self.random_abilities)]
	local starting_points = table.shuffled(self.start_points)

	for _, hero in pairs(all_heroes) do
		if self.alive_teams[hero:GetTeam()] then
			hero:RespawnHero(false, false)
			hero:Stop()
			hero:SetHealth(hero:GetMaxHealth())
			hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = 3})
			hero:RemoveModifierByName("modifier_fountain_invulnerability")
			FindClearSpaceForUnit(hero, table.remove(starting_points), true)

			LockPlayerCameraOnTarget(hero, hero, (not CAMERA_LOCK))

			if RANDOM_ABILITIES then
				if (not SAME_RANDOM_ABILITY) then random_ability = self.random_abilities[RandomInt(1, #self.random_abilities)] end

				self:AddRandomAbilityForRound(hero, random_ability)
			end

			self:RefreshHeroAbilities(hero)

			local bonker = hero:FindAbilityByName("basic_cleave")
			if bonker then bonker:SetHidden(true) end
		end
	end

	local found_bonker = false

	while (not found_bonker) do
		local random_hero = all_heroes[RandomInt(1, #all_heroes)]
		local bonk_ability = random_hero:FindAbilityByName("basic_cleave")

		if self.alive_teams[random_hero:GetTeam()] and bonk_ability then
			bonk_ability:SetHidden(false)
			found_bonker = true
		end
	end

	local countdown = 3

	Timers:CreateTimer(0, function()
		if countdown > 0 then
			GlobalMessages:Send("Round "..self.current_round.." starts in "..countdown.."...")

			countdown = countdown - 1

			return 1
		else
			GlobalMessages:SendAnimated("Round "..self.current_round.." is starting!")

			GameManager:SetGamePhase(GAME_STATE_BATTLE)

			self.round_time_remaining = ROUND_DURATION + 1
			self:UpdateRoundTimer()

			self:Tick()
		end
	end)
end

function RoundManager:Tick()
	self.round_time_remaining = self.round_time_remaining - 1

	self:UpdateRoundTimer()

	if self.round_time_remaining > 0 then
		Timers:CreateTimer(1, function() self:Tick() end)
	else
		self:EndRound()
	end
end

function RoundManager:UpdateRoundTimer()
	CustomNetTables:SetTableValue("round_timer", "timer", {round_time_remaining = self.round_time_remaining})
end

function RoundManager:RefreshHeroAbilities(hero)
	for i = 0, 10 do
		local ability = hero:GetAbilityByIndex(i)

		if ability then ability:EndCooldown() end
	end
end

function RoundManager:AddRandomAbilityForRound(hero, random_ability)
	for _, ability_name in pairs(self.random_abilities) do
		hero:RemoveAbility(ability_name)
	end

	hero:RemoveAbility("primal_beast_onslaught_release")
	hero:RemoveAbility("faceless_void_time_walk_reverse")

	local new_ability = hero:AddAbility(random_ability)
	new_ability:SetLevel(1)

	if random_ability == "primal_beast_onslaught" then
		local aux_ability = hero:AddAbility("primal_beast_onslaught_release")
		aux_ability:SetLevel(1)
	elseif random_ability == "faceless_void_time_walk" then
		local aux_ability = hero:AddAbility("faceless_void_time_walk_reverse")
		aux_ability:SetLevel(1)
	end
end

function RoundManager:EndRound()
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = 3})

		local bonker = hero:FindAbilityByName("basic_cleave")

		if bonker and (not bonker:IsHidden()) then
			local blood_pfx = ParticleManager:CreateParticle("particles/tag/death_explode.vpcf", PATTACH_ABSORIGIN, hero)
			ParticleManager:SetParticleControl(blood_pfx, 0, hero:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(blood_pfx)

			hero:AddNewModifier(hero, bonker, "modifier_tagger_visual_death", {})

			hero:EmitSound("Sapper.Boom")
			hero:EmitSound("Death.Boom")

			hero:Kill(bonker, hero)

			self.alive_teams[hero:GetTeam()] = false

			AddFOWViewer(hero:GetTeam(), Vector(0, 0, 0), 3000, 10000, false)
			if CAMERA_LOCK then UnlockPlayerCamera(hero) end

			Timers:CreateTimer(3, function() hero:AddNoDraw() end)
		end
	end

	self:CheckForWinner()

	self.current_round = self.current_round + 1

	Timers:CreateTimer(3, function() self:InitializeRound() end)
end

function RoundManager:CheckForWinner()
	local winner = false

	for team, alive in pairs(self.alive_teams) do
		if alive and (not winner) then
			winner = team
		elseif alive and winner then
			return
		end
	end

	if winner then GameManager:EndGameWithWinner(winner) end
end

function RoundManager:OnUnitKilled(killed_unit)
	if GameManager:GetGamePhase() ~= GAME_STATE_BATTLE then return end

	local lives = killed_unit:FindModifierByName("modifier_lives")

	if lives and lives:GetStackCount() > 0 then
		lives:DecrementStackCount()

		if lives:GetStackCount() < 1 then lives:Destroy() end

		if killed_unit:IsRealHero() then
			killed_unit:RespawnHero(false, false)
			killed_unit:AddNewModifier(killed_unit, nil, "modifier_just_respawned", {duration = 3})
		end

		return nil
	end

	if CAMERA_LOCK then UnlockPlayerCamera(killed_unit) end

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