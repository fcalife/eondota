function Filters:DamageFilter(keys)
	local attacker 	= false
	local victim 	= false
	local inflictor = false

	if keys.entindex_attacker_const then attacker = EntIndexToHScript(keys.entindex_attacker_const) end
	if keys.entindex_victim_const then victim = EntIndexToHScript(keys.entindex_victim_const) end
	if keys.entindex_inflictor_const then inflictor = EntIndexToHScript(keys.entindex_inflictor_const) end

	if (not attacker) or attacker:IsNull() then return false end
	if (not victim) or victim:IsNull() then return false end

	if victim:HasModifier("modifier_creep_footman") and attacker:IsRangedAttacker() then
		keys.damage = 0.75 * keys.damage
	end

	if attacker:HasModifier("modifier_creep_archer") and (victim:HasModifier("modifier_creep_knight") or victim:HasModifier("modifier_creep_golem")) then
		keys.damage = 2 * keys.damage
	end

	if attacker:HasModifier("modifier_creep_reaper") and victim:HasModifier("modifier_harvester_harvest") then
		keys.damage = 2 * keys.damage
	end

	if attacker:HasModifier("modifier_creep_golem") and (not victim:IsHero()) then
		keys.damage = 1.5 * keys.damage
	end

	return true
end