_G.RoundManager = RoundManager or {}

ROUND_DURATION = 60

function RoundManager:Init()
	self.current_round = 1

	--self.start_points = {}

	--local start_point_entities = Entities:FindAllByName("start_point")
	--for _, start_point_entity in pairs(start_point_entities) do
	--	table.insert(self.start_points, start_point_entity:GetAbsOrigin())
	--end

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
	self.score = {}
	self.alive_teams = {}

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		self.alive_teams[hero:GetTeam()] = true
		self.score[hero:GetTeam()] = 0
	end

	self:InitializeRound()
end

function RoundManager:InitializeRound()
	local all_heroes = HeroList:GetAllHeroes()
	local random_ability = self.random_abilities[RandomInt(1, #self.random_abilities)]

	for _, hero in pairs(all_heroes) do
		local team = hero:GetTeam()

		if self.alive_teams[team] then
			hero:RespawnHero(false, false)
			hero:Stop()
			hero:SetHealth(hero:GetMaxHealth())
			hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = 3})
			hero:RemoveModifierByName("modifier_fountain_invulnerability")

			if FASTER_ABILITIES then
				hero:AddNewModifier(hero, nil, "modifier_faster_abilities", {})
			elseif FAST_ABILITIES then
				hero:AddNewModifier(hero, nil, "modifier_fast_abilities", {})
			end

			LockPlayerCameraOnTarget(hero, hero, (not CAMERA_LOCK))

			if RANDOM_ABILITIES then
				if (not SAME_RANDOM_ABILITY) then random_ability = self.random_abilities[RandomInt(1, #self.random_abilities)] end

				self:AddRandomAbilityForRound(hero, random_ability)
			end

			self:RefreshHeroAbilities(hero)
		end
	end

	PaintableGrids:OnRoundStart()

	self:UpdateScoreboard()

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

function RoundManager:UpdateScoreboard()
	self.score = PaintableGrids:GetTeamScores()

	CustomNetTables:SetTableValue("score", "scoreboard", self.score)
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
	end

	local round_scores = PaintableGrids:GetTeamScores()
	local lowest_score = 999

	for _, score in pairs(round_scores) do
		if score < lowest_score then lowest_score = score end
	end

	for team, score in pairs(round_scores) do
		if score <= lowest_score then self:EliminateTeam(team) end
	end

	self.current_round = self.current_round + 1

	Timers:CreateTimer(3, function() self:InitializeRound() end)
end

function RoundManager:EliminateTeam(team)
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		if hero:GetTeam() == team then
			local blood_pfx = ParticleManager:CreateParticle("particles/tag/death_explode.vpcf", PATTACH_ABSORIGIN, hero)
			ParticleManager:SetParticleControl(blood_pfx, 0, hero:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(blood_pfx)

			hero:AddNewModifier(hero, nil, "modifier_tagger_visual_death", {})

			hero:EmitSound("Sapper.Boom")
			hero:EmitSound("Death.Boom")

			hero:Kill(nil, hero)

			AddFOWViewer(hero:GetTeam(), Vector(0, 0, 0), 3000, 10000, false)
			if CAMERA_LOCK then UnlockPlayerCamera(hero) end

			Timers:CreateTimer(3, function()
				hero:SetAbsOrigin(Vector(2000, 2000, 128))
				hero:AddNoDraw()
			end)
		end
	end

	self.alive_teams[team] = false

	self:CheckForWinner()
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