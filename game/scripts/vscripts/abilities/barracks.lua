barracks_state = class({})

LinkLuaModifier("modifier_barracks_state", "abilities/barracks", LUA_MODIFIER_MOTION_NONE)

function barracks_state:GetIntrinsicModifierName()
	return "modifier_barracks_state"
end



modifier_barracks_state = class({})

function modifier_barracks_state:IsHidden() return true end
function modifier_barracks_state:IsDebuff() return false end
function modifier_barracks_state:IsPurgable() return false end

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



barracks_summon_footman = class({})

function barracks_summon_footman:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 100) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam())

		if barracks then barracks:SpawnUnit("npc_eon_tier_1_footman") end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



barracks_summon_archer = class({})

function barracks_summon_archer:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 100) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam())

		if barracks then barracks:SpawnUnit("npc_eon_tier_1_archer") end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



barracks_summon_marauder = class({})

function barracks_summon_marauder:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 200) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam())

		if barracks then barracks:SpawnUnit("npc_eon_tier_2_marauder") end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



barracks_summon_reaper = class({})

function barracks_summon_reaper:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 250) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam())

		if barracks then barracks:SpawnUnit("npc_eon_tier_2_reaper") end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



barracks_summon_knight = class({})

function barracks_summon_knight:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 500) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam())

		if barracks then barracks:SpawnUnit("npc_eon_tier_3_knight") end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



barracks_summon_golem = class({})

function barracks_summon_golem:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 500) then
		local barracks = BarracksManager:GetBarracks(caster:GetTeam())

		if barracks then barracks:SpawnUnit("npc_eon_tier_3_golem") end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end