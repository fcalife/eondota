modifier_hero_base_state = class({})

function modifier_hero_base_state:IsHidden() return true end
function modifier_hero_base_state:IsDebuff() return false end
function modifier_hero_base_state:IsPurgable() return false end
function modifier_hero_base_state:RemoveOnDeath() return false end
function modifier_hero_base_state:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_hero_base_state:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if (not IsInToolsMode()) then parent:AddNewModifier(parent, nil, "modifier_stunned", {duration = 15}) end

	self:StartIntervalThink(0.03)
end

function modifier_hero_base_state:OnIntervalThink()
	local parent = self:GetParent()
	local position = parent:GetAbsOrigin()
	local team = parent:GetTeam()

	if position.x > 0 and team == DOTA_TEAM_GOODGUYS then
		FindClearSpaceForUnit(parent, Vector(-100, position.y, position.z), true)
	elseif position.x < 0 and team == DOTA_TEAM_BADGUYS then
		FindClearSpaceForUnit(parent, Vector(100, position.y, position.z), true)
	end
end

function modifier_hero_base_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
	}
end

function modifier_hero_base_state:GetModifierIgnoreCastAngle()
	return 1
end



modifier_duck = class({})

function modifier_duck:IsHidden() return true end
function modifier_duck:IsDebuff() return false end
function modifier_duck:IsPurgable() return false end

function modifier_duck:OnCreated(keys)
	if IsClient() then return end

	self.speed = keys.speed
	self:SetStackCount(self.speed - 200)

	self.points = keys.points

	local parent = self:GetParent()
	local team = parent:GetTeam()
	local position = parent:GetAbsOrigin()

	if team == DOTA_TEAM_BADGUYS then
		if position.x > -500 then
			self.destination = Vector((-1) * EDGE_DUCK, position.y, 0)
		else
			self.destination = Vector((-1) * MIDDLE_DUCK, position.y, 0)
		end
	else
		if position.x > 500 then
			self.destination = Vector(MIDDLE_DUCK, position.y, 0)
		else
			self.destination = Vector(EDGE_DUCK, position.y, 0)
		end
	end

	self:StartIntervalThink(0.2)
end

function modifier_duck:OnIntervalThink()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and self.destination then
		ExecuteOrderFromTable({
			unitIndex = parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = self.destination,
			Queue = false
		})

		local position = parent:GetAbsOrigin()

		if math.abs(position.x - self.destination.x) < 10 then
			parent:AddNoDraw()
			parent:Kill(nil, parent)
		end
	end
end

function modifier_duck:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_UNSLOWABLE] = true,
	}
end

function modifier_duck:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_DEATH,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		}
	else
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		}
	end
end

function modifier_duck:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount()
end

function modifier_duck:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_duck:OnDeath(keys)
	if keys.unit == self:GetParent() and keys.unit ~= keys.attacker then
		Ducks:OnDuckDied(keys.attacker, keys.unit, self.points)
	end
end