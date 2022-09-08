modifier_goblin_item_tracker = class({})

function modifier_goblin_item_tracker:IsHidden() return true end
function modifier_goblin_item_tracker:IsDebuff() return false end
function modifier_goblin_item_tracker:IsPurgable() return false end
function modifier_goblin_item_tracker:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_goblin_item_tracker:DeclareFunctions()
	if IsServer() then return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST } end
end

function modifier_goblin_item_tracker:OnAbilityFullyCast(keys)
	local item = self:GetAbility()

	if keys.ability and item == keys.ability then
		local item_name = item:GetAbilityName()

		if item_name and item_name == "item_goblin_cyclone" and keys.target and keys.target == self:GetParent() then
			Timers:CreateTimer(2.5, function()
				item:SpendCharge()
			end)
		else
			item:SpendCharge()
		end
	end
end

function modifier_goblin_item_tracker:OnDestroy()
	if IsClient() then return end

	local item = self:GetAbility()

	if item and (not item:IsNull()) then
		local item_name = item:GetAbilityName()

		if item_name and item_name == "item_goblin_bkb" then
			item:OnSpellStart()
		end

		item:Destroy()
	end
end