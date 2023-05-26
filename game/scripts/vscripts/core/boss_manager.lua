_G.BossManager = BossManager or {}

BOSS_PHASE_PRESENT = 1
BOSS_PHASE_PAST = 2
BOSS_PHASE_FUTURE = 3

HEALTH_DROP_MIN_TIME = 40
SPHERE_DROP_MIN_TIME = 40
DROP_TIME_VARIATION = 10

function BossManager:StartBossBattle()
	self.boss_is_busy = false

	self.weather_particles = {}

	self:SpawnBoss()

	self.battle_start_time = GameRules:GetGameTime()

	self.next_health_drop = self.battle_start_time + HEALTH_DROP_MIN_TIME + RandomInt(0, DROP_TIME_VARIATION)
	self.next_sphere_drop = self.battle_start_time + SPHERE_DROP_MIN_TIME + RandomInt(0, DROP_TIME_VARIATION)

	self.boss_think_timer = Timers:CreateTimer(1, function()
		return BossManager:TimeThink()
	end)
end

function BossManager:ResetBattle()
	if self.boss_is_busy then return end

	if self.boss_think_timer then Timers:RemoveTimer(self.boss_think_timer) end

	self:ClearWeather()

	self:ResetEonDropCount()

	PowerupManager:CleanPowerups()

	if self.boss then
		self.boss:RemoveModifierByName("modifier_boss_health_controller")
		self.boss:RemoveModifierByName("modifier_phase_transition_beast_state")
		self.boss:ForceKill(false)
	end

	CustomGameEventManager:Send_ServerToAllClients("boss_health", {health = 10000})

	CustomGameEventManager:Send_ServerToAllClients("reset_eon", {})

	RoundManager:Initialize()
end

function BossManager:TimeThink()
	if (not BossManager:IsBossBusy()) then
		local current_time = GameRules:GetGameTime()

		if SPHERE_TRIGGER_MAP and current_time >= self.next_sphere_drop then
			self:SpawnMapEonStone()

			self.next_sphere_drop = current_time + SPHERE_DROP_MIN_TIME + RandomInt(0, DROP_TIME_VARIATION)
		end

		if current_time >= self.next_health_drop then
			self:SpawnHealthPowerup()

			self.next_health_drop = current_time + SPHERE_DROP_MIN_TIME + RandomInt(0, DROP_TIME_VARIATION)
		end
	end

	if GameManager:GetGamePhase() == GAME_STATE_BATTLE then return 1 end
end

