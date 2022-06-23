function Filters:ItemAddedToInventoryFilter(keys)
	if not keys.item_entindex_const then return true end
	if not keys.inventory_parent_entindex_const then return true end
	
	local item = EntIndexToHScript(keys.item_entindex_const)
	local inventory_owner = EntIndexToHScript(keys.inventory_parent_entindex_const)
	
	if (not item) or (not inventory_owner) then return true end

	local player_owner_id = inventory_owner:GetPlayerOwnerID()
	local player = (player_owner_id and PlayerResource:GetPlayer(player_owner_id)) or nil
end