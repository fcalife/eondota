function Filters:OrderFilter(keys)
	table.deepprint(keys)
	if keys.units and keys.units["0"] and keys.entindex_target and keys.order_type and keys.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
		local container = EntIndexToHScript(keys.entindex_target)
		local item = container:GetContainedItem()
		local unit = EntIndexToHScript(keys.units["0"])

		if item:GetAbilityName() == "item_eon_stone" and unit:HasModifier("modifier_item_eon_stone_cooldown") then
			return false
		end
	end

	return true
end