item_eon_stone = class({})

LinkLuaModifier("modifier_item_eon_stone", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)



function item_eon_stone:GetIntrinsicModifierName()
	return "modifier_item_eon_stone"
end

modifier_item_eon_stone = class({})

function modifier_item_eon_stone:IsHidden() return true end
function modifier_item_eon_stone:IsDebuff() return false end
function modifier_item_eon_stone:IsPurgable() return false end
function modifier_item_eon_stone:RemoveOnDeath() return false end
function modifier_item_eon_stone:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_eon_stone:OnCreated(keys)
	if IsClient() then return end

	self:GetParent():EmitSound("Item.PickUpGemWorld")
end

function modifier_item_eon_stone:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_DEATH } end
end

function modifier_item_eon_stone:OnDeath(keys)
	if (not IsServer()) or keys.unit ~= self:GetParent() then return end

	local stone = keys.unit:FindItemInInventory("item_eon_stone")
	local charges = stone:GetCurrentCharges()

	for i = 1, charges do
		GameManager:SpawnEonStone(self:GetParent() + RandomVector(300))
	end

	stone:Destroy()
end