ability_ball_forcer = class({})

function ability_ball_forcer:CastFilterResultTarget(target)
	if target:HasModifier("modifier_item_eon_stone_visual") then return UF_SUCCESS end

	return UF_FAIL_CUSTOM
end

function ability_ball_forcer:GetCustomCastErrorTarget(target)
	if target:HasModifier("modifier_item_eon_stone_visual") then return UF_SUCCESS end

	return "#error_not_carrying_ball"
end

function ability_ball_forcer:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local distance = self:GetSpecialValueFor("push_length")
	local speed = self:GetSpecialValueFor("speed")

	target:AddNewModifier(caster, self, "modifier_item_forcestaff_active", {duration = distance / speed, push_length = distance})

	target:EmitSound("DOTA_Item.ForceStaff.Activate")
end