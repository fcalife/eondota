item_flag = class({})

LinkLuaModifier("modifier_item_flag", "items/flag", LUA_MODIFIER_MOTION_NONE)

function item_flag:GetIntrinsicModifierName()
	return "modifier_item_flag"
end

function item_flag:DropOnLocation(location)
	if self then
		EmitSoundOnLocationWithCaster(location, "Drop.EonStone", self:GetCaster())

		table.insert(Flags.flags, Flag(location))

		self:Destroy()
	end
end



modifier_item_flag = class({})

function modifier_item_flag:IsHidden() return false end
function modifier_item_flag:IsDebuff() return true end
function modifier_item_flag:IsPurgable() return false end
function modifier_item_flag:RemoveOnDeath() return false end
function modifier_item_flag:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
function modifier_item_flag:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_flag:GetEffectName()
	return "particles/eon_carrier.vpcf"
end

function modifier_item_flag:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_flag:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and (parent:IsIllusion() or parent:IsClone()) then
		self:Destroy()
		return
	end

	parent:EmitSound("Drop.EonStone")

	local flag_item = self:GetAbility()
	if flag_item and flag_item.dummy then flag_item.dummy:Destroy() end

	self.minimap_dummy = CreateUnitByName("npc_flag_dummy", parent:GetAbsOrigin(), false, nil, nil, parent:GetTeam())
	self.minimap_dummy:AddNewModifier(self.minimap_dummy, nil, "modifier_dummy_state", {})

	self:StartIntervalThink(0.03)
end

function modifier_item_flag:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and (parent:IsIllusion() or parent:IsClone()) then return end

	if self.minimap_dummy and (not self.minimap_dummy:IsNull()) then self.minimap_dummy:Destroy() end
end

function modifier_item_flag:OnIntervalThink()
	local parent = self:GetParent()

	if self.minimap_dummy and (not self.minimap_dummy:IsNull()) then self.minimap_dummy:SetAbsOrigin(parent:GetAbsOrigin()) end
end

function modifier_item_flag:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = false,
		[MODIFIER_STATE_INVULNERABLE] = false,
		[MODIFIER_STATE_MAGIC_IMMUNE] = false,
		[MODIFIER_STATE_UNTARGETABLE] = false,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true
	}
end

function modifier_item_flag:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
			MODIFIER_EVENT_ON_DEATH
		}
	else
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
		}
	end
end

function modifier_item_flag:GetModifierMoveSpeedBonus_Percentage()
	return -15
end

function modifier_item_flag:GetModifierInvisibilityLevel()
	return 0
end

function modifier_item_flag:GetModifierProvidesFOWVision()
	return 1
end

function modifier_item_flag:OnDeath(keys)
	if (not IsServer()) or keys.unit ~= self:GetParent() then return end

	local flag = keys.unit:FindItemInInventory("item_flag")

	if flag then flag:DropOnLocation(keys.unit:GetAbsOrigin()) end
end