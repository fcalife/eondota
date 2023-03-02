LinkLuaModifier("modifier_barracks_creep_spawn_state", "abilities/barracks", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_barracks_creep_teleport_wait", "abilities/barracks", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_barracks_creep_teleport", "abilities/barracks", LUA_MODIFIER_MOTION_NONE)

modifier_barracks_creep_spawn_state = class({})

function modifier_barracks_creep_spawn_state:IsHidden() return true end
function modifier_barracks_creep_spawn_state:IsDebuff() return false end
function modifier_barracks_creep_spawn_state:IsPurgable() return false end

function modifier_barracks_creep_spawn_state:CheckState()
	return {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end



modifier_barracks_creep_teleport_wait = class({})

function modifier_barracks_creep_teleport_wait:IsHidden() return true end
function modifier_barracks_creep_teleport_wait:IsDebuff() return false end
function modifier_barracks_creep_teleport_wait:IsPurgable() return false end

function modifier_barracks_creep_teleport_wait:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent:IsAlive() then
		parent:AddNewModifier(parent, nil, "modifier_barracks_creep_teleport", {duration = BARRACKS_UNIT_TELEPORT_DURATION})
	else
		local player_id = parent:GetPlayerOwnerID()
		if player_id and parent.barracks_name then EonSpheres:EndUnitCooldownForPlayer(player_id, parent.barracks_name) end
	end
end



modifier_barracks_creep_teleport = class({})

function modifier_barracks_creep_teleport:IsHidden() return true end
function modifier_barracks_creep_teleport:IsDebuff() return false end
function modifier_barracks_creep_teleport:IsPurgable() return false end

function modifier_barracks_creep_teleport:GetEffectName()
	return "particles/econ/events/fall_2021/teleport_end_fall_2021_lvl1.vpcf"
end

function modifier_barracks_creep_teleport:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_barracks_creep_teleport:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
end

function modifier_barracks_creep_teleport:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
end

function modifier_barracks_creep_teleport:GetOverrideAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

function modifier_barracks_creep_teleport:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	local player_id = parent:GetPlayerOwnerID()

	if parent:IsAlive() then
		parent:Kill(nil, parent)

		if player_id and parent.barracks_name then BarracksManager:RefundBarracksUnitCostForPlayer(player_id, parent.barracks_name) end
	end

	if player_id and parent.barracks_name then EonSpheres:EndUnitCooldownForPlayer(player_id, parent.barracks_name) end
end



barracks_state = class({})

LinkLuaModifier("modifier_barracks_state", "abilities/barracks", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_barracks_state_aura", "abilities/barracks", LUA_MODIFIER_MOTION_NONE)

function barracks_state:GetIntrinsicModifierName()
	return "modifier_barracks_state"
end



modifier_barracks_state = class({})

function modifier_barracks_state:IsHidden() return true end
function modifier_barracks_state:IsDebuff() return false end
function modifier_barracks_state:IsPurgable() return false end

function modifier_barracks_state:IsAura() return true end
function modifier_barracks_state:GetModifierAura() return "modifier_barracks_state_aura" end
function modifier_barracks_state:GetAuraRadius() return 750 end
function modifier_barracks_state:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_barracks_state:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_barracks_state:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_barracks_state:GetAuraEntityReject(unit)
	return self:GetParent():HasModifier("modifier_upgrade_center_disabled")
end

function modifier_barracks_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

function modifier_barracks_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MIN_HEALTH,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
	else
		return {
			MODIFIER_PROPERTY_MIN_HEALTH,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
	end
end

function modifier_barracks_state:GetMinHealth()
	return 1
end

function modifier_barracks_state:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

function modifier_barracks_state:OnTakeDamage(keys)
	if keys.unit == self:GetParent() then
		if keys.unit:GetHealth() < 2 then
			keys.unit:AddNewModifier(keys.unit, self:GetAbility(), "modifier_upgrade_center_disabled", {duration = UPGRADE_CENTER_DISABLE_DURATION})
		end
	end
end



modifier_barracks_state_aura = class({})

function modifier_barracks_state_aura:IsHidden() return false end
function modifier_barracks_state_aura:IsDebuff() return false end
function modifier_barracks_state_aura:IsPurgable() return false end

function modifier_barracks_state_aura:OnCreated()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent:IsRealHero() then
		EonSpheres:GivePlayerBarracksAccess(parent:GetPlayerOwnerID())
	end
end

function modifier_barracks_state_aura:OnRemoved()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent:IsRealHero() then
		EonSpheres:RemovePlayerBarracksAccess(parent:GetPlayerOwnerID())
	end
end



barracks_summon_footman = class({})

function barracks_summon_footman:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 100) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam(), BARRACKS_MID)

		if barracks then barracks:SpawnUnit("npc_eon_tier_1_footman") end
	else
		caster:EmitSound("Upgrade.Fail")
		Timers:CreateTimer(0.1, function() self:EndCooldown() end)
	end
end



barracks_summon_archer = class({})

function barracks_summon_archer:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 100) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam(), BARRACKS_MID)

		if barracks then barracks:SpawnUnit("npc_eon_tier_1_archer") end
	else
		caster:EmitSound("Upgrade.Fail")
		Timers:CreateTimer(0.1, function() self:EndCooldown() end)
	end
end



barracks_summon_marauder = class({})

function barracks_summon_marauder:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 200) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam(), BARRACKS_MID)

		if barracks then barracks:SpawnUnit("npc_eon_tier_2_marauder") end
	else
		caster:EmitSound("Upgrade.Fail")
		Timers:CreateTimer(0.1, function() self:EndCooldown() end)
	end
end



barracks_summon_reaper = class({})

function barracks_summon_reaper:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 250) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam(), BARRACKS_MID)

		if barracks then barracks:SpawnUnit("npc_eon_tier_2_reaper") end
	else
		caster:EmitSound("Upgrade.Fail")
		Timers:CreateTimer(0.1, function() self:EndCooldown() end)
	end
end



barracks_summon_knight = class({})

function barracks_summon_knight:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 500) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam(), BARRACKS_MID)

		if barracks then barracks:SpawnUnit("npc_eon_tier_3_knight") end
	else
		caster:EmitSound("Upgrade.Fail")
		Timers:CreateTimer(0.1, function() self:EndCooldown() end)
	end
end



barracks_summon_golem = class({})

function barracks_summon_golem:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 500) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam(), BARRACKS_MID)

		if barracks then barracks:SpawnUnit("npc_eon_tier_3_golem") end
	else
		caster:EmitSound("Upgrade.Fail")
		Timers:CreateTimer(0.1, function() self:EndCooldown() end)
	end
end