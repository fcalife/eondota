_G.DebugCommandManager = DebugCommandManager or {}

CustomGameEventManager:RegisterListener("debug_command_fight_reset", function(_, event)
	DebugCommandManager:FightReset()
end)

CustomGameEventManager:RegisterListener("debug_command_advance_phase", function(_, event)
	DebugCommandManager:AdvancePhase()
end)

CustomGameEventManager:RegisterListener("debug_command_heal_all", function(_, event)
	DebugCommandManager:HealAll()
end)

CustomGameEventManager:RegisterListener("debug_command_god_mode", function(_, event)
	DebugCommandManager:ToggleGodMode()
end)

CustomGameEventManager:RegisterListener("debug_command_set_sphere_trigger_health", function(_, event)
	DebugCommandManager:SetSphereTriggerHealth()
end)

CustomGameEventManager:RegisterListener("debug_command_set_sphere_trigger_weak_point", function(_, event)
	DebugCommandManager:SetSphereTriggerWeakPoint()
end)

CustomGameEventManager:RegisterListener("debug_command_set_sphere_trigger_map", function(_, event)
	DebugCommandManager:SetSphereTriggerMap()
end)

CustomGameEventManager:RegisterListener("debug_command_sphere_ms", function(_, event)
	DebugCommandManager:SetSphereMoveSpeed(event)
end)

CustomGameEventManager:RegisterListener("debug_command_sphere_regen", function(_, event)
	DebugCommandManager:SetSphereHealthRegen(event)
end)

CustomGameEventManager:RegisterListener("debug_command_sphere_shield", function(_, event)
	DebugCommandManager:SetSphereShieldAmount(event)
end)

CustomGameEventManager:RegisterListener("debug_command_sphere_shield_cd", function(_, event)
	DebugCommandManager:SetSphereShieldCooldown(event)
end)

CustomGameEventManager:RegisterListener("debug_command_sphere_nuke_damage", function(_, event)
	DebugCommandManager:SetSphereNukeDamage(event)
end)

CustomGameEventManager:RegisterListener("debug_command_sphere_power_factor", function(_, event)
	DebugCommandManager:SetSpherePowerFactor(event)
end)

CustomGameEventManager:RegisterListener("debug_command_set_player_health", function(_, event)
	DebugCommandManager:SetPlayerHealth(event)
end)





function DebugCommandManager:FightReset()
	BossManager:ResetBattle()
end

function DebugCommandManager:AdvancePhase()
	if BossManager:GetCurrentPhase() == BOSS_PHASE_PRESENT then
		local boss_health = BossManager.boss:GetHealth()

		if boss_health > 5000 then
			ApplyDamage({attacker = BossManager.boss, victim = BossManager.boss, damage = boss_health - 4999, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
		end
	elseif BossManager:GetCurrentPhase() == BOSS_PHASE_PAST then
		local boss_health = BossManager.boss:GetHealth()

		if boss_health > 5000 then
			ApplyDamage({attacker = BossManager.boss, victim = BossManager.boss, damage = boss_health - 4999, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
		end
	end
end

function DebugCommandManager:HealAll()
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		hero:Heal(9999, nil)
	end
end

function DebugCommandManager:ToggleGodMode()
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:HasModifier("modifier_boss_god_mode") then
			hero:RemoveModifierByName("modifier_boss_god_mode")
		else
			hero:AddNewModifier(hero, nil, "modifier_boss_god_mode", {})
		end
	end
end






SPHERE_TRIGGER_HEALTH = false
SPHERE_TRIGGER_WEAK_POINT = true
SPHERE_TRIGGER_MAP = false

function DebugCommandManager:SetSphereTriggerHealth()
	SPHERE_TRIGGER_HEALTH = true
	SPHERE_TRIGGER_WEAK_POINT = false
	SPHERE_TRIGGER_MAP = false

	self:FightReset()
end

function DebugCommandManager:SetSphereTriggerWeakPoint()
	SPHERE_TRIGGER_HEALTH = false
	SPHERE_TRIGGER_WEAK_POINT = true
	SPHERE_TRIGGER_MAP = false

	self:FightReset()
end

function DebugCommandManager:SetSphereTriggerMap()
	SPHERE_TRIGGER_HEALTH = false
	SPHERE_TRIGGER_WEAK_POINT = false
	SPHERE_TRIGGER_MAP = true

	self:FightReset()
end





SPHERE_MOVE_SPEED = 20
SPHERE_HEALTH_REGEN = 10
SPHERE_SHIELD_AMOUNT = 500
SPHERE_SHIELD_DELAY = 15
SPHERE_NUKE_DAMAGE = 300
SPHERE_POWER_FACTOR = 2

function DebugCommandManager:SetSphereMoveSpeed(event)
	SPHERE_MOVE_SPEED = tonumber(event.value)
end

function DebugCommandManager:SetSphereHealthRegen(event)
	SPHERE_HEALTH_REGEN = tonumber(event.value)
end

function DebugCommandManager:SetSphereShieldAmount(event)
	SPHERE_SHIELD_AMOUNT = tonumber(event.value)
end

function DebugCommandManager:SetSphereShieldCooldown(event)
	SPHERE_SHIELD_DELAY = tonumber(event.value)
end

function DebugCommandManager:SetSphereNukeDamage(event)
	SPHERE_NUKE_DAMAGE = tonumber(event.value)
end

function DebugCommandManager:SetSpherePowerFactor(event)
	SPHERE_POWER_FACTOR = tonumber(event.value)
end

function DebugCommandManager:SetPlayerHealth(event)
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		local health_modifier = hero:FindModifierByName("modifier_hero_base_state")

		if health_modifier then health_modifier:SetStackCount(tonumber(event.value)) end

		hero:CalculateStatBonus(true)

		hero:Heal(9999, nil)
	end
end