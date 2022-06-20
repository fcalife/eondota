function Filters:ItemAddedToInventoryFilter(keys)
	if not keys.item_entindex_const then return true end
	if not keys.inventory_parent_entindex_const then return true end
	
	local item = EntIndexToHScript(keys.item_entindex_const)
	local inventory_owner = EntIndexToHScript(keys.inventory_parent_entindex_const)
	
	if (not item) or (not inventory_owner) then return true end

	local player_owner_id = inventory_owner:GetPlayerOwnerID()
	local player = (player_owner_id and PlayerResource:GetPlayer(player_owner_id)) or nil

	if item:GetAbilityName() == "item_eon_stone" then
		local stone = inventory_owner:FindItemInInventory("item_eon_stone")

		if stone then stone:SetCurrentCharges(stone:GetCurrentCharges() + 1) end
	end
end