function BossManager:SpawnHealthPowerup()
	local powerup_loc = Vector(800, 960, 128)

	if RollPercentage(50) then powerup_loc = Vector(-powerup_loc.x, powerup_loc.y, powerup_loc.z) end
	if RollPercentage(50) then powerup_loc = Vector(powerup_loc.x, -powerup_loc.y, powerup_loc.z) end

	local arena_center = Vector(0, 0, 0)
	if self.boss:HasModifier("modifier_chronobeast_phase_present") then arena_center = Vector(-8192, 0, 0) end
	if self.boss:HasModifier("modifier_chronobeast_phase_future") then arena_center = Vector(8192, 0, 0) end

	powerup_loc = powerup_loc + arena_center

	PowerupManager:SpawnPowerUp(powerup_loc, powerup_loc, "item_health_potion")

	EmitGlobalSound("ui.npe_objective_complete")

	local indicator_pfx = ParticleManager:CreateParticle("particles/boss/powerup_ping.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(indicator_pfx, 0, powerup_loc)

	Timers:CreateTimer(5.0, function()
		ParticleManager:DestroyParticle(indicator_pfx, false)
		ParticleManager:ReleaseParticleIndex(indicator_pfx)
	end)
end

function BossManager:SpawnMapEonStone()
	local powerup_loc = Vector(1536, 896, 128)

	if RollPercentage(50) then powerup_loc = Vector(-powerup_loc.x, powerup_loc.y, powerup_loc.z) end
	if RollPercentage(50) then powerup_loc = Vector(powerup_loc.x, -powerup_loc.y, powerup_loc.z) end

	local arena_center = BossManager:GetCurrentMapCenter()

	powerup_loc = powerup_loc + arena_center

	BossManager:IncrementEonDropCount()

	PowerupManager:SpawnPowerUp(powerup_loc, powerup_loc, "item_mario_star")

	EmitGlobalSound("ui.npe_objective_complete")

	local indicator_pfx = ParticleManager:CreateParticle("particles/boss/powerup_ping.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(indicator_pfx, 0, powerup_loc - Vector(0, 0, 96))

	Timers:CreateTimer(5.0, function()
		ParticleManager:DestroyParticle(indicator_pfx, false)
		ParticleManager:ReleaseParticleIndex(indicator_pfx)
	end)
end

function BossManager:SetWeather(phase)
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		local player = hero:GetPlayerOwner()

		if player then
			local pid = player:GetPlayerID()
			self.weather_particles[pid] = ParticleManager:CreateParticleForPlayer("particles/boss/weather_"..phase..".vpcf", PATTACH_EYES_FOLLOW, hero, player)
		end
	end
end

function BossManager:ClearWeather()
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		local player = hero:GetPlayerOwner()

		if player then
			local pid = player:GetPlayerID()
			if self.weather_particles[pid] then
				ParticleManager:DestroyParticle(self.weather_particles[pid], false)
				ParticleManager:ReleaseParticleIndex(self.weather_particles[pid])
			end
		end
	end

	self.weather_particles = {}
end

function BossManager:LockCameraForAllPlayers(target, release)
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		LockPlayerCameraOnTarget(hero, target or hero, release)
	end
end

function BossManager:InitializeAllSpells()
	local ability_swipe_light = self.boss:FindAbilityByName("beast_swipe_light")
	local ability_swipe_heavy = self.boss:FindAbilityByName("beast_swipe_heavy")
	local ability_roar = self.boss:FindAbilityByName("beast_roar")
	local ability_breath = self.boss:FindAbilityByName("beast_breath")
	local ability_tail_spin = self.boss:FindAbilityByName("beast_tail_spin")
	local ability_leap = self.boss:FindAbilityByName("beast_leap")
	local ability_spikes = self.boss:FindAbilityByName("beast_spikes")
	local ability_charge = self.boss:FindAbilityByName("beast_charge")
	local ability_bite = self.boss:FindAbilityByName("beast_bite")
	local ability_tail_smash = self.boss:FindAbilityByName("beast_tail_smash")

	if ability_swipe_light then ability_swipe_light:StartCooldown(0.5 * ability_swipe_light:GetCooldown(1)) end
	if ability_swipe_heavy then ability_swipe_heavy:StartCooldown(0.5 * ability_swipe_heavy:GetCooldown(1)) end
	if ability_roar then ability_roar:StartCooldown(0.5 * ability_roar:GetCooldown(1)) end
	if ability_breath then ability_breath:StartCooldown(0.5 * ability_breath:GetCooldown(1)) end
	if ability_tail_spin then ability_tail_spin:StartCooldown(0.5 * ability_tail_spin:GetCooldown(1)) end
	if ability_leap then ability_leap:StartCooldown(0.5 * ability_leap:GetCooldown(1)) end
	if ability_spikes then ability_spikes:StartCooldown(0.5 * ability_spikes:GetCooldown(1)) end
	if ability_charge then ability_charge:StartCooldown(0.5 * ability_charge:GetCooldown(1)) end
	if ability_bite then ability_bite:StartCooldown(0.5 * ability_bite:GetCooldown(1)) end
	if ability_tail_smash then ability_tail_smash:StartCooldown(0.5 * ability_tail_smash:GetCooldown(1)) end
end

function BossManager:SpawnBoss()
	BossManager:SetBossBusyState(true)

	local spawn_point = GameManager:GetMapLocation("boss_spawn_present")

	self.boss = CreateUnitByName("npc_eon_chronobeast", spawn_point, true, nil, nil, DOTA_TEAM_BADGUYS)
	--self.boss:SetControllableByPlayer(0, false)
	self.boss:AddNewModifier(self.boss, nil, "modifier_chronobeast_phase_present", {})

	AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(-8192, 0, 0), 10000, 99999, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), 10000, 99999, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(8192, 0, 0), 10000, 99999, false)

	self.fow_viewer = AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(-8192, 0, 0), 4000, 99999, false)

	BossManager:SetWeather("present")

	self.boss:AddNewModifier(self.boss, nil, "modifier_phase_transition_beast_state", {})

	Timers:CreateTimer(1.0, function()
		BossManager:CastSpellPointTarget("beast_leap", Vector(-8192, 10, 256), true)

		Timers:CreateTimer(3.5, function()
			BossManager:PlayMusic("awolnation_01.music.battle_02")
			CustomGameEventManager:Send_ServerToAllClients("show_health", {})

			Timers:CreateTimer(1.5, function()
				BossManager:CastSpellNoTarget("beast_phase_roar", true)

				Timers:CreateTimer(0.8, function()
					for _, hero in pairs(HeroList:GetAllHeroes()) do
						hero:RemoveModifierByName("modifier_phase_transition_roar")
						hero:RemoveModifierByName("modifier_stunned")
					end

					BossManager:InitializeAllSpells()

					BossManager:SetBossBusyState(false)

					self.boss:RemoveModifierByName("modifier_phase_transition_beast_state")

					Timers:CreateTimer(0.1, function()
						return BossManager:Think()
					end)
				end)
			end)
		end)
	end)
