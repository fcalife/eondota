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

	if position.z < 350 and (not parent:HasModifier("modifier_thrown_out")) then
		KnockbackArena:OnExitRing(parent)
	end
end

function modifier_hero_base_state:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_hero_base_state:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
	}
end

function modifier_hero_base_state:GetModifierIgnoreCastAngle()
	return 1
end



modifier_thrown_out = class({})

function modifier_thrown_out:IsHidden() return true end
function modifier_thrown_out:IsDebuff() return false end
function modifier_thrown_out:IsPurgable() return false end
function modifier_thrown_out:RemoveOnDeath() return false end
function modifier_thrown_out:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_thrown_out:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_FLYING] = true,
	}
end

function modifier_thrown_out:OnDestroy(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	KnockbackArena:OnThrowOutStatusEnd(parent)
end