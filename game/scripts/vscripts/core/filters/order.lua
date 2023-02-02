function Filters:OrderFilter(keys)
	local units = keys.units
	local order_type = keys.order_type

	if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
		local ability = EntIndexToHScript(keys.entindex_ability)
		local location = Vector(keys.position_x, keys.position_y, keys.position_z)

		if ability and location and ability:GetAbilityName() == "void_spirit_astral_step" then
			if location:Length2D() > MAX_CAST_RADIUS then
				local new_location = MAX_CAST_RADIUS * location:Normalized()

				keys.position_x = new_location.x
				keys.position_y = new_location.y
				keys.position_z = new_location.z
			end
		end
	end

	return true
end