end

function BossManager:AdvanceToPhaseTwo()
	BossManager:LockCameraForAllPlayers(self.boss, false)
	BossManager:SetBossBusyState(true)
	BossManager:PlayMusic("awolnation_01.music.battle_02_end")

	self.boss:RemoveModifierByName("modifier_charge_exhausted")
	self.boss:AddNewModifier(self.boss, nil, "modifier_phase_transition_beast_state", {})

	BossManager:CastSpellPointTarget("beast_leap", Vector(-8192, 10, 256), true)
	BossManager:MoveToPosition(Vector(-8192, 0, 256), true)

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		hero:AddNewModifier(hero, nil, "modifier_phase_transition_no_damage", {})
	end

	Timers:CreateTimer(2.3, function()
		BossManager:CastSpellNoTarget("beast_phase_roar", true)

		BossManager:ClearWeather()

		Timers:CreateTimer(0.75, function()
			self.boss:EmitSound("PhaseChange.Start")
			self.boss:EmitSound("PhaseChange.TickTock")

			local jump_modifier = self.boss:FindModifierByName("modifier_extra_jumps")
			if jump_modifier then jump_modifier:IncrementStackCount() end

			local crono_pfx = ParticleManager:CreateParticle("particles/boss/phase_transition_chrono.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(crono_pfx, 0, Vector(-8192, 0, 256))
			ParticleManager:SetParticleControl(crono_pfx, 1, Vector(800, 800, 800))

			for _, hero in pairs(HeroList:GetAllHeroes()) do
				local player = hero:GetPlayerOwner()

				if player then
					local screen_pfx = ParticleManager:CreateParticleForPlayer("particles/boss/phase_transition.vpcf", PATTACH_EYES_FOLLOW, hero, player)
					ParticleManager:ReleaseParticleIndex(screen_pfx)
				end
			end

			Timers:CreateTimer(6.0, function()
				self.boss:SetHealth(self.boss:GetMaxHealth())
				CustomGameEventManager:Send_ServerToAllClients("boss_health", {health = self.boss:GetHealth()})

				ParticleManager:DestroyParticle(crono_pfx, false)

				self.boss:EmitSound("PhaseChange.End")
				self.boss:StopSound("PhaseChange.TickTock")

				self.boss:AddNewModifier(self.boss, nil, "modifier_chronobeast_phase_past", {})
				self.boss:RemoveModifierByName("modifier_chronobeast_phase_present")

				if self.fow_viewer then RemoveFOWViewer(DOTA_TEAM_GOODGUYS, self.fow_viewer) end

				self.fow_viewer = AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), 4000, 99999, false)

				FindClearSpaceForUnit(self.boss, Vector(0, 0, 256), true)

				for _, hero in pairs(HeroList:GetAllHeroes()) do
					FindClearSpaceForUnit(hero, hero:GetAbsOrigin() + Vector(8192, 0, 0), true)
				end

				PowerupManager:MovePowerupsToNextArena()

				BossManager:SetWeather("past")

				Timers:CreateTimer(3.5, function()
					BossManager:CastSpellNoTarget("beast_roar", true)

					Timers:CreateTimer(0.75, function()
						for _, hero in pairs(HeroList:GetAllHeroes()) do
							hero:RemoveModifierByName("modifier_phase_transition_roar")
							hero:RemoveModifierByName("modifier_phase_transition_no_damage")
						end

						self.boss:RemoveModifierByName("modifier_phase_transition_beast_state")

						BossManager:LockCameraForAllPlayers(nil, (not CAMERA_LOCK))

						Timers:CreateTimer(1.5, function()
							BossManager:SetBossBusyState(false)
							BossManager:PlayMusic("awolnation_01.music.battle_03")
						end)
					end)
				end)
			end)
		end)
	end)
end

