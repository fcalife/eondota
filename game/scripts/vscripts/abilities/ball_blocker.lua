LinkLuaModifier("modifier_ball_blocker_tracker", "abilities/ball_blocker", LUA_MODIFIER_MOTION_NONE)

ability_ball_blocker = class({})

function ability_ball_blocker:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Ball.Blocker.Windup")

	return true
end

function ability_ball_blocker:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Ball.Blocker.Windup")
end

function ability_ball_blocker:OnSpellStart()
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

	caster:AddNewModifier(caster, self, "modifier_ball_blocker_tracker", {duration = duration})

	caster:EmitSound("Ball.Blocker.Cast")
end



modifier_ball_blocker_tracker = class({})

function modifier_ball_blocker_tracker:IsHidden() return true end
function modifier_ball_blocker_tracker:IsDebuff() return false end
function modifier_ball_blocker_tracker:IsPurgable() return false end

function modifier_ball_blocker_tracker:OnCreated(keys)
	if IsClient() then return end

	self.hit_enemy = false

	self:StartIntervalThink(0.03)
end

function modifier_ball_blocker_tracker:OnDestroy()
	if IsClient() then return end

	if (not self.hit_enemy) then
		self:GetParent():EmitSound("Ball.Blocker.Selfstun")
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_stunned", {duration = 0.5})
	end
end

function modifier_ball_blocker_tracker:OnIntervalThink()
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

		for _, enemy in pairs(enemies) do
			self.hit_enemy = true

			enemy:EmitSound("Ball.Blocker.Hit")

			local stone = enemy:FindItemInInventory("item_eon_stone")

			if stone and stone:IsActivated() then
				local modifier = enemy:FindModifierByName("modifier_item_eon_stone")
				if modifier then modifier:Bust() end
			end

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

function modifier_ball_blocker_tracker:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_ROOTED] = true,
		}
	end
end