function Filters:OrderFilter(keys)
	if keys.units and keys.units["0"] and keys.entindex_target and keys.order_type and keys.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
		local container = EntIndexToHScript(keys.entindex_target)
		if container then
			local item = container:GetContainedItem()
			local unit = EntIndexToHScript(keys.units["0"])

			if item:GetAbilityName() == "item_eon_stone" and unit:HasModifier("modifier_item_eon_stone_cooldown") then
				return false
			end

			if item:GetAbilityName() == "item_neutral_gold" then
				local new_position = container:GetAbsOrigin()

				keys.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				keys.position_x = new_position.x
				keys.position_y = new_position.y
				keys.position_z = new_position.z
			end
		end
	end

	return true
end