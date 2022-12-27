item_fire_essence = class({})

LinkLuaModifier("modifier_item_fire_essence", "items/fire_essence", LUA_MODIFIER_MOTION_NONE)

function item_fire_essence:GetIntrinsicModifierName()
	return "modifier_item_fire_essence"
end

function item_fire_essence:CastFilterResultTarget(target)
	if target:HasModifier("modifier_firelord_state") then
		return UF_SUCCESS
	end

	return UF_FAIL_CUSTOM
end

function item_fire_essence:GetCustomCastErrorTarget(target)
	if target:HasModifier("modifier_firelord_state") then
		return UF_SUCCESS
	end

	return "#error_can_only_target_fire_guardian"
end

function item_fire_essence:OnSpellStart()
	local essence_count = self:GetCurrentCharges()

	ScoreManager:AddEssence(self:GetCaster(), essence_count)

	SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, NexusManager:GetNexusUnit(self:GetCaster():GetTeam()), essence_count, nil)

	self:Destroy()
end

function item_fire_essence:DropOnLocation(location)
	if self then
		EmitSoundOnLocationWithCaster(location, "Drop.EonStone", self:GetCaster())

		for i = 1, math.max(1, self:GetCurrentCharges()) do
			local essence_drop = CreateItem("item_fire_essence", nil, nil)
			local drop = CreateItemOnPositionForLaunch(self:GetCaster():GetAbsOrigin(), essence_drop)
			drop:SetModelScale(1.2)
			essence_drop:LaunchLoot(false, RandomInt(175, 300), 0.4, self:GetCaster():GetAbsOrigin() + RandomVector(120))
		end

		self:Destroy()
	end
end



modifier_item_fire_essence = class({})

function modifier_item_fire_essence:IsHidden() return true end
function modifier_item_fire_essence:IsDebuff() return false end
function modifier_item_fire_essence:IsPurgable() return false end
function modifier_item_fire_essence:RemoveOnDeath() return false end
function modifier_item_fire_essence:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_fire_essence:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and (parent:IsIllusion() or parent:IsClone()) then
		self:Destroy()
		return
	end
end

function modifier_item_fire_essence:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_DEATH
		}
	end
end

function modifier_item_fire_essence:OnDeath(keys)
	if (not IsServer()) or keys.unit ~= self:GetParent() then return end

	local essence = keys.unit:FindItemInInventory("item_fire_essence")

	if essence then essence:DropOnLocation(keys.unit:GetAbsOrigin()) end
end

item_blue_essence = class({})

item_red_essence = class({})