function BossManager:AdvanceToPhaseThree()
	BossManager:LockCameraForAllPlayers(self.boss, false)
	BossManager:SetBossBusyState(true)
	BossManager:PlayMusic("awolnation_01.music.battle_03_end")

	self.boss:RemoveModifierByName("modifier_charge_exhausted")
	self.boss:AddNewModifier(self.boss, nil, "modifier_phase_transition_beast_state", {})

	BossManager:CastSpellPointTarget("beast_leap", Vector(0, 10, 256), true)
	BossManager:MoveToPosition(Vector(0, 0, 256), true)

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		hero:AddNewModifier(hero, nil, "modifier_phase_transition_no_damage", {})
	end

	Timers:CreateTimer(2.3, function()
		BossManager:CastSpellNoTarget("beast_phase_roar", true)

		BossManager:ClearWeather()

		Timers:CreateTimer(0.75, function()
			self.boss:EmitSound("PhaseChange.Start")
			self.boss:EmitSound("PhaseChange.TickTock")

			local jump_modifier = self.boss:FindModifierByName("modifier_extra_jumps")
			if jump_modifier then jump_modifier:IncrementStackCount() end

			local crono_pfx = ParticleManager:CreateParticle("particles/boss/phase_transition_chrono.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(crono_pfx, 0, Vector(0, 0, 256))
			ParticleManager:SetParticleControl(crono_pfx, 1, Vector(800, 800, 800))

			for _, hero in pairs(HeroList:GetAllHeroes()) do
				local player = hero:GetPlayerOwner()

				if player then
					local screen_pfx = ParticleManager:CreateParticleForPlayer("particles/boss/phase_transition.vpcf", PATTACH_EYES_FOLLOW, hero, player)
					ParticleManager:ReleaseParticleIndex(screen_pfx)
				end
			end

			Timers:CreateTimer(6.0, function()
				self.boss:SetHealth(self.boss:GetMaxHealth())
				CustomGameEventManager:Send_ServerToAllClients("boss_health", {health = self.boss:GetHealth()})

				ParticleManager:DestroyParticle(crono_pfx, false)

				self.boss:EmitSound("PhaseChange.End")
				self.boss:StopSound("PhaseChange.TickTock")

				self.boss:AddNewModifier(self.boss, nil, "modifier_chronobeast_phase_future", {})
				self.boss:RemoveModifierByName("modifier_chronobeast_phase_past")

				if self.fow_viewer then RemoveFOWViewer(DOTA_TEAM_GOODGUYS, self.fow_viewer) end

				self.fow_viewer = AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(8192, 0, 0), 4000, 99999, false)

				FindClearSpaceForUnit(self.boss, Vector(8192, 0, 256), true)

				for _, hero in pairs(HeroList:GetAllHeroes()) do
					FindClearSpaceForUnit(hero, hero:GetAbsOrigin() + Vector(8192, 0, 0), true)
				end

				PowerupManager:MovePowerupsToNextArena()

				BossManager:SetWeather("future")

				Timers:CreateTimer(3.5, function()
					BossManager:CastSpellNoTarget("beast_roar", true)
					BossManager:PlayMusic("awolnation_01.music.battle_01")

					Timers:CreateTimer(0.75, function()
						for _, hero in pairs(HeroList:GetAllHeroes()) do
							hero:RemoveModifierByName("modifier_phase_transition_roar")
							hero:RemoveModifierByName("modifier_phase_transition_no_damage")
						end

						self.boss:RemoveModifierByName("modifier_phase_transition_beast_state")

						BossManager:LockCameraForAllPlayers(nil, (not CAMERA_LOCK))

						Timers:CreateTimer(1.5, function()
							BossManager:SetBossBusyState(false)
						end)
					end)
				end)
			end)
		end)
	end)
end

function BossManager:CastSpellNoTarget(spell_name, ignore_cooldown)
	local ability = self.boss:FindAbilityByName(spell_name)

	if (not ability) then return end

	if ignore_cooldown then ability:EndCooldown() end

	ExecuteOrderFromTable({
		unitIndex = self.boss:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = ability:entindex(),
		Queue = false
	})
end

function BossManager:CastSpellPointTarget(spell_name, target, ignore_cooldown)
	local ability = self.boss:FindAbilityByName(spell_name)

	if (not ability) then return end

	if ignore_cooldown then ability:EndCooldown() end

	ExecuteOrderFromTable({
		unitIndex = self.boss:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = ability:entindex(),
		Position = target,
		Queue = false
	})
end

