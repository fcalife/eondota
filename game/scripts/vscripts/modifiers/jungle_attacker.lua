modifier_jungle_attacker = class({})

function modifier_jungle_attacker:IsHidden() return true end
function modifier_jungle_attacker:IsDebuff() return false end
function modifier_jungle_attacker:IsPurgable() return false end

function modifier_jungle_attacker:GetStatusEffectName()
	return "particles/samurai/status_effect_samurai.vpcf"
end

function modifier_jungle_attacker:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
		}
	end
end

function modifier_jungle_attacker:GetModifierProcAttack_Feedback(keys)
	if keys.target then
		if keys.target.camp and keys.target.camp.creeps and keys.target:GetLevel() < 30 then
			keys.target:EmitSound("Hero_Techies.Suicide")

			local suicide_pfx = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(suicide_pfx, 0, keys.target:GetAbsOrigin())
			ParticleManager:SetParticleControl(suicide_pfx, 1, Vector(100, 0, 0))
			ParticleManager:SetParticleControl(suicide_pfx, 2, Vector(550, 0, 0))
			ParticleManager:SetParticleControl(suicide_pfx, 15, Vector(192, 128, 255))
			ParticleManager:SetParticleControl(suicide_pfx, 16, Vector(1, 0, 0))
			ParticleManager:ReleaseParticleIndex(suicide_pfx)

			for _, creep in pairs(keys.target.camp.creeps) do
				creep:Kill(nil, keys.attacker)
			end

			keys.attacker:Kill(nil, keys.attacker)
		end
	end
end