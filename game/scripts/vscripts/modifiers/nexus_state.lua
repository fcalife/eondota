modifier_nexus_state = class({})

function modifier_nexus_state:IsHidden() return true end
function modifier_nexus_state:IsDebuff() return false end
function modifier_nexus_state:IsPurgable() return false end

function modifier_nexus_state:IsAura() return true end
function modifier_nexus_state:GetModifierAura() return "modifier_nexus_state_debuff" end
function modifier_nexus_state:GetAuraRadius() return 900 end
function modifier_nexus_state:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_nexus_state:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_nexus_state:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end

function modifier_nexus_state:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_nexus_state:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_DEATH,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
	else
		return {
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
	end
end

function modifier_nexus_state:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

function modifier_nexus_state:OnAttackLanded(keys)
	if keys.target and keys.target == self:GetParent() then
		local team = keys.target:GetTeam()

		if keys.attacker and keys.attacker:GetTeam() ~= team then
			local health = math.ceil(100 * keys.target:GetHealth() / keys.target:GetMaxHealth())
			ScoreManager:OnNexusHealth(team, health)
		end
	end
end

function modifier_nexus_state:OnDeath(keys)
	if keys.unit and keys.unit == self:GetParent() then
		GameManager:EndGameWithWinner(ENEMY_TEAM[keys.unit:GetTeam()])
	end
end



modifier_nexus_state_debuff = class({})

function modifier_nexus_state_debuff:IsHidden() return false end
function modifier_nexus_state_debuff:IsDebuff() return true end
function modifier_nexus_state_debuff:IsPurgable() return false end

function modifier_nexus_state_debuff:GetTexture()
	return "item_radiance"
end

function modifier_nexus_state_debuff:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(1.0)
	end
end

function modifier_nexus_state_debuff:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()

	if parent and caster and parent:IsAlive() and (not parent:IsNull()) then
		ApplyDamage({attacker = caster, victim = parent, damage = 30 + 0.07 * parent:GetHealth(), damage_type = DAMAGE_TYPE_PURE})
	end
end