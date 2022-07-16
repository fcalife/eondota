modifier_neutral_size = class({})

function modifier_neutral_size:IsHidden() return true end
function modifier_neutral_size:IsDebuff() return false end
function modifier_neutral_size:IsPurgable() return false end

function modifier_neutral_size:OnCreated(keys)
	if IsClient() then return end

	if keys.scale then self:SetStackCount(keys.scale) end
end

function modifier_neutral_size:DeclareFunctions()
	return { MODIFIER_PROPERTY_MODEL_SCALE }
end

function modifier_neutral_size:GetModifierModelScale()
	return self:GetStackCount()
end