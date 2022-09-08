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
	if keys.target then
		if keys.target:GetUnitName() == "npc_dota_goodguys_tower1_mid" or keys.target:GetUnitName() == "npc_dota_badguys_tower1_mid" then
			keys.target:AddNewModifier(keys.attacker, nil, "modifier_stunned", {duration = 1.25})
		end
		if keys.target:GetUnitName() == "npc_eon_nexus" then
			local modifier = keys.target:AddNewModifier(keys.attacker, nil, "modifier_knight_nexus_debuff", {duration = 5})
			if modifier then modifier:SetStackCount(math.min(65, modifier:GetStackCount() + 4)) end
		end
	end
end



modifier_samurai_state = class({})

function modifier_samurai_state:IsHidden() return true end
function modifier_samurai_state:IsDebuff() return false end
function modifier_samurai_state:IsPurgable() return false end

function modifier_samurai_state:GetStatusEffectName()
	return "particles/samurai/status_effect_samurai.vpcf"
end

function modifier_samurai_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
		}
	end
end

function modifier_samurai_state:GetModifierProcAttack_Feedback(keys)
	if keys.target then
		if keys.target:GetUnitName() == "npc_dota_goodguys_tower1_mid" or keys.target:GetUnitName() == "npc_dota_badguys_tower1_mid" then
			keys.target:AddNewModifier(keys.attacker, nil, "modifier_stunned", {duration = 1.25})
		end
		if keys.target:GetUnitName() == "npc_eon_nexus" then
			local modifier = keys.target:AddNewModifier(keys.attacker, nil, "modifier_knight_nexus_debuff", {duration = 5})
			if modifier then modifier:SetStackCount(math.min(65, modifier:GetStackCount() + 4)) end
		end
	end
end



modifier_knight_nexus_debuff = class({})

function modifier_knight_nexus_debuff:IsHidden() return false end
function modifier_knight_nexus_debuff:IsDebuff() return true end
function modifier_knight_nexus_debuff:IsPurgable() return false end

function modifier_knight_nexus_debuff:GetTexture()
	return "slardar_amplify_damage"
end

function modifier_knight_nexus_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_slardar_amp_damage.vpcf"
end

function modifier_knight_nexus_debuff:GetEffectName()
	return "particles/econ/items/slardar/slardar_ti10_head/slardar_ti10_broken_shield.vpcf"
end

function modifier_knight_nexus_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_knight_nexus_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_knight_nexus_debuff:GetModifierIncomingDamage_Percentage()
	return self:GetStackCount()
end