function BossManager:CastSpellUnitTarget(spell_name, target, ignore_cooldown)
	local ability = self.boss:FindAbilityByName(spell_name)

	if (not ability) then return end

	if ignore_cooldown then ability:EndCooldown() end

	ExecuteOrderFromTable({
		unitIndex = self.boss:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = ability:entindex(),
		TargetIndex = target:entindex(),
		Queue = false
	})
end

function BossManager:MoveToPosition(position, queue_order)
	ExecuteOrderFromTable({
		unitIndex = self.boss:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = position,
		Queue = queue_order
	})
end

function BossManager:SetBossBusyState(state)
	self.boss_is_busy = state
end

function BossManager:IsBossBusy()
	return self.boss_is_busy or nil
end



function BossManager:Think()
	if self.boss:IsChanneling() then return 0.1 end
	if self.boss:HasModifier("modifier_chronobeast_channeling") then return 0.1 end
	if self.boss:HasModifier("modifier_charge_exhausted") then return 0.1 end
	if self:IsBossBusy() then return 0.1 end

	local ability_spikes = self.boss:FindAbilityByName("beast_spikes")
	local ability_breath = self.boss:FindAbilityByName("beast_breath")
	local ability_roar = self.boss:FindAbilityByName("beast_roar")

	local ability_swipe_light = self.boss:FindAbilityByName("beast_swipe_light")
	local ability_swipe_heavy = self.boss:FindAbilityByName("beast_swipe_heavy")
	local ability_tail_spin = self.boss:FindAbilityByName("beast_tail_spin")
	local ability_bite = self.boss:FindAbilityByName("beast_bite")
	local ability_tail_smash = self.boss:FindAbilityByName("beast_tail_smash")

	if self:IsComboOngoing() then
		if ability_swipe_light:IsCooldownReady() then
			self:CastSpellNoTarget("beast_swipe_light", false)

			return ability_swipe_light:GetCastPoint() + 0.03
		end

		if ability_swipe_heavy:IsCooldownReady() then
			self:CastSpellNoTarget("beast_swipe_heavy", false)

			return ability_swipe_heavy:GetCastPoint() + 0.03
		end

		if ability_bite:IsCooldownReady() then
			self:EndCombo()

			local target = self:FindClosestTarget()

			if target then
				self:CastSpellUnitTarget("beast_bite", target, false)

				return ability_bite:GetCastPoint() + 0.1
			else
				ability_bite:UseResources(true, true, true, true)
			end
		end
	end

	if ability_spikes:IsCooldownReady() then
		local target = self:FindClosestTarget()

		if target then
			self:CastSpellUnitTarget("beast_spikes", target, false)

			return ability_spikes:GetCastPoint() + 0.1
		end
	end

	if ability_breath:IsCooldownReady() then
		local target = self:FindClosestTarget()

		if target then
			self:CastSpellPointTarget("beast_breath", target:GetAbsOrigin(), false)

			return ability_breath:GetCastPoint() + 0.1
		end
	end

	if ability_roar:IsCooldownReady() then
		self:CastSpellNoTarget("beast_roar", false)

		return ability_roar:GetCastPoint() + 0.5
	end

	if ability_tail_spin:IsCooldownReady() then
		if self.boss:HasModifier("modifier_chronobeast_phase_past") or self.boss:HasModifier("modifier_chronobeast_phase_future") then
			local target = self:FindClosestTarget()

			if target and (target:GetAbsOrigin() - self.boss:GetAbsOrigin()):Length2D() < 600 then
				self:CastSpellNoTarget("beast_tail_spin", false)

				return ability_tail_spin:GetCastPoint() + 1.25
			end
		end
	end

	if ability_tail_smash:IsCooldownReady() and self.boss:HasModifier("modifier_chronobeast_phase_present") then
		local hit_loc = self.boss:GetAbsOrigin() - 325 * self.boss:GetForwardVector()

		local enemies = FindUnitsInRadius(
			self.boss:GetTeam(),
			hit_loc,
			nil,
			650,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		if #enemies > 0 then
			self:CastSpellNoTarget("beast_tail_smash", false)

			return ability_tail_smash:GetCastPoint() + 0.1
		end
	end

	if ability_bite:IsCooldownReady() then
		local hit_loc = self.boss:GetAbsOrigin() + 300 * self.boss:GetForwardVector()

		local enemies = FindUnitsInRadius(
			self.boss:GetTeam(),
			hit_loc,
			nil,
			300,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		if enemies[1] then
			ability_swipe_light:EndCooldown()
			ability_swipe_heavy:EndCooldown()

			self:StartCombo()

			return 0.05
		end
	end

	if ability_swipe_heavy:IsCooldownReady() then
		local hit_loc = self.boss:GetAbsOrigin() + 400 * self.boss:GetForwardVector()

		local enemies = FindUnitsInRadius(
			self.boss:GetTeam(),
			hit_loc,
			nil,
			400,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		if #enemies > 0 then
			self:CastSpellNoTarget("beast_swipe_heavy", false)

			return ability_swipe_heavy:GetCastPoint() + 0.1
		end
	end

	if ability_swipe_light:IsCooldownReady() then
		local hit_loc = self.boss:GetAbsOrigin() + 300 * self.boss:GetForwardVector()

		local enemies = FindUnitsInRadius(
			self.boss:GetTeam(),
			hit_loc,
			nil,
			275,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		if #enemies > 0 then
			self:CastSpellNoTarget("beast_swipe_light", false)

			return ability_swipe_light:GetCastPoint() + 0.1
		end
	end

	local closest_enemy = self:FindClosestTarget()
	local closest_enemy_loc = (closest_enemy and closest_enemy:GetAbsOrigin()) or nil

	local closest_enemy_leap = self:LeapOrChargeIfPossible(closest_enemy_loc)

	if closest_enemy_leap and closest_enemy_leap > 0 then return closest_enemy_leap end

	ExecuteOrderFromTable({
		unitIndex = self.boss:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = closest_enemy_loc,
		Queue = false
	})

	return 0.1
end

function BossManager:StartCombo()
	self.ongoing_combo = true
end

function BossManager:EndCombo()
	self.ongoing_combo = false
end

function BossManager:IsComboOngoing()
	return self.ongoing_combo or nil
end

function BossManager:FindRandomTarget()
	local alive_heroes = {}
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:IsAlive() then table.insert(alive_heroes, hero) end
	end

	return ((#alive_heroes > 0) and alive_heroes[RandomInt(1, #alive_heroes)]) or nil
end

function BossManager:FindClosestTarget()
	local enemies = {}
	local all_heroes = HeroList:GetAllHeroes()

	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:IsAlive() and (not hero:IsInvulnerable()) then table.insert(enemies, hero) end
	end

	if enemies[2] then
		local distance_a = (enemies[1]:GetAbsOrigin() - self.boss:GetAbsOrigin()):Length2D()
		local distance_b = (enemies[2]:GetAbsOrigin() - self.boss:GetAbsOrigin()):Length2D()

		if distance_a > distance_b then return enemies[2] end
	end

	return enemies[1] or nil
end

function BossManager:LeapOrChargeIfPossible(position)
	if (not position) then return nil end

	local ability_leap = self.boss:FindAbilityByName("beast_leap")
	local ability_charge = self.boss:FindAbilityByName("beast_charge")

	if ability_charge:IsCooldownReady() then
		self:CastSpellPointTarget("beast_charge", position, false)

		return ability_charge:GetCastPoint() + 0.05
	end

	if ability_leap:IsCooldownReady() then
		self:CastSpellPointTarget("beast_leap", position, false)

		return ability_leap:GetCastPoint() + 0.05
	end

	return nil
end

function BossManager:PlayMusic(name)
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		local player = hero:GetPlayerOwner()

		if player then EmitSoundOnClient(name, player) end
	end
end

function BossManager:GetCurrentPhase()
	if self.boss:HasModifier("modifier_chronobeast_phase_present") then return BOSS_PHASE_PRESENT end
	if self.boss:HasModifier("modifier_chronobeast_phase_past") then return BOSS_PHASE_PAST end
	if self.boss:HasModifier("modifier_chronobeast_phase_future") then return BOSS_PHASE_FUTURE end
end

function BossManager:GetCurrentMapCenter()
	if self:GetCurrentPhase() == BOSS_PHASE_PRESENT then return Vector(-8192, 0, 256) end
	if self:GetCurrentPhase() == BOSS_PHASE_PAST then return Vector(0, 0, 256) end
	if self:GetCurrentPhase() == BOSS_PHASE_FUTURE then return Vector(8192, 0, 256) end
end

function BossManager:IncrementEonDropCount()
	self.eon_drops = (self.eon_drops or 0) + 1
end

function BossManager:GetEonDropCount()
	return (self.eon_drops or 0)
end

function BossManager:ResetEonDropCount()
	self.eon_drops = 0
end