modifier_hero_base_state = class({})

function modifier_hero_base_state:IsHidden() return true end
function modifier_hero_base_state:IsDebuff() return false end
function modifier_hero_base_state:IsPurgable() return false end
function modifier_hero_base_state:RemoveOnDeath() return false end
function modifier_hero_base_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_base_state:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if (not IsInToolsMode()) then parent:AddNewModifier(parent, nil, "modifier_stunned", {duration = 20}) end
end



modifier_hero_boosted_mana_regen = class({})

function modifier_hero_boosted_mana_regen:IsHidden() return true end
function modifier_hero_boosted_mana_regen:IsDebuff() return false end
function modifier_hero_boosted_mana_regen:IsPurgable() return false end
function modifier_hero_boosted_mana_regen:RemoveOnDeath() return false end
function modifier_hero_boosted_mana_regen:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_boosted_mana_regen:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_hero_boosted_mana_regen:GetModifierConstantManaRegen()
	return 0.01 * self:GetParent():GetMaxMana()
end