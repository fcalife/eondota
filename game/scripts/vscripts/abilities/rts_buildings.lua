LinkLuaModifier("modifier_building_regen", "abilities/rts_buildings", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_building_regen_effect", "abilities/rts_buildings", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_building_gold", "abilities/rts_buildings", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_building_gold_effect", "abilities/rts_buildings", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_building_damage", "abilities/rts_buildings", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_building_damage_effect", "abilities/rts_buildings", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_building_defense_thinker", "abilities/rts_buildings", LUA_MODIFIER_MOTION_NONE)



ability_building_regen = class({})

function ability_building_regen:GetIntrinsicModifierName()
	return "modifier_building_regen"
end



modifier_building_regen = class({})

function modifier_building_regen:IsHidden() return true end
function modifier_building_regen:IsDebuff() return false end
function modifier_building_regen:IsPurgable() return false end

function modifier_building_regen:IsAura() return true end
function modifier_building_regen:GetModifierAura() return "modifier_building_regen_effect" end
function modifier_building_regen:GetAuraRadius() return 15000 end
function modifier_building_regen:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_building_regen:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_building_regen:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end



modifier_building_regen_effect = class({})

function modifier_building_regen_effect:IsHidden() return true end
function modifier_building_regen_effect:IsDebuff() return false end
function modifier_building_regen_effect:IsPurgable() return false end
function modifier_building_regen_effect:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_building_regen_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_building_regen_effect:GetModifierHealthRegenPercentage()
	return 1
end

function modifier_building_regen_effect:GetModifierConstantManaRegen()
	return 0.01 * self:GetParent():GetMaxMana()
end






ability_building_gold = class({})

function ability_building_gold:GetIntrinsicModifierName()
	return "modifier_building_gold"
end



modifier_building_gold = class({})

function modifier_building_gold:IsHidden() return true end
function modifier_building_gold:IsDebuff() return false end
function modifier_building_gold:IsPurgable() return false end

function modifier_building_gold:IsAura() return true end
function modifier_building_gold:GetModifierAura() return "modifier_building_gold_effect" end
function modifier_building_gold:GetAuraRadius() return 15000 end
function modifier_building_gold:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_building_gold:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_building_gold:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end



modifier_building_gold_effect = class({})

function modifier_building_gold_effect:IsHidden() return true end
function modifier_building_gold_effect:IsDebuff() return false end
function modifier_building_gold_effect:IsPurgable() return false end
function modifier_building_gold_effect:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end



ability_building_damage = class({})

function ability_building_damage:GetIntrinsicModifierName()
	return "modifier_building_damage"
end



modifier_building_damage = class({})

function modifier_building_damage:IsHidden() return true end
function modifier_building_damage:IsDebuff() return false end
function modifier_building_damage:IsPurgable() return false end

function modifier_building_damage:IsAura() return true end
function modifier_building_damage:GetModifierAura() return "modifier_building_damage_effect" end
function modifier_building_damage:GetAuraRadius() return 15000 end
function modifier_building_damage:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_building_damage:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_building_damage:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end



modifier_building_damage_effect = class({})

function modifier_building_damage_effect:IsHidden() return true end
function modifier_building_damage_effect:IsDebuff() return false end
function modifier_building_damage_effect:IsPurgable() return false end
function modifier_building_damage_effect:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_building_damage_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_building_damage_effect:GetModifierTotalDamageOutgoing_Percentage()
	return 15
end



ability_building_defense = class({})

function ability_building_defense:GetIntrinsicModifierName()
	return "modifier_building_defense_thinker"
end



modifier_building_defense_thinker = class({})

function modifier_building_defense_thinker:IsHidden() return true end
function modifier_building_defense_thinker:IsDebuff() return false end
function modifier_building_defense_thinker:IsPurgable() return false end

function modifier_building_defense_thinker:OnCreated(keys)
	if IsClient() then return end

	self:StartIntervalThink(1.5)
end

function modifier_building_defense_thinker:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeam(),
		self:GetParent():GetAbsOrigin(),
		nil,
		1300,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_CLOSEST,
		false
	)

	if enemies and enemies[1] then

		local ability = self:GetParent():FindAbilityByName("magnataur_shockwave")

		self:GetParent():SetCursorPosition(enemies[1]:GetAbsOrigin())

		ability:OnSpellStart()
	end
end