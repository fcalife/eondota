LinkLuaModifier("modifier_red_rune_buff", "items/runes", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_green_rune_buff", "items/runes", LUA_MODIFIER_MOTION_NONE)



item_red_rune = class({})

function item_red_rune:OnSpellStart(keys)
	local caster = self:GetCaster()
	local team = caster:GetTeam()

	EmitAnnouncerSoundForTeam("red_rune.activate", team)

	caster:AddNewModifier(caster, nil, "modifier_red_rune_buff", {duration = RED_BUFF_DURATION})

	self:Destroy()
end



item_green_rune = class({})

function item_green_rune:OnSpellStart(keys)
	local caster = self:GetCaster()
	local team = caster:GetTeam()

	EmitAnnouncerSoundForTeam("green_rune.activate", team)

	caster:AddNewModifier(caster, nil, "modifier_green_rune_buff", {duration = GREEN_BUFF_DURATION})

	self:Destroy()
end



modifier_red_rune_buff = class({})

function modifier_red_rune_buff:IsHidden() return false end
function modifier_red_rune_buff:IsDebuff() return false end
function modifier_red_rune_buff:IsPurgable() return false end

function modifier_red_rune_buff:GetTexture()
	return "rune_haste"
end

function modifier_red_rune_buff:GetEffectName()
	return "particles/control_zone/shrine_frenzy_buff.vpcf"
end

function modifier_red_rune_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_red_rune_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE 
	}
end

function modifier_red_rune_buff:GetModifierTotalDamageOutgoing_Percentage()
	return 30
end

function modifier_red_rune_buff:GetModifierIncomingDamage_Percentage()
	return 10
end



modifier_green_rune_buff = class({})

function modifier_green_rune_buff:IsHidden() return false end
function modifier_green_rune_buff:IsDebuff() return false end
function modifier_green_rune_buff:IsPurgable() return false end

function modifier_green_rune_buff:GetTexture()
	return "rune_regen"
end

function modifier_green_rune_buff:GetEffectName()
	return "particles/control_zone/shrine_catastrophe_buff.vpcf"
end

function modifier_green_rune_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_green_rune_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
	}
end

function modifier_green_rune_buff:GetModifierMoveSpeedBonus_Percentage()
	return 20
end

function modifier_green_rune_buff:GetModifierStatusResistanceStacking()
	return 20
end