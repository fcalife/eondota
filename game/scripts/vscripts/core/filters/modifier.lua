function Filters:ModifierFilter(keys)
	local modifier_name = keys.name_const

	local caster	= false
	local parent	= false
	local ability	= false

	if keys.entindex_caster_const then caster = EntIndexToHScript(keys.entindex_caster_const) end
	if keys.entindex_parent_const then parent = EntIndexToHScript(keys.entindex_parent_const) end
	if keys.entindex_ability_const then ability = EntIndexToHScript(keys.entindex_ability_const) end

	if parent and parent:HasModifier("modifier_boss_health_controller") then
		if modifier_name and (modifier_name == "modifier_earthshaker_aftershock" or modifier_name == "modifier_stunned") then
			return false
		end
	end

	return true
end