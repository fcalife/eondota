modifier_speed_bonus = class({})

function modifier_speed_bonus:IsHidden() return false end
function modifier_speed_bonus:IsDebuff() return false end
function modifier_speed_bonus:IsPurgable() return false end

function modifier_speed_bonus:GetTexture()
	return "windrunner_windrun"
end

function modifier_speed_bonus:GetEffectName()
	return "particles/speed_buff.vpcf"
end

function modifier_speed_bonus:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_speed_bonus:OnCreated()
	if IsClient() then return end

	self:GetParent():EmitSound("Speed.Boost")
end

function modifier_speed_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_speed_bonus:GetModifierMoveSpeedBonus_Percentage()
	return self:GetRemainingTime() * 20
end