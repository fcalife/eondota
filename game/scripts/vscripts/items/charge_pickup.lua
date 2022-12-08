item_charge_pickup = class({})

function item_charge_pickup:OnSpellStart(keys)
	local caster = self:GetCaster()
	local team = caster:GetTeam()

	caster:EmitSound("Drop.EonStone")

	ScoreManager:OnGainCharge(team)

	self:Destroy()
end