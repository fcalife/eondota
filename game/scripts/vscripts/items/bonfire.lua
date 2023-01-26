item_bonfire = class({})

LinkLuaModifier("modifier_bonfire_healing_aura", "items/bonfire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonfire_vision_aura", "items/bonfire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonfire_buff", "items/bonfire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonfire_vision", "items/bonfire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonfire_healing_prevention", "items/bonfire", LUA_MODIFIER_MOTION_NONE)

function item_bonfire:OnSpellStart(keys)
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_bonfire_healing_aura", {duration = self:GetSpecialValueFor("max_duration")})
	caster:AddNewModifier(caster, self, "modifier_bonfire_vision_aura", {duration = self:GetSpecialValueFor("max_duration")})

	self.healing_pfx = ParticleManager:CreateParticle("particles/items_fx/seeds_of_serenity.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.healing_pfx, 0, caster:GetAbsOrigin() + Vector(0, 0, 20))
	ParticleManager:SetParticleControl(self.healing_pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
end

function item_bonfire:OnChannelFinish(interrupted)
	local caster = self:GetCaster()

	caster:RemoveModifierByName("modifier_bonfire_healing_aura")
	caster:RemoveModifierByName("modifier_bonfire_vision_aura")

	if self.healing_pfx then
		ParticleManager:DestroyParticle(self.healing_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.healing_pfx)
	end
end



modifier_bonfire_healing_aura = class({})

function modifier_bonfire_healing_aura:IsHidden() return true end
function modifier_bonfire_healing_aura:IsDebuff() return false end
function modifier_bonfire_healing_aura:IsPurgable() return false end

function modifier_bonfire_healing_aura:IsAura() return true end
function modifier_bonfire_healing_aura:GetModifierAura() return "modifier_bonfire_buff" end
function modifier_bonfire_healing_aura:GetAuraRadius() return 400 end
function modifier_bonfire_healing_aura:GetAuraDuration() return 0.1 end
function modifier_bonfire_healing_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_bonfire_healing_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_bonfire_healing_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end
function modifier_bonfire_healing_aura:GetAuraEntityReject(unit)
	return unit:HasModifier("modifier_bonfire_healing_prevention")
end



modifier_bonfire_vision_aura = class({})

function modifier_bonfire_vision_aura:IsHidden() return true end
function modifier_bonfire_vision_aura:IsDebuff() return false end
function modifier_bonfire_vision_aura:IsPurgable() return false end

function modifier_bonfire_vision_aura:IsAura() return true end
function modifier_bonfire_vision_aura:GetModifierAura() return "modifier_bonfire_vision" end
function modifier_bonfire_vision_aura:GetAuraRadius() return 3000 end
function modifier_bonfire_vision_aura:GetAuraDuration() return 0.1 end
function modifier_bonfire_vision_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_bonfire_vision_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_bonfire_vision_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_bonfire_vision_aura:GetAuraEntityReject(unit)
	return unit:GetTeam() == DOTA_TEAM_CUSTOM_3
end



modifier_bonfire_buff = class({})

function modifier_bonfire_buff:IsHidden() return self:GetParent():HasModifier("modifier_bonfire_healing_prevention") end
function modifier_bonfire_buff:IsDebuff() return false end
function modifier_bonfire_buff:IsPurgable() return false end

function modifier_bonfire_buff:GetTexture() return "rune_regen" end

function modifier_bonfire_buff:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
		}
	else
		return {
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
		}
	end
end

function modifier_bonfire_buff:GetModifierConstantHealthRegen()
	return 0.07 * self:GetParent():GetMaxHealth()
end

function modifier_bonfire_buff:GetModifierConstantManaRegen()
	return 0.07 * self:GetParent():GetMaxMana()
end

function modifier_bonfire_buff:OnTakeDamage(keys)
	if keys.unit == self:GetCaster() then
		keys.unit:InterruptChannel()
	end
end



modifier_bonfire_vision = class({})

function modifier_bonfire_vision:IsHidden() return true end
function modifier_bonfire_vision:IsDebuff() return false end
function modifier_bonfire_vision:IsPurgable() return false end

function modifier_bonfire_vision:OnCreated(keys)
	if IsClient() then return end

	self.vision = AddFOWViewer(self:GetParent():GetTeam(), self:GetCaster():GetAbsOrigin(), 400, 15.1, false)
end

function modifier_bonfire_vision:OnDestroy()
	if IsClient() then return end

	if self.vision then RemoveFOWViewer(self:GetParent():GetTeam(), self.vision) end
end



modifier_bonfire_healing_prevention = class({})

function modifier_bonfire_healing_prevention:IsHidden() return true end
function modifier_bonfire_healing_prevention:IsDebuff() return true end
function modifier_bonfire_healing_prevention:IsPurgable() return false end