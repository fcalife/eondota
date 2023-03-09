basic_cleave = class({})

LinkLuaModifier("modifier_crown", "abilities/basic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crown_visual", "abilities/basic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tagger_visual_death", "abilities/basic", LUA_MODIFIER_MOTION_NONE)



modifier_crown = class({})

function modifier_crown:IsHidden() return true end
function modifier_crown:IsDebuff() return false end
function modifier_crown:IsPurgable() return false end

function modifier_crown:GetEffectName()
	return "particles/tag/tag_crown.vpcf"
end

function modifier_crown:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_crown:OnCreated(keys)
	if IsClient() then return end

	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_crown_visual", {})

	local bonker = self:GetParent():FindAbilityByName("basic_cleave")

	if bonker then bonker:SetHidden(true) end
end

function modifier_crown:OnDestroy()
	if IsClient() then return end

	self:GetParent():RemoveModifierByName("modifier_crown_visual")

	local bonker = self:GetParent():FindAbilityByName("basic_cleave")

	if bonker then bonker:SetHidden(false) end
end



modifier_crown_visual = class({})

function modifier_crown_visual:IsHidden() return true end
function modifier_crown_visual:IsDebuff() return false end
function modifier_crown_visual:IsPurgable() return false end

function modifier_crown_visual:GetEffectName()
	return "particles/tag/tag_energy.vpcf"
end

function modifier_crown_visual:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



modifier_tagger_visual_death = class({})

function modifier_tagger_visual_death:IsHidden() return true end
function modifier_tagger_visual_death:IsDebuff() return false end
function modifier_tagger_visual_death:IsPurgable() return false end
function modifier_tagger_visual_death:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_tagger_visual_death:CheckState()
	return {
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true
	}
end



function basic_cleave:OnSpellStart()
	local caster = self:GetCaster()

	local target = caster:GetAbsOrigin() + 100 * caster:GetForwardVector()

	self:FireOnPosition(target)
end

function basic_cleave:FireOnPosition(target)
	local caster = self:GetCaster()

	local angle = self:GetSpecialValueFor("angle")
	local length = self:GetSpecialValueFor("length")

	local caster_loc = caster:GetAbsOrigin()

	target.z = 0
	caster_loc.z = 0

	local direction = (target - caster_loc):Normalized()
	local min_dot_product = math.cos(2 * angle * math.pi / 360)

	caster:EmitSound("KnockbackArena.HeavyThrow")

	local strike_pfx = ParticleManager:CreateParticle("particles/dodgeball/heavy_strike.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(strike_pfx, 0, caster_loc)
	ParticleManager:SetParticleControlOrientation(strike_pfx, 0, caster:GetForwardVector(), caster:GetRightVector(), caster:GetUpVector())
	ParticleManager:ReleaseParticleIndex(strike_pfx)

	if caster:HasModifier("modifier_crown") then return end

	local enemies = FindUnitsInRadius(
		caster:GetTeam(),
		caster_loc,
		nil,
		length,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_CLOSEST,
		false
	)

	for _, enemy in pairs(enemies) do
		local enemy_loc = enemy:GetAbsOrigin()
		enemy_loc.z = 0

		local enemy_direction = (enemy_loc - caster_loc):Normalized()
		local dot_product = DotProduct(direction, enemy_direction)

		if enemy:HasModifier("modifier_crown") and dot_product >= min_dot_product then
			enemy:EmitSound("KnockbackArena.HeavyHit")
			enemy:AddNewModifier(caster, self, "modifier_stunned", {duration = 2.0})

			enemy:RemoveModifierByName("modifier_crown")
			caster:AddNewModifier(caster, self, "modifier_crown", {})

			return
		end
	end
end