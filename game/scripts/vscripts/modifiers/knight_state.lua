modifier_knight_state = class({})

function modifier_knight_state:IsHidden() return true end
function modifier_knight_state:IsDebuff() return false end
function modifier_knight_state:IsPurgable() return false end

function modifier_knight_state:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_seer_illusion.vpcf"
end

function modifier_knight_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
		}
	end
end

function modifier_knight_state:GetModifierProcAttack_Feedback(keys)
	if keys.target and (keys.target:GetUnitName() == "npc_dota_goodguys_tower1_mid" or keys.target:GetUnitName() == "npc_dota_badguys_tower1_mid") then
		keys.target:AddNewModifier(keys.attacker, nil, "modifier_stunned", {duration = 1.25})
	end
end