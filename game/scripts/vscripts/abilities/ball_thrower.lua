ability_ball_thrower = class({})

function ability_ball_thrower:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local distance = self:GetSpecialValueFor("distance")
	local speed = self:GetSpecialValueFor("speed")

	local stone = caster:FindItemInInventory("item_eon_stone")

	if stone then
		caster:AddNewModifier(caster, self, "modifier_item_eon_stone_long_throw", {duration = distance / speed})
		caster:SetCursorPosition(target)

		stone:OnSpellStart()
		stone:UseResources(true, true, true)
	end
end