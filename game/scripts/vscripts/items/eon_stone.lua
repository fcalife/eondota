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

function modifier_item_eon_stone:GetEffectName()
	return "particles/eon_carrier.vpcf"
end

function modifier_item_eon_stone:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_eon_stone:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	parent:EmitSound("Item.PickUpGemWorld")

	GameManager:OnEonStonePickedUp(parent:GetAbsOrigin())
end

function modifier_item_eon_stone:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
			MODIFIER_EVENT_ON_DEATH
		}
	else
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
		}
	end
end

function modifier_item_eon_stone:GetModifierMoveSpeedBonus_Percentage()
	return 0
end

function modifier_item_eon_stone:GetModifierProvidesFOWVision()
	return 1
end

function modifier_item_eon_stone:OnDeath(keys)
	if (not IsServer()) or keys.unit ~= self:GetParent() then return end

	local stone = keys.unit:FindItemInInventory("item_eon_stone")

	if stone then
		keys.unit:EmitSound("Item.PickUpGemWorld")
		GameManager:SpawnEonStone(self:GetParent():GetAbsOrigin())
	end

	stone:Destroy()
end