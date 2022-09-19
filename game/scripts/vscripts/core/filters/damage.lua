function Filters:DamageFilter(keys)
	local attacker 	= false
	local victim 	= false
	local inflictor = false

	if keys.entindex_attacker_const then attacker = EntIndexToHScript(keys.entindex_attacker_const) end
	if keys.entindex_victim_const then victim = EntIndexToHScript(keys.entindex_victim_const) end
	if keys.entindex_inflictor_const then inflictor = EntIndexToHScript(keys.entindex_inflictor_const) end

	if (not attacker) or attacker:IsNull() then return false end
	if (not victim) or victim:IsNull() then return false end

	if victim.GetUnitName and attacker.GetUnitName and victim:GetUnitName() == "npc_dota_goodguys_tower1_mid" or victim:GetUnitName() == "npc_dota_badguys_tower1_mid" then
		if attacker:GetUnitName() == "npc_eon_knight_ally" or attacker:GetUnitName() == "npc_eon_trio_knight_ally" then
			keys.damage = 0.4 * keys.damage
		end
	end

	if victim.HasModifier then
		if victim:HasModifier("modifier_teleporting") or victim:HasModifier("modifier_underlord_portal_warp_channel") then
			victim:InterruptChannel()
		end
	end

	return true
end