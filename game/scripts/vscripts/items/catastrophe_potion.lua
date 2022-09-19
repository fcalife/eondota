item_catastrophe_potion = class({})

function item_catastrophe_potion:OnSpellStart(keys)
	if IsClient() then return end

	local caster = self:GetCaster()

	caster:EmitSound("DOTA_Item.ClarityPotion.Activate")

	caster:AddNewModifier(caster, nil, "modifier_shrine_buff_catastrophe", {duration = self:GetSpecialValueFor("duration")})

	self:SpendCharge()
end