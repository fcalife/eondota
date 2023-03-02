function CDOTA_BaseNPC:IsMonkeyClone()
	return (self:HasModifier("modifier_monkey_king_fur_army_soldier") or self:HasModifier("modifier_wukongs_command_warrior"))
end

function CDOTA_BaseNPC:IsMainHero()
	return self and (not self:IsNull()) and self:IsRealHero() and (not self:IsTempestDouble()) and (not self:IsMonkeyClone())
end

-- Has Aghanim's Shard
function CDOTA_BaseNPC:HasShard()
	if not self or self:IsNull() then return end

	return self:HasModifier("modifier_item_aghanims_shard")
end

-- Talent handling
function CDOTA_BaseNPC:HasTalent(talent_name)
	if not self or self:IsNull() then return end

	local talent = self:FindAbilityByName(talent_name)
	if talent and talent:GetLevel() > 0 then return true end
end

function CDOTA_BaseNPC:GetTalentValue(talent_name, key)
	if self:HasTalent(talent_name) then
		local value_name = key or "value"
		return self:FindAbilityByName(talent_name):GetSpecialValueFor(value_name)
	end

	return 0
end

function CDOTA_BaseNPC:GetPositionOffensiveValue()
	local position = self:GetAbsOrigin()
	local team = self:GetTeam()

	if (not ScoreManager.nexus) then return 0 end

	local center_line = (ScoreManager.nexus[ENEMY_TEAM[team]]:GetAbsOrigin() - ScoreManager.nexus[team]:GetAbsOrigin()):Normalized()

	local distance = DotProduct(position, center_line)

	if math.abs(distance) <= OFFENSIVE_VALUE_DEADZONE_RADIUS then
		return 0
	elseif math.abs(distance) <= OFFENSIVE_VALUE_CENTER_LIMIT then
		return (distance / math.abs(distance)) * (math.abs(distance) - OFFENSIVE_VALUE_DEADZONE_RADIUS) / (OFFENSIVE_VALUE_CENTER_LIMIT - OFFENSIVE_VALUE_DEADZONE_RADIUS)
	else
		return distance / math.abs(distance)
	end
end

function CDOTA_BaseNPC:ExecutePathOrders(path)
	local unit_id = self:entindex()

	for _, destination in ipairs(path) do
		ExecuteOrderFromTable({
			unitIndex = unit_id,
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = destination,
			Queue = true
		})
	end
end