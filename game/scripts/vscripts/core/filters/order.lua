local instant_turn_orders = {
	[DOTA_UNIT_ORDER_MOVE_TO_POSITION] = true,
	[DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
	[DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
	[DOTA_UNIT_ORDER_DROP_ITEM] = true,
	[DOTA_UNIT_ORDER_GIVE_ITEM] = true,
	[DOTA_UNIT_ORDER_PICKUP_ITEM] = true,
	[DOTA_UNIT_ORDER_PICKUP_RUNE] = true
}

function Filters:ExecuteOrderFilter(keys)
	local order_type = keys.order_type

	local player_id = keys.issuer_player_id_const
	if not player_id then return true end

	local player = PlayerResource:GetPlayer(player_id)
	if not player then return true end

	local target = keys.entindex_target ~= 0 and EntIndexToHScript(keys.entindex_target) or nil
	local ability = keys.entindex_ability ~= 0 and EntIndexToHScript(keys.entindex_ability) or nil

	local unit = false
	if keys.units and keys.units["0"] then unit = EntIndexToHScript(keys.units["0"]) end

	if (not unit) or unit:IsNull() then return true end

	if order_type and instant_turn_orders[order_type] then
		local target_loc = (target and target:GetAbsOrigin()) or keys.target

		if target_loc then
			unit:SetForwardVector((target_loc - unit:GetAbsOrigin()):Normalized())
		end
	end
end