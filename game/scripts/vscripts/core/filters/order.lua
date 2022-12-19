function Filters:OrderFilter(keys)
	local target = EntIndexToHScript(keys.entindex_target)
	local ability = EntIndexToHScript(keys.entindex_ability)
	local unit = (keys.units["0"] and EntIndexToHScript(keys.units["0"])) or nil

	if unit and target and unit.GetTeam and target.HasModifier then
		if unit:GetTeam() ~= DOTA_TEAM_NEUTRALS and target:HasModifier("modifier_neutral_building_state") then
			if keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
				local target_loc = target:GetAbsOrigin()
				local distance = (unit:GetAbsOrigin() - target_loc):Length2D()

				if distance < 400 then
					if target.building_slot then target.building_slot:ShowBuildingMenu(unit) end
				end

				keys.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				keys.position_x = target_loc.x
				keys.position_y = target_loc.y
				keys.position_z = target_loc.z
			end
		end
	end

	return true
end