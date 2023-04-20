LinkLuaModifier("modifier_ball_charger", "abilities/ball_charger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ball_charger_max", "abilities/ball_charger", LUA_MODIFIER_MOTION_NONE)

ability_ball_charger = class({})

function ability_ball_charger:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Ball.Charge.Windup")

	return true
end

function ability_ball_charger:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Ball.Charge.Windup")
end

function ability_ball_charger:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("acceleration_duration")

	caster:AddNewModifier(caster, self, "modifier_ball_charger", {duration = duration})
end



modifier_ball_charger = class({})

function modifier_ball_charger:IsHidden() return false end
function modifier_ball_charger:IsDebuff() return false end
function modifier_ball_charger:IsPurgable() return false end

function modifier_ball_charger:OnCreated(keys)
	self:OnRefresh(keys)
end

function modifier_ball_charger:OnRefresh(keys)
	local ability = self:GetAbility()

	self.ms_penalty = ability:GetSpecialValueFor("ms_penalty")
	self.max_ms_bonus = ability:GetSpecialValueFor("max_ms_bonus")
	self.turn_rate = ability:GetSpecialValueFor("turn_rate")

	if IsClient() then return end

	self.acceleration_duration = ability:GetSpecialValueFor("acceleration_duration")
	self.max_speed_duration = ability:GetSpecialValueFor("max_speed_duration")
	self.elapsed_duration = 0
	self.steps = 0

	self:StartIntervalThink(0.1)
end

function modifier_ball_charger:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()
	if parent then parent:AddNewModifier(parent, self:GetAbility(), "modifier_ball_charger_max", {duration = self.max_speed_duration}) end
end

function modifier_ball_charger:OnIntervalThink()
	self.elapsed_duration = self.elapsed_duration + 0.1
	self.steps = self.steps + 1

	if self.steps % 5 == 0 then self:GetCaster():EmitSound("Ball.Charge.Step") end

	self:SetStackCount(100 * math.min(1, self.elapsed_duration / self.acceleration_duration))
end

function modifier_ball_charger:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_OVERRIDE
	}
end

function modifier_ball_charger:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_penalty + 0.01 * self:GetStackCount() * (self.max_ms_bonus - self.ms_penalty)
end

function modifier_ball_charger:GetModifierTurnRate_Override()
	return self.turn_rate
end



modifier_ball_charger_max = class({})

function modifier_ball_charger_max:IsHidden() return false end
function modifier_ball_charger_max:IsDebuff() return false end
function modifier_ball_charger_max:IsPurgable() return false end

function modifier_ball_charger_max:OnCreated(keys)
	self:OnRefresh(keys)
end

function modifier_ball_charger_max:OnRefresh(keys)
	local ability = self:GetAbility()

	self.max_ms_bonus = ability:GetSpecialValueFor("max_ms_bonus")
	self.turn_rate = ability:GetSpecialValueFor("turn_rate")
	self.status_resist = ability:GetSpecialValueFor("status_resist")

	if IsClient() then return end

	self.steps = 0

	self:StartIntervalThink(0.1)
end

function modifier_ball_charger_max:OnIntervalThink()
	self.steps = self.steps + 1

	if self.steps % 4 == 0 then self:GetCaster():EmitSound("Ball.Charge.Step") end

	local parent = self:GetParent()

	if parent then
		local enemies = FindUnitsInRadius(
			parent:GetTeam(),
			parent:GetAbsOrigin(),
			nil,
			250,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false
		)

		for _, enemy in pairs(enemies) do
			enemy:EmitSound("Ball.Blocker.Hit")

			if (not enemy:HasModifier("modifier_knockback")) then
				local knockback_origin = parent:GetAbsOrigin() + RandomVector(100)

				local knockback = {
					center_x = knockback_origin.x,
					center_y = knockback_origin.y,
					center_z = knockback_origin.z,
					knockback_duration = 0.25,
					knockback_distance = 400,
					knockback_height = 20,
					should_stun = 1,
					duration = 0.8
				}

				enemy:AddNewModifier(enemy, nil, "modifier_knockback", knockback)
			end
		end
	end
end

-- function modifier_ball_charger_max:OnDestroy()
-- 	if IsClient() then return end

-- 	local parent = self:GetParent()

-- 	if parent then
-- 		local stone = parent:FindItemInInventory("item_eon_stone")

-- 		if stone and stone:IsActivated() then
-- 			local modifier = parent:FindModifierByName("modifier_item_eon_stone")
-- 			if modifier then modifier:Bust() end
-- 		end
-- 	end
-- end

function modifier_ball_charger_max:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_OVERRIDE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
	}
end

function modifier_ball_charger_max:GetModifierMoveSpeedBonus_Percentage()
	return self.max_ms_bonus
end

function modifier_ball_charger_max:GetModifierTurnRate_Override()
	return self.turn_rate
end

function modifier_ball_charger_max:GetModifierStatusResistanceStacking()
	return self.status_resist
end