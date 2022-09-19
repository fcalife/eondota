_G.GameManager = GameManager or {}

function GameManager:Init()
	self:SetGamePhase(GAME_STATE_INIT)

	self.eon_stone_spawn_points = {}

	for _, spawn_point in pairs(Entities:FindAllByName("eon_stone_spawn")) do
		table.insert(self.eon_stone_spawn_points, spawn_point:GetAbsOrigin())
	end

	-- self.match_spawn_points = {}
	-- local shuffled_spawn_points = table.shuffle(self.eon_stone_spawn_points)

	-- while #self.match_spawn_points < 10 do
	-- 	if #shuffled_spawn_points > 0 then
	-- 		table.insert(self.match_spawn_points, table.remove(shuffled_spawn_points))
	-- 	else
	-- 		shuffled_spawn_points = table.shuffle(self.eon_stone_spawn_points)
	-- 	end
	-- end

	--self.spawned_stones = {}
end

function GameManager:SetGamePhase(phase)
	self.game_state = phase
end

function GameManager:GetGamePhase()
	return self.game_state or nil
end

function GameManager:StartEonStoneCountdown()
	local location = self.eon_stone_spawn_points[1]

	if not location then return end

	EmitGlobalSound("stone.warning")

	GlobalMessages:Send("An Eon Stone will spawn in "..EON_STONE_COUNTDOWN_TIME.." seconds!")

	local minimap_dummy = CreateUnitByName("npc_stone_dummy", location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_dummy_state", {})
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_not_on_minimap", {})

	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		AddFOWViewer(team, location, EON_STONE_VISION_RADIUS, EON_STONE_COUNTDOWN_TIME, false)
		MinimapEvent(team, minimap_dummy, location.x, location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, EON_STONE_COUNTDOWN_TIME)
	end

	local warning_pfx = ParticleManager:CreateParticle("particles/econ/events/fall_2021/teleport_end_fall_2021_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(warning_pfx, 0, location)
	ParticleManager:SetParticleControl(warning_pfx, 1, location)

	Timers:CreateTimer(3, function() EmitGlobalSound("stone.countdown") end)
	Timers:CreateTimer(5, function() GlobalMessages:Send("An Eon Stone will spawn in 10 seconds!") end)
	Timers:CreateTimer(10, function() GlobalMessages:Send("An Eon Stone will spawn in 5 seconds!") end)

	Timers:CreateTimer(15, function()
		ParticleManager:DestroyParticle(warning_pfx, false)
		ParticleManager:ReleaseParticleIndex(warning_pfx)

		StopGlobalSound("stone.countdown")
		EmitGlobalSound("stone.spawn")

		minimap_dummy:Destroy()

		self:SpawnEonStone(location)
	end)
end

function GameManager:SpawnEonStone(location)
	local container = CreateItemOnPositionForLaunch(location, CreateItem("item_eon_stone", nil, nil))
	local item = container:GetContainedItem()

	self.stone_data = {}

	self.stone_data.location = location

	self.stone_data.dummy = CreateUnitByName("npc_stone_dummy", location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	self.stone_data.dummy:AddNewModifier(self.stone_data.dummy, nil, "modifier_dummy_state", {})

	self.stone_data.fow_viewers = {}
	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		table.insert(self.stone_data.fow_viewers, AddFOWViewer(team, location, EON_STONE_VISION_RADIUS, GAME_MAX_DURATION, false))
	end

	local distance = (location - self.eon_stone_spawn_points[1]):Length2D()
	if distance > 200 then
		self.stone_pfx = ParticleManager:CreateParticle("particles/eon_timer.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(self.stone_pfx, 0, location + Vector(0, 0, 50))
		ParticleManager:SetParticleControl(self.stone_pfx, 1, Vector(350, 1/EON_STONE_TIME_ON_GROUND, 0))
		ParticleManager:SetParticleControl(self.stone_pfx, 15, Vector(255, 255, 255))
		ParticleManager:SetParticleControl(self.stone_pfx, 16, Vector(1, 0, 0))

		Timers:CreateTimer(EON_STONE_TIME_ON_GROUND, function()
			if container and (not container:IsNull()) then
				container:Destroy()
				GameManager:OnEonStonePickedUp(location)

				self:SpawnEonStone(self.eon_stone_spawn_points[1])
			end
		end)
	end
end

function GameManager:OnEonStonePickedUp(location)
	self.stone_data.dummy:Destroy()

	if self.stone_pfx then
		ParticleManager:DestroyParticle(self.stone_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.stone_pfx)
	end

	for _, viewer in pairs(self.stone_data.fow_viewers) do
		RemoveFOWViewer(DOTA_TEAM_GOODGUYS, viewer)
		RemoveFOWViewer(DOTA_TEAM_BADGUYS, viewer)
	end

	for player_id = 0, 24 do
		if PlayerResource:IsValidPlayer(player_id) then
			local hero = PlayerResource:GetSelectedHeroEntity(player_id)
			if hero then hero:RemoveModifierByName("modifier_item_eon_stone_cooldown") end
		end
	end
end


function GameManager:InitializeHero(hero)
	hero:AddNewModifier(hero, nil, "modifier_hero_base_state", {})

	for i = 1, 59 do
		hero:AddItemByName("item_tpscroll")
	end

	for i = 0, 10 do
		if hero:GetAbilityByIndex(i) then
			if hero:GetAbilityByIndex(i):GetAbilityType() == ABILITY_TYPE_BASIC then
				hero:GetAbilityByIndex(i):SetLevel(1)
			end
		end
	end

	for i = 1, 2 do
		hero:HeroLevelUp(false)
	end

	hero:SetAbilityPoints(0)

	if IsInToolsMode() then
		hero:ModifyGold(50000, true, DOTA_ModifyGold_GameTick)
		hero:AddItemByName("item_dev_blink")
		hero:AddItemByName("item_dev_dagon")

		for i = 1, 30 do hero:HeroLevelUp(false) end

		for i = 0, 30 do
			if hero:GetAbilityByIndex(i) then
				hero:GetAbilityByIndex(i):SetLevel(hero:GetAbilityByIndex(i):GetMaxLevel())
			end
		end
	end
end

function GameManager:EndGameWithWinner(team)
	self:SetGamePhase(GAME_STATE_END)

	GameRules:SetGameWinner(team)
end

function GameManager:StartGameEndCountdown()
	self:SetGamePhase(GAME_STATE_END_TIMER)

	EmitGlobalSound("game_end.timer_start")
	GlobalMessages:Send("The game will end in 30 seconds!")

	Timers:CreateTimer(10, function() GlobalMessages:Send("The game will end in 20 seconds!") end)
	Timers:CreateTimer(15, function() GlobalMessages:Send("The game will end in 15 seconds!") end)

	Timers:CreateTimer(20, function()
		EmitGlobalSound("game_end.10")
		GlobalMessages:Send("The game will end in 10 seconds!")
	end)

	Timers:CreateTimer(21, function() EmitGlobalSound("game_end.09") end)
	Timers:CreateTimer(22, function() EmitGlobalSound("game_end.08") end)
	Timers:CreateTimer(23, function() EmitGlobalSound("game_end.07") end)
	Timers:CreateTimer(24, function() EmitGlobalSound("game_end.06") end)

	Timers:CreateTimer(25, function()
		EmitGlobalSound("game_end.05")
		GlobalMessages:Send("5!")
	end)

	Timers:CreateTimer(26, function() EmitGlobalSound("game_end.04") end)
	Timers:CreateTimer(27, function()
		EmitGlobalSound("game_end.03")
		GlobalMessages:Send("3!")
	end)
	Timers:CreateTimer(28, function()
		EmitGlobalSound("game_end.02")
		GlobalMessages:Send("2!")
	end)
	Timers:CreateTimer(29, function()
		EmitGlobalSound("game_end.01")
		GlobalMessages:Send("1!")
	end)
end