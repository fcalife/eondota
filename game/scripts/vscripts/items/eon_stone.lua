item_eon_stone = class({})

LinkLuaModifier("modifier_item_eon_stone", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)



function item_eon_stone:GetIntrinsicModifierName()
	return "modifier_item_eon_stone"
end

modifier_item_eon_stone = class({})

function modifier_item_eon_stone:IsHidden() return true end
function modifier_item_eon_stone:IsDebuff() return false end
function modifier_item_eon_stone:IsPurgable() return false end
function modifier_item_eon_stone:RemoveOnDeath() return true end
function modifier_item_eon_stone:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_eon_stone:OnCreated(keys)
	if IsClient() then return end

	self.reached_target = false
	self:StartIntervalThink(0.1)
	self:GetParent():EmitSound("Item.PickUpGemWorld")
end

function modifier_item_eon_stone:OnIntervalThink()
	local parent = self:GetParent()
	local parent_loc = parent and parent:GetAbsOrigin() or nil

	if parent_loc then
		if (parent_loc - EON_STONE_TARGET[parent:GetTeam()]):Length2D() < 275 then
			ScoreManager:Score(parent:GetTeam())
			self.reached_target = true
			self:GetAbility():Destroy()
		end
	end
end

function modifier_item_eon_stone:OnDestroy()
	if IsClient() then return end

	if (not self.reached_target) then
		CreateItemOnPositionForLaunch(self:GetParent():GetAbsOrigin(), CreateItem("item_eon_stone", nil, nil))
		self:GetAbility():Destroy()
	end
end