IGNORE_PICKUP_ITEMS = {}
IGNORE_PICKUP_ITEMS["item_neutral_gold"] = true
IGNORE_PICKUP_ITEMS["item_dragon_drop_frenzy"] = true
IGNORE_PICKUP_ITEMS["item_dragon_drop_arcane"] = true

function Filters:OrderFilter(keys)
	if keys.units and keys.units["0"] and keys.entindex_target and keys.order_type and keys.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
		local container = EntIndexToHScript(keys.entindex_target)
		if container then
			local item = container:GetContainedItem()
			local unit = EntIndexToHScript(keys.units["0"])
			local item_name = item:GetAbilityName()
			local player = unit and unit:GetPlayerOwner() or nil

			if item_name == "item_eon_stone" and unit:HasModifier("modifier_item_eon_stone_cooldown") then
				if player then CustomGameEventManager:Send_ServerToPlayer(player, "display_custom_error", {message = "Cannot pick the stone up yet!"}) end

				local new_position = container:GetAbsOrigin()

				keys.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				keys.position_x = new_position.x
				keys.position_y = new_position.y
				keys.position_z = new_position.z
			end

			if IGNORE_PICKUP_ITEMS[item_name] then
				local new_position = container:GetAbsOrigin()

				keys.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				keys.position_x = new_position.x
				keys.position_y = new_position.y
				keys.position_z = new_position.z
			end
		end
	end

	if keys.units and keys.units["0"] and keys.order_type and keys.order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		local unit = EntIndexToHScript(keys.units["0"])
		local player = unit and unit:GetPlayerOwner() or nil

		if unit and unit:HasModifier("modifier_damage_taken") then
			if player then CustomGameEventManager:Send_ServerToPlayer(player, "display_custom_error", {message = "Can't use the shop while in combat!"}) end

			return false
		end
	end

	return true
end