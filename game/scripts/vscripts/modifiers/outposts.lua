modifier_fountain_outpost_thinker = class({})

function modifier_fountain_outpost_thinker:IsHidden() return false end
function modifier_fountain_outpost_thinker:IsDebuff() return false end
function modifier_fountain_outpost_thinker:IsPurgable() return false end

function modifier_fountain_outpost_thinker:IsAura() return true end
function modifier_fountain_outpost_thinker:GetModifierAura() return "modifier_fountain_outpost_buff" end
function modifier_fountain_outpost_thinker:GetAuraRadius() return 350 end
function modifier_fountain_outpost_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_fountain_outpost_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_fountain_outpost_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end



modifier_fountain_outpost_buff = class({})

function modifier_fountain_outpost_buff:IsHidden() return false end
function modifier_fountain_outpost_buff:IsDebuff() return false end
function modifier_fountain_outpost_buff:IsPurgable() return false end

function modifier_fountain_outpost_buff:GetTexture() return "rune_regen" end

function modifier_fountain_outpost_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_fountain_outpost_buff:GetModifierHealthRegenPercentage()
	return 4
end

function modifier_fountain_outpost_buff:GetModifierConstantManaRegen()
	return 0.05 * self:GetParent():GetMaxMana()
end