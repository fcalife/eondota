function Filters:InventoryFilter(keys)
	if not keys.item_entindex_const then return true end
	if not keys.inventory_parent_entindex_const then return true end
	
	local item = EntIndexToHScript(keys.item_entindex_const)
	local inventory_owner = EntIndexToHScript(keys.inventory_parent_entindex_const)
	
	if (not item) or (not inventory_owner) then return true end

	local player_owner_id = inventory_owner:GetPlayerOwnerID()
	local player = (player_owner_id and PlayerResource:GetPlayer(player_owner_id)) or nil

	local item_name = item:GetAbilityName()

	if item_name then
		if item_name == "item_dev_blink" then
			keys.suggested_slot = DOTA_ITEM_SLOT_3
		end
	end

	-- if item.is_goblin_item then
	-- 	local free_slot = false

	-- 	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
	-- 		if (not inventory_owner:GetItemInSlot(i)) then free_slot = true end
	-- 	end

	-- 	if free_slot then inventory_owner:AddNewModifier(inventory_owner, item, "modifier_goblin_item_tracker", {duration = 60}) end
	-- end

	return true
end