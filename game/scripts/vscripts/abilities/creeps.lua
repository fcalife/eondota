creep_magic = class({})

LinkLuaModifier("modifier_creep_magic_aura", "abilities/creeps", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_creep_magic", "abilities/creeps", LUA_MODIFIER_MOTION_NONE)

function creep_magic:GetIntrinsicModifierName()
	return "modifier_creep_magic_aura"
end



modifier_creep_magic_aura = class({})

function modifier_creep_magic_aura:IsHidden() return true end
function modifier_creep_magic_aura:IsDebuff() return false end
function modifier_creep_magic_aura:IsPurgable() return false end

function modifier_creep_magic_aura:OnCreated()
	self:OnRefresh()
end

function modifier_creep_magic_aura:OnRefresh()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_creep_magic_aura:IsAura() return true end
function modifier_creep_magic_aura:GetModifierAura() return "modifier_creep_magic" end
function modifier_creep_magic_aura:GetAuraRadius() return self.radius end
function modifier_creep_magic_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_creep_magic_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_creep_magic_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE end



modifier_creep_magic = class({})

function modifier_creep_magic:IsHidden() return false end
function modifier_creep_magic:IsDebuff() return false end
function modifier_creep_magic:IsPurgable() return false end

function modifier_creep_magic:OnCreated(keys)
	self:OnRefresh(keys)
end

function modifier_creep_magic:OnRefresh(keys)
	self.health_pct = self:GetAbility():GetSpecialValueFor("health_pct")
end

function modifier_creep_magic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
end

function modifier_creep_magic:GetModifierHealthRegenPercentage()
	return 1.5
end



creep_sapper = class({})

LinkLuaModifier("modifier_creep_sapper", "abilities/creeps", LUA_MODIFIER_MOTION_NONE)

function creep_sapper:GetIntrinsicModifierName()
	return "modifier_creep_sapper"
end



modifier_creep_sapper = class({})

function modifier_creep_sapper:IsHidden() return true end
function modifier_creep_sapper:IsDebuff() return false end
function modifier_creep_sapper:IsPurgable() return false end

function modifier_creep_sapper:OnCreated()
	if IsClient() then return end

	self.target = false

	self:OnRefresh()

	self:StartIntervalThink(0.1)
end

function modifier_creep_sapper:OnRefresh()
	if IsClient() then return end

	self.search_radius = self:GetAbility():GetSpecialValueFor("search_radius")
	self.damage_radius = self:GetAbility():GetSpecialValueFor("damage_radius")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.tower_multiplier = self:GetAbility():GetSpecialValueFor("tower_multiplier")
end

function modifier_creep_sapper:OnIntervalThink()
	local parent = self:GetParent()

	if (not parent) or (not parent:IsAlive()) or parent:IsNull() then return end

	if self.target then
		if self.target then
			ExecuteOrderFromTable({
				unitIndex = parent:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = self.target:GetAbsOrigin(),
				Queue = false
			})
		end

		if (parent:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D() <= (0.8 * self.damage_radius) then

			local explosion_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(explosion_pfx, 0, parent:GetAbsOrigin())
			ParticleManager:SetParticleControl(explosion_pfx, 1, Vector(self.damage_radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(explosion_pfx)

			parent:EmitSound("Sapper.Boom")

			local enemies = FindUnitsInRadius(
				parent:GetTeam(),
				parent:GetAbsOrigin(),
				nil,
				self.damage_radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				FIND_ANY_ORDER,
				false
			)

			for _, enemy in pairs(enemies) do
				if enemy:IsBuilding() then
					ApplyDamage({attacker = parent, victim = enemy, damage = 0.01 * self.tower_multiplier * self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
				else
					ApplyDamage({attacker = parent, victim = enemy, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})
				end
			end

			parent:Kill(nil, parent)

			self:Destroy()
		end
	else
		local enemies = FindUnitsInRadius(
			parent:GetTeam(),
			parent:GetAbsOrigin(),
			nil,
			self.search_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false
		)

		for _, enemy in pairs(enemies) do
			if enemy:IsRealHero() or enemy:IsBuilding() then
				self.target = enemy
			end
		end
	end
end



creep_footman = class({})

LinkLuaModifier("modifier_creep_footman", "abilities/creeps", LUA_MODIFIER_MOTION_NONE)

function creep_footman:GetIntrinsicModifierName()
	return "modifier_creep_footman"
end



modifier_creep_footman = class({})

function modifier_creep_footman:IsHidden() return true end
function modifier_creep_footman:IsDebuff() return false end
function modifier_creep_footman:IsPurgable() return false end



creep_archer = class({})

LinkLuaModifier("modifier_creep_archer", "abilities/creeps", LUA_MODIFIER_MOTION_NONE)

function creep_archer:GetIntrinsicModifierName()
	return "modifier_creep_archer"
end



modifier_creep_archer = class({})

function modifier_creep_archer:IsHidden() return true end
function modifier_creep_archer:IsDebuff() return false end
function modifier_creep_archer:IsPurgable() return false end



creep_reaper = class({})

LinkLuaModifier("modifier_creep_reaper", "abilities/creeps", LUA_MODIFIER_MOTION_NONE)

function creep_reaper:GetIntrinsicModifierName()
	return "modifier_creep_reaper"
end



modifier_creep_reaper = class({})

function modifier_creep_reaper:IsHidden() return true end
function modifier_creep_reaper:IsDebuff() return false end
function modifier_creep_reaper:IsPurgable() return false end



creep_knight = class({})

LinkLuaModifier("modifier_creep_knight", "abilities/creeps", LUA_MODIFIER_MOTION_NONE)

function creep_knight:GetIntrinsicModifierName()
	return "modifier_creep_knight"
end



modifier_creep_knight = class({})

function modifier_creep_knight:IsHidden() return true end
function modifier_creep_knight:IsDebuff() return false end
function modifier_creep_knight:IsPurgable() return false end

function modifier_creep_knight:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
		}
	end
end

function modifier_creep_knight:GetModifierProcAttack_Feedback(keys)
	if keys.target and (keys.target:IsBuilding() or keys.target:HasModifier("modifier_nexus_state")) then
		keys.target:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_disarmed", {duration = 3})
	end
end



creep_golem = class({})

LinkLuaModifier("modifier_creep_golem", "abilities/creeps", LUA_MODIFIER_MOTION_NONE)

function creep_golem:GetIntrinsicModifierName()
	return "modifier_creep_golem"
end



modifier_creep_golem = class({})

function modifier_creep_golem:IsHidden() return true end
function modifier_creep_golem:IsDebuff() return false end
function modifier_creep_golem:IsPurgable() return false end