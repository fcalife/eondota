modifier_boss_state_thinker = class({})

function modifier_boss_state_thinker:IsHidden() return true end
function modifier_boss_state_thinker:IsDebuff() return false end
function modifier_boss_state_thinker:IsPurgable() return false end

function modifier_boss_state_thinker:OnCreated(keys)
	if IsClient() then return end

	self.origin = self:GetParent():GetAbsOrigin()

	self:StartIntervalThink(0.5)
end

function modifier_boss_state_thinker:OnIntervalThink()
	local parent = self:GetParent()

	if (not parent) or parent:IsNull() or (not parent:IsAlive()) then return end
	
	local location = parent:GetAbsOrigin()

	if (location - self.origin):Length2D() > 1800 then
		parent:Heal(99999, nil)

		ExecuteOrderFromTable({
			UnitIndex = parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = self.origin,
			Queue = false,
		})
	elseif (location - self.origin):Length2D() < 300 then
		ExecuteOrderFromTable({
			UnitIndex = parent:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = location,
			Queue = false,
		})
	end
end



modifier_boss_toughness = class({})

function modifier_boss_toughness:IsHidden() return true end
function modifier_boss_toughness:IsDebuff() return false end
function modifier_boss_toughness:IsPurgable() return false end

function modifier_boss_toughness:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_MIN_HEALTH
	}
end

function modifier_boss_toughness:GetModifierStatusResistance()
	return 65
end

function modifier_boss_toughness:GetMinHealth()
	return self:GetParent():GetHealth() - 100
end



modifier_boss_state_roaming_thinker = class({})

function modifier_boss_state_roaming_thinker:IsHidden() return true end
function modifier_boss_state_roaming_thinker:IsDebuff() return false end
function modifier_boss_state_roaming_thinker:IsPurgable() return false end

function modifier_boss_state_roaming_thinker:OnCreated(keys)
	if IsClient() then return end

	local boss = self:GetParent().boss

	if boss and boss.path then
		self.path = table.shuffled(boss.path)
		self:StartIntervalThink(20)
	end
end

function modifier_boss_state_roaming_thinker:OnIntervalThink()
	if (not self.path) then return end

	local destination = self.path[RandomInt(1, #self.path)]

	ExecuteOrderFromTable({
		UnitIndex = self:GetParent():entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = destination,
		Queue = false,
	})
end