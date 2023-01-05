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