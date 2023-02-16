function Filters:DamageFilter(keys)
	local attacker 	= false
	local victim 	= false
	local inflictor = false

	if keys.entindex_attacker_const then attacker = EntIndexToHScript(keys.entindex_attacker_const) end
	if keys.entindex_victim_const then victim = EntIndexToHScript(keys.entindex_victim_const) end
	if keys.entindex_inflictor_const then inflictor = EntIndexToHScript(keys.entindex_inflictor_const) end

	if (not attacker) or attacker:IsNull() then return false end
	if (not victim) or victim:IsNull() then return false end

	if victim:HasModifier("modifier_brawler_reflect") then
		victim:RemoveModifierByName("modifier_brawler_reflect")

		ApplyDamage({attacker = victim, victim = attacker, damage = keys.damage, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION})

		return false
	end

	if victim:HasModifier("modifier_powerup_shield") then
		victim:RemoveModifierByName("modifier_powerup_shield")

		return false
	end

	if victim:HasModifier("modifier_tank_shield") then
		keys.damage = math.max(0, keys.damage - 1)
		victim:RemoveModifierByName("modifier_tank_shield")
	end

	return true
end