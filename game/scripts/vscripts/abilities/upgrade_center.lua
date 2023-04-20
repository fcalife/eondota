upgrade_center_state = class({})

LinkLuaModifier("modifier_upgrade_center_state", "abilities/upgrade_center", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_upgrade_center_fountain_aura", "abilities/upgrade_center", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_upgrade_center_disabled", "abilities/upgrade_center", LUA_MODIFIER_MOTION_NONE)

function upgrade_center_state:GetIntrinsicModifierName()
	return "modifier_upgrade_center_state"
end



modifier_upgrade_center_state = class({})

function modifier_upgrade_center_state:IsHidden() return true end
function modifier_upgrade_center_state:IsDebuff() return false end
function modifier_upgrade_center_state:IsPurgable() return false end

function modifier_upgrade_center_state:IsAura() return true end
function modifier_upgrade_center_state:GetModifierAura() return "modifier_upgrade_center_fountain_aura" end
function modifier_upgrade_center_state:GetAuraRadius() return 750 end
function modifier_upgrade_center_state:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_upgrade_center_state:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_upgrade_center_state:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end

function modifier_upgrade_center_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

function modifier_upgrade_center_state:DeclareFunctions()
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

function modifier_upgrade_center_state:GetMinHealth()
	return 1
end

function modifier_upgrade_center_state:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

function modifier_upgrade_center_state:OnTakeDamage(keys)
	if keys.unit == self:GetParent() then
		if keys.unit:GetHealth() < 2 then
			keys.unit:AddNewModifier(keys.unit, self:GetAbility(), "modifier_upgrade_center_disabled", {duration = UPGRADE_CENTER_DISABLE_DURATION})
		end
	end
end



modifier_upgrade_center_fountain_aura = class({})

function modifier_upgrade_center_fountain_aura:IsHidden() return false end
function modifier_upgrade_center_fountain_aura:IsDebuff() return false end
function modifier_upgrade_center_fountain_aura:IsPurgable() return false end

function modifier_upgrade_center_fountain_aura:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_upgrade_center_fountain_aura:GetModifierHealthRegenPercentage()
	return 6
end

function modifier_upgrade_center_fountain_aura:GetModifierConstantManaRegen()
	return 0.07 * self:GetParent():GetMaxMana()
end



modifier_upgrade_center_disabled = class({})

function modifier_upgrade_center_disabled:IsHidden() return false end
function modifier_upgrade_center_disabled:IsDebuff() return true end
function modifier_upgrade_center_disabled:IsPurgable() return false end

function modifier_upgrade_center_disabled:OnCreated(keys)
	if IsClient() then return end

	self:GetParent():EmitSound("Building.PowerDown")
end

function modifier_upgrade_center_disabled:OnDestroy()
	if IsClient() then return end

	self:GetParent():EmitSound("Building.PowerUp")
end

function modifier_upgrade_center_disabled:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}
end

function modifier_upgrade_center_disabled:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
end

function modifier_upgrade_center_disabled:GetModifierHealthRegenPercentage()
	return 100/60
end

function modifier_upgrade_center_disabled:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_upgrade_center_disabled:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_upgrade_center_disabled:GetAbsoluteNoDamagePure()
	return 1
end





upgrade_economy_1 = class({})

function upgrade_economy_1:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 300) then
		local refinery = Refineries:GetRefinery(caster:GetTeam())

		if refinery then
			for i = 1, 2 do refinery:SpawnHarvester() end
			refinery:UpgradeHarvesters(2)

			caster:EmitSound("Upgrade.Success")
			self:SetActivated(false)
			self:SetHidden(true)
		end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



upgrade_creeps_1 = class({})

LinkLuaModifier("modifier_upgrade_creeps", "abilities/upgrade_center", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_upgrade_creeps_buff", "abilities/upgrade_center", LUA_MODIFIER_MOTION_NONE)

function upgrade_creeps_1:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 300) then
		caster:AddNewModifier(caster, self, "modifier_upgrade_creeps", {})

		caster:EmitSound("Upgrade.Success")
		self:SetActivated(false)
		self:SetHidden(true)
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



modifier_upgrade_creeps = class({})

function modifier_upgrade_creeps:IsHidden() return true end
function modifier_upgrade_creeps:IsDebuff() return false end
function modifier_upgrade_creeps:IsPurgable() return false end

function modifier_upgrade_creeps:IsAura() return true end
function modifier_upgrade_creeps:GetModifierAura() return "modifier_upgrade_creeps_buff" end
function modifier_upgrade_creeps:GetAuraRadius() return 10000 end
function modifier_upgrade_creeps:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_upgrade_creeps:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC end



modifier_upgrade_creeps_buff = class({})

function modifier_upgrade_creeps_buff:IsHidden() return false end
function modifier_upgrade_creeps_buff:IsDebuff() return false end
function modifier_upgrade_creeps_buff:IsPurgable() return false end

function modifier_upgrade_creeps_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
	}
end

function modifier_upgrade_creeps_buff:GetModifierDamageOutgoing_Percentage()
	return 10
end

function modifier_upgrade_creeps_buff:GetModifierExtraHealthPercentage()
	return 10
end



upgrade_nexus_1 = class({})

LinkLuaModifier("modifier_upgrade_nexus", "abilities/upgrade_center", LUA_MODIFIER_MOTION_NONE)

function upgrade_nexus_1:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 400) then
		local nexus = NexusManager:GetNexus(caster:GetTeam())

		if nexus then nexus.unit:AddNewModifier(caster, self, "modifier_upgrade_nexus", {}) end

		caster:EmitSound("Upgrade.Success")
		self:SetActivated(false)
		self:SetHidden(true)
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



modifier_upgrade_nexus = class({})

function modifier_upgrade_nexus:IsHidden() return false end
function modifier_upgrade_nexus:IsDebuff() return false end
function modifier_upgrade_nexus:IsPurgable() return false end

function modifier_upgrade_nexus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_upgrade_nexus:GetModifierIncomingDamage_Percentage()
	return -10
end



upgrade_tech_1 = class({})

function upgrade_tech_1:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 500) then
		local new_abilities = {
			"upgrade_economy_2",
			"upgrade_creeps_2",
			"upgrade_nexus_2",
			"upgrade_tech_2",
		}

		for _, ability_name in pairs(new_abilities) do
			local ability = caster:FindAbilityByName(ability_name)
			if ability then ability:SetHidden(false) end
		end

		local barracks_abilities = {
			"barracks_summon_marauder",
			"barracks_summon_reaper"
		}

		local barracks = BarracksManager:GetBarracks(caster:GetTeam())

		for _, ability_name in pairs(barracks_abilities) do
			local ability = barracks.unit:FindAbilityByName(ability_name)
			if ability then ability:SetHidden(false) end
		end

		caster:EmitSound("Upgrade.Success")
		self:SetActivated(false)
		self:SetHidden(true)
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



upgrade_economy_2 = class({})

function upgrade_economy_2:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 400) then
		local refinery = Refineries:GetRefinery(caster:GetTeam())

		if refinery then
			for i = 1, 2 do refinery:SpawnHarvester() end
			refinery:UpgradeHarvesters(3)

			caster:EmitSound("Upgrade.Success")
			self:SetActivated(false)
			self:SetHidden(true)
		end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



upgrade_creeps_2 = class({})

function upgrade_creeps_2:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 600) then
		LaneCreeps:ResearchMagicCreep(caster:GetTeam())

		caster:EmitSound("Upgrade.Success")
		self:SetActivated(false)
		self:SetHidden(true)
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



upgrade_nexus_2 = class({})

function upgrade_nexus_2:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 700) then
		local nexus = NexusManager:GetNexus(caster:GetTeam())

		if nexus then
			local split_shot = nexus.unit:AddAbility("medusa_split_shot")
			split_shot:SetLevel(1)
			split_shot:ToggleAbility()

			caster:EmitSound("Upgrade.Success")
			self:SetActivated(false)
			self:SetHidden(true)
		end
	else
		caster:EmitSound("Upgrade.Fail")
	end
end



upgrade_tech_2 = class({})

function upgrade_tech_2:OnSpellStart()
	local caster = self:GetCaster()

	if EonSpheres:SpendTeamSpheres(caster:GetTeam(), 1000) then
		local new_abilities = {
			"upgrade_creeps_3",
			"upgrade_nexus_3"
		}

		for _, ability_name in pairs(new_abilities) do
			local ability = caster:FindAbilityByName(ability_name)
			if ability then ability:SetHidden(false) end
		end

		local barracks_abilities = {
			"barracks_summon_knight",
			"barracks_summon_golem"
		}

		local barracks = BarracksManager:GetBarracks(caster:GetTeam())

		for _, ability_name in pairs(barracks_abilities) do
			local ability = barracks.unit:FindAbilityByName(ability_name)
			if ability then ability:SetHidden(false) end
		end

		caster:EmitSound("Upgrade.Success")
		self:SetActivated(false)
		self:SetHidden(true)
	else
		caster:EmitSound("Upgrade.Fail")
	end
end