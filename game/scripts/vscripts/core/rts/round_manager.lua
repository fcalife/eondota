_G.RoundManager = RoundManager or {}

function RoundManager:OnGameStart()
	self:Initialize()
end

function RoundManager:Initialize()
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		hero:RemoveModifierByName("modifier_boss_crawling")
		hero:RespawnHero(false, false)
		hero:RemoveModifierByName("modifier_fountain_invulnerability")
		hero:Stop()
		hero:SetHealth(hero:GetMaxHealth())
		hero:AddNewModifier(hero, nil, "modifier_stunned", {})
		hero:FindModifierByName("modifier_ressurrect_progress_counter"):SetStackCount(0)

		hero:RemoveModifierByName("modifier_eon_stone_carrier")
		hero:RemoveModifierByName("modifier_powerup_bossfight_shield")
		hero:RemoveModifierByName("modifier_powerup_bossfight_nuke_damage")
		hero:RemoveModifierByName("modifier_powerup_bossfight_movespeed")
		hero:RemoveModifierByName("modifier_powerup_bossfight_regen")
		hero:RemoveModifierByName("modifier_powerup_bossfight_ultimate_power")

		if FASTER_ABILITIES then
			hero:AddNewModifier(hero, nil, "modifier_faster_abilities", {})
		elseif FAST_ABILITIES then
			hero:AddNewModifier(hero, nil, "modifier_fast_abilities", {})
		end

		LockPlayerCameraOnTarget(hero, hero, (not CAMERA_LOCK))

		self:RefreshHeroAbilities(hero)

		if IsInToolsMode() then hero:AddItemByName("item_dev_blink") end
	end

	local countdown = (IsInToolsMode() and 1) or 5

	Timers:CreateTimer(0, function()
		if countdown > 0 then
			GlobalMessages:Send("Battle starts in "..countdown.."...")

			countdown = 0

			return (IsInToolsMode() and 1) or 5
		else
			GameManager:SetGamePhase(GAME_STATE_BATTLE)

			if GetMapName() == "boss_arena" then
				BossManager:StartBossBattle()
			else
				GameRules:SetHeroRespawnEnabled(true)
				GameRules:GetGameModeEntity():SetFixedRespawnTime(3)
				AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), 10000, 99999, false)
				AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), 10000, 99999, false)

				for _, hero in pairs(HeroList:GetAllHeroes()) do
					hero:RemoveModifierByName("modifier_stunned")
				end
			end
		end
	end)
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

function RoundManager:EndRound()
	GlobalMessages:Send("Defeated...")

	-- BossManager:Reset()
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(all_heroes) do
		--hero:AddNewModifier(hero, nil, "modifier_stunned", {duration = 3})
	end
end