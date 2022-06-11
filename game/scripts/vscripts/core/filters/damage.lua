function Filters:DamageFilter(keys)
	local attacker 	= false
	local victim 	= false
	local inflictor = false

	if keys.entindex_attacker_const then attacker = EntIndexToHScript(keys.entindex_attacker_const) end
	if keys.entindex_victim_const then victim = EntIndexToHScript(keys.entindex_victim_const) end
	if keys.entindex_inflictor_const then inflictor = EntIndexToHScript(keys.entindex_inflictor_const) end

	if (not attacker) or attacker:IsNull() then return false end
	if (not victim) or victim:IsNull() then return false end
end