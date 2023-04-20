LinkLuaModifier("modifier_ball_runner_tracker", "abilities/ball_runner", LUA_MODIFIER_MOTION_NONE)

ability_ball_runner = class({})

function ability_ball_runner:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Ball.Runner.Windup")

	return true
end

function ability_ball_runner:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Ball.Runner.Windup")
end

function ability_ball_runner:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local distance = self:GetSpecialValueFor("distance")
	local speed = self:GetSpecialValueFor("speed")
	local duration = distance / speed

	local knockback_origin = caster:GetAbsOrigin() + 100 * (caster:GetAbsOrigin() - target):Normalized()

	local knockback = {
		center_x = knockback_origin.x,
		center_y = knockback_origin.y,
		center_z = knockback_origin.z,
		knockback_duration = duration,
		knockback_distance = distance,
		knockback_height = 0,
		should_stun = 1,
		duration = duration
	}

	caster:RemoveModifierByName("modifier_knockback")
	caster:AddNewModifier(caster, nil, "modifier_knockback", knockback)

	caster:AddNewModifier(caster, self, "modifier_ball_runner_tracker", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_item_eon_stone_no_overcharge", {duration = duration})

	caster:StopSound("Ball.Runner.Cast")
end



modifier_ball_runner_tracker = class({})

function modifier_ball_runner_tracker:IsHidden() return true end
function modifier_ball_runner_tracker:IsDebuff() return false end
function modifier_ball_runner_tracker:IsPurgable() return false end

function modifier_ball_runner_tracker:OnCreated(keys)
	if IsClient() then return end

	self:StartIntervalThink(0.03)
end

function modifier_ball_runner_tracker:OnIntervalThink()
	if IsClient() then return end

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

		if #enemies > 0 then
			parent:RemoveModifierByName("modifier_knockback")
			self:Destroy()
		end
	end
end

function modifier_ball_runner_tracker:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_ROOTED] = true,
		}
	end
end