item_charge_pickup = class({})

function item_charge_pickup:OnSpellStart(keys)
	local caster = self:GetCaster()
	local team = caster:GetTeam()

	caster:EmitSound("Drop.EonStone")

	ScoreManager:OnPickupCharge(team)

	self:Destroy()
end