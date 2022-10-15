_G.ScoreManager = ScoreManager or {}

ENEMY_TEAM = {}
ENEMY_TEAM[DOTA_TEAM_GOODGUYS] = DOTA_TEAM_BADGUYS
ENEMY_TEAM[DOTA_TEAM_BADGUYS] = DOTA_TEAM_GOODGUYS

function ScoreManager:Init()
	self.nexus = {}

	self.eon_points = {}
	self.eon_points[DOTA_TEAM_GOODGUYS] = IS_LANE_MAP and 100 or 0
	self.eon_points[DOTA_TEAM_BADGUYS] = IS_LANE_MAP and 100 or 0

	self.small_goal_score = {}
	self.small_goal_score[DOTA_TEAM_GOODGUYS] = 0
	self.small_goal_score[DOTA_TEAM_BADGUYS] = 0

	self:UpdateScores()
end

function ScoreManager:OnNexusHealth(team, health)
	if IS_LANE_MAP and health < self.eon_points[team] then
		self.eon_points[team] = health
		self:UpdateScores()
	end
end

function ScoreManager:Score(team, points)
	if IS_LANE_MAP then
		if self.nexus[team] and self.nexus[ENEMY_TEAM[team]] then
			local damage = self.nexus[ENEMY_TEAM[team]]:GetMaxHealth() * EON_STONE_NEXUS_DAMAGE
			ApplyDamage({attacker = self.nexus[team], victim = self.nexus[ENEMY_TEAM[team]], damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})

			self:Laser(TEAM_GOALS[team].location, self.nexus[ENEMY_TEAM[team]]:GetAbsOrigin())

			self.eon_points[ENEMY_TEAM[team]] = math.ceil(100 * self.nexus[ENEMY_TEAM[team]]:GetHealth() / self.nexus[ENEMY_TEAM[team]]:GetMaxHealth())
		end
	else
		self.eon_points[team] = math.min(self.eon_points[team] + points, GAME_TARGET_SCORE)
	end

	self:UpdateScores()

	GlobalMessages:NotifyTeamScored(team)

	PassiveGold:GiveGoldToPlayersInTeam(team, EON_STONE_GOLD_REWARD, 0)

	Timers:CreateTimer(math.max(0, EON_STONE_RESPAWN_TIME - EON_STONE_COUNTDOWN_TIME), function()
		GameManager:StartEonStoneCountdown()
	end)
end

function ScoreManager:ScoreSecondary(team)
	-- if IS_LANE_MAP then
	-- 	if self.nexus[team] and self.nexus[ENEMY_TEAM[team]] then
	-- 		local damage = self.nexus[ENEMY_TEAM[team]]:GetMaxHealth() * SECONDARY_NEXUS_DAMAGE
	-- 		ApplyDamage({attacker = self.nexus[team], victim = self.nexus[ENEMY_TEAM[team]], damage = damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})

	-- 		self.eon_points[ENEMY_TEAM[team]] = math.ceil(100 * self.nexus[ENEMY_TEAM[team]]:GetHealth() / self.nexus[ENEMY_TEAM[team]]:GetMaxHealth())
	-- 	end
	-- else
	-- 	self.eon_points[team] = math.min(self.eon_points[team] + points, GAME_TARGET_SCORE)
	-- end

	-- self:UpdateScores()

	--PassiveGold:GiveGoldToPlayersInTeam(team, SECONDARY_CAPTURE_GOLD, 0)

	-- local enemy_tower = Towers:GetTeamTower(ENEMY_TEAM[team])
	-- if self.nexus[team] and enemy_tower.unit and enemy_tower.unit:IsAlive() then
	-- 	ApplyDamage({
	-- 		attacker = self.nexus[team],
	-- 		victim = enemy_tower.unit,
	-- 		damage = enemy_tower.unit:GetMaxHealth() * SECONDARY_LANE_TOWER_DAMAGE,
	-- 		damage_type = DAMAGE_TYPE_PURE,
	-- 		damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
	-- 	})
	-- end

	-- local enemy_golems = PatrolGolems:GetTeamGolems(ENEMY_TEAM[team])
	-- for _, enemy_golem in pairs(enemy_golems) do
	-- 	if enemy_golem.golem then enemy_golem.golem:AddNewModifier(enemy_golem.golem, nil, "modifier_stunned", {duration = SECONDARY_GOLEM_DISABLE_DURATION}) end
	-- end

	Timers:CreateTimer(math.max(0, SECONDARY_CAPTURE_SPAWN_TIME - EON_STONE_COUNTDOWN_TIME), function()
		GameManager:StartEonStoneCountdown()
	end)
end

function ScoreManager:UpdateScores()
	local game_mode_entity = GameRules:GetGameModeEntity()

	game_mode_entity:SetCustomRadiantScore(self.eon_points[DOTA_TEAM_GOODGUYS])
	game_mode_entity:SetCustomDireScore(self.eon_points[DOTA_TEAM_BADGUYS])

	if (not IS_LANE_MAP) then self:CheckForPointWin() end
end

function ScoreManager:CheckForPointWin()
	if self:GetTotalScore(DOTA_TEAM_GOODGUYS) >= GAME_TARGET_SCORE then
		GameManager:EndGameWithWinner(DOTA_TEAM_GOODGUYS)
	end
	if self:GetTotalScore(DOTA_TEAM_BADGUYS) >= GAME_TARGET_SCORE then
		GameManager:EndGameWithWinner(DOTA_TEAM_BADGUYS)
	end
end

function ScoreManager:GetHandicap(team)
	return math.max(0, self:GetTotalScore(ENEMY_TEAM[team]) - self:GetTotalScore(team))
end

function ScoreManager:GetTotalScore(team)
	return (self.eon_points and self.eon_points[team] or 0)
end

function ScoreManager:SmallGoalAchieved(team, location)
	self.small_goal_score[team] = self.small_goal_score[team] + 1

	if self.small_goal_score[team] == 1 then
		local enemy_tower = Towers.jungle_towers[ENEMY_TEAM[team]].unit
		local shield_modifier = enemy_tower:FindModifierByName("modifier_jungle_tower_shield")
		local damage = 1.0

		if shield_modifier then
			local stacks = shield_modifier:GetStackCount()
			damage = (250 - stacks) / 250
			
			enemy_tower:RemoveModifierByName("modifier_jungle_tower_shield")
		end

		ApplyDamage({
			victim = enemy_tower,
			attacker = enemy_tower,
			damage = damage * enemy_tower:GetMaxHealth(),
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
		})

		self:Laser(location, enemy_tower:GetAbsOrigin())
	elseif self.small_goal_score[team] == 2 then
		Walls.walls[team]:Demolish()

		self:Laser(location, Walls.walls[team].start_position)
		self:Laser(location, Walls.walls[team].end_position)
	elseif self.small_goal_score[team] == 3 then
		SpeedLane(team)

		self:Laser(location, GameManager.eon_stone_spawn_points[1])
		self:Laser(location, TEAM_GOALS[team].location)
	end
end

function ScoreManager:Laser(start_position, end_position)
	local laser_pfx = ParticleManager:CreateParticle("particles/econ/items/tinker/tinker_ti10_immortal_laser/tinker_ti10_immortal_laser.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(laser_pfx, 9, start_position + Vector(0, 0, 150))
	ParticleManager:SetParticleControl(laser_pfx, 1, end_position + Vector(0, 0, 150))
	ParticleManager:ReleaseParticleIndex(laser_pfx)
end