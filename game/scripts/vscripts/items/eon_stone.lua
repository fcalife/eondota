item_eon_stone = class({})

LinkLuaModifier("modifier_item_eon_stone", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eon_stone_visual", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eon_stone_overheat", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eon_stone_cooldown", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eon_stone_proximity", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eon_stone_long_throw", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eon_stone_no_overcharge", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)

local banned_abilities = {}
banned_abilities["witch_doctor_voodoo_switcheroo"] = true

function item_eon_stone:GetIntrinsicModifierName()
	return "modifier_item_eon_stone"
end

function item_eon_stone:DropOnLocation(location)
	if self then
		EmitSoundOnLocationWithCaster(location, "Drop.EonStone", self:GetCaster())
		GameManager:SpawnEonStone(location, self:GetCaster():GetTeam())
		self:Destroy()
	end
end

function item_eon_stone:CastFilterResultLocation(location)
	if IsServer() then
		local caster = self:GetCaster()
		if GridNav:IsNearbyTree(location, 50, true) or (caster and (not GridNav:CanFindPath(caster:GetAbsOrigin(), location)))then
			return UF_FAIL_INVALID_LOCATION
		end
	end
end

function item_eon_stone:OnSpellStart(keys)
	if IsClient() then return end

	self:SetActivated(false)

	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local direction = (target - caster:GetAbsOrigin()):Normalized()
	local distance = math.max(EON_STONE_MIN_THROW_DISTANCE, (target - caster:GetAbsOrigin()):Length2D())
	local speed = distance / EON_STONE_THROW_DURATION
	local projectile = "particles/eon_throw.vpcf"

	if caster:HasModifier("modifier_item_eon_stone_long_throw") then
		distance = 2500
		speed = 1800
		projectile = "particles/eon_throw_long.vpcf"
	end

	local stone_projectile = {
		Ability				= self,
		EffectName			= projectile,
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_mouth")),
		fDistance			= distance,
		fStartRadius		= 150,
		fEndRadius			= 150,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO,
		fExpireTime 		= GameRules:GetGameTime() + distance / speed + 0.01,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x, direction.y, 0) * speed,
		bProvidesVision		= true,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
	}

	ProjectileManager:CreateLinearProjectile(stone_projectile)

	caster:RemoveModifierByName("modifier_item_eon_stone_visual")
	caster:RemoveModifierByName("modifier_item_eon_stone_overheat")

	caster:EmitSound("Throw.EonStone")
end

function item_eon_stone:OnProjectileHit(target, location)
	if not self then return end

	local caster = self:GetCaster() or nil

	if target and target ~= caster and caster:HasModifier("modifier_item_eon_stone_long_throw") then
		if caster:GetTeam() == target:GetTeam() then
			caster:AddNewModifier(caster, nil, "modifier_speed_bonus", {duration = 3.0})
		end

		self:Destroy()
		target:AddItemByName("item_eon_stone")

		return true
	end

	if location and (not target) then
		GridNav:DestroyTreesAroundPoint(location, 200, true)
		self:DropOnLocation(GetGroundPosition(location, nil))

		return true
	end
end



modifier_item_eon_stone = class({})

function modifier_item_eon_stone:IsHidden() return true end
function modifier_item_eon_stone:IsDebuff() return false end
function modifier_item_eon_stone:IsPurgable() return false end
function modifier_item_eon_stone:RemoveOnDeath() return false end
function modifier_item_eon_stone:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
function modifier_item_eon_stone:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_eon_stone:IsAura() return true end
function modifier_item_eon_stone:GetModifierAura() return "modifier_item_eon_stone_proximity" end
function modifier_item_eon_stone:GetAuraRadius() return 2400 end
function modifier_item_eon_stone:GetAuraDuration() return 0.0 end
function modifier_item_eon_stone:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_eon_stone:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_item_eon_stone:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end

function modifier_item_eon_stone:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and (parent:IsIllusion() or parent:IsClone()) then
		self:Destroy()
		return
	end

	parent:EmitSound("Drop.EonStone")

	parent:AddNewModifier(parent, nil, "modifier_item_eon_stone_visual", {})

	local distance = (parent:GetAbsOrigin() - GameManager.eon_stone_spawn_points[1]):Length2D()
	if distance > 200 then
		parent:AddNewModifier(parent, nil, "modifier_speed_bonus", {duration = 5})
	end

	for banned_ability, _ in pairs(banned_abilities) do
		local this_ability = parent:FindAbilityByName(banned_ability)
		if this_ability then this_ability:SetActivated(false) end
	end

	GameManager:OnEonStonePickedUp(parent:GetAbsOrigin())

	self.previous_position = parent:GetAbsOrigin()

	self.minimap_dummy = CreateUnitByName("npc_stone_dummy", self.previous_position, false, nil, nil, parent:GetTeam())
	self.minimap_dummy:AddNewModifier(self.minimap_dummy, nil, "modifier_dummy_state", {})

	self.elapsed_time = 0
	self.damage_taken = 0
	self.distance_moved = 0
	self.overheat_fraction = 0
	self.previous_health = parent:GetHealth()

	self:StartIntervalThink(0.03)
end

function modifier_item_eon_stone:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and (parent:IsIllusion() or parent:IsClone()) then return end

	parent:RemoveModifierByName("modifier_item_eon_stone_visual")
	parent:RemoveModifierByName("modifier_item_eon_stone_overheat")

	parent:AddNewModifier(parent, nil, "modifier_item_eon_stone_cooldown", {duration = 8})

	for banned_ability, _ in pairs(banned_abilities) do
		local this_ability = parent:FindAbilityByName(banned_ability)
		if this_ability then this_ability:SetActivated(true) end
	end

	if self.minimap_dummy and (not self.minimap_dummy:IsNull()) then self.minimap_dummy:Destroy() end
end

function modifier_item_eon_stone:OnIntervalThink()
	local parent = self:GetParent()
	local current_position = parent:GetAbsOrigin()
	local distance = (current_position - self.previous_position):Length2D()

	self.elapsed_time = self.elapsed_time + 0.03

	if self.elapsed_time > 0.4 then
		self.elapsed_time = self.elapsed_time - 0.4
		self:IncrementOverheat(1)
	end

	if parent:GetHealth() < self.previous_health then
		self.damage_taken = self.damage_taken + (self.previous_health - parent:GetHealth())

		local stack_damage = parent:GetMaxHealth() * 0.025

		if self.damage_taken > stack_damage then
			local stack_count = math.floor(self.damage_taken / stack_damage)
			self:IncrementOverheat(stack_count)
			self.damage_taken = self.damage_taken - stack_count * stack_damage
		end
	end

	self.previous_health = parent:GetHealth()

	self.distance_moved = self.distance_moved + distance

	if self.distance_moved >= EON_STONE_DISTANCE_FOR_OVERCHARGE_RAMP then
		local stack_count = math.floor(self.distance_moved / EON_STONE_DISTANCE_FOR_OVERCHARGE_RAMP)
		self:IncrementOverheat(stack_count)
		self.distance_moved = self.distance_moved - EON_STONE_DISTANCE_FOR_OVERCHARGE_RAMP * stack_count
	end

	if self.minimap_dummy and (not self.minimap_dummy:IsNull()) then self.minimap_dummy:SetAbsOrigin(current_position) end

	if (distance > 200) then
		local stone = parent:FindItemInInventory("item_eon_stone")

		if stone and stone:IsActivated() then stone:DropOnLocation(self.previous_position) end
	end

	if self then self.previous_position = parent:GetAbsOrigin() end
end

function modifier_item_eon_stone:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = false,
		[MODIFIER_STATE_INVULNERABLE] = false,
		[MODIFIER_STATE_MAGIC_IMMUNE] = false,
		[MODIFIER_STATE_UNTARGETABLE] = false,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true
	}
end

function modifier_item_eon_stone:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
			MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
			MODIFIER_EVENT_ON_DEATH
		}
	else
		return {
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
			MODIFIER_PROPERTY_INVISIBILITY_LEVEL
		}
	end
end

function modifier_item_eon_stone:GetModifierProvidesFOWVision()
	return 1
end

function modifier_item_eon_stone:GetModifierInvisibilityLevel()
	return 0
end

function modifier_item_eon_stone:OnDeath(keys)
	if (not IsServer()) or keys.unit ~= self:GetParent() then return end

	local stone = keys.unit:FindItemInInventory("item_eon_stone")

	if stone and stone:IsActivated() then stone:DropOnLocation(self:GetParent():GetAbsOrigin()) end
end

function modifier_item_eon_stone:IncrementOverheat(stacks)
	local parent = self:GetParent()

	if (not parent) or parent:IsNull() or (not parent:HasModifier("modifier_item_eon_stone_visual")) then return end

	if parent:HasModifier("modifier_item_eon_stone_no_overcharge") then return end

	local overheat_modifier = parent:FindModifierByName("modifier_item_eon_stone_overheat")

	if (not overheat_modifier) then
		overheat_modifier = parent:AddNewModifier(parent, nil, "modifier_item_eon_stone_overheat", {})
	end

	local offensive_value = parent:GetPositionOffensiveValue()

	if offensive_value < 0 then
		stacks = stacks * (1 - offensive_value * OFFENSIVE_VALUE_MAX_OVERCHARGE_BOOST)
	end

	if math.floor(stacks + self.overheat_fraction) > math.floor(stacks) then
		stacks = stacks + self.overheat_fraction
		self.overheat_fraction = 0
	end

	self.overheat_fraction = self.overheat_fraction + stacks - math.floor(stacks)

	overheat_modifier:SetStackCount(math.min(100, overheat_modifier:GetStackCount() + stacks))

	if overheat_modifier:GetStackCount() >= 100 then
		overheat_modifier:SetStackCount(50)
		self:Bust()
	end
end

function modifier_item_eon_stone:Bust()
	local parent = self:GetParent()

	if (not parent) or parent:IsNull() then return end

	local stone = self:GetAbility()
	local throw_position = parent:GetAbsOrigin() + RandomVector(RandomInt(800, 1200))

	parent:SetCursorPosition(throw_position)

	if stone and (not stone:IsNull()) then stone:OnSpellStart() end

	parent:AddNewModifier(parent, nil, "modifier_stunned", {duration = 2.5})

	ApplyDamage({
		victim = parent,
		attacker = parent,
		damage = parent:GetMaxHealth() * 0.15,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
	})
end



modifier_item_eon_stone_visual = class({})

function modifier_item_eon_stone_visual:IsHidden() return true end
function modifier_item_eon_stone_visual:IsDebuff() return false end
function modifier_item_eon_stone_visual:IsPurgable() return false end

function modifier_item_eon_stone_visual:GetEffectName()
	return "particles/eon_carrier.vpcf"
end

function modifier_item_eon_stone_visual:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_eon_stone_visual:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	local runner = parent:FindAbilityByName("ability_ball_runner")
	if runner then runner:SetActivated(true) end

	local thrower = parent:FindAbilityByName("ability_ball_thrower")
	if thrower then thrower:SetActivated(true) end

	local blocker = parent:FindAbilityByName("ability_ball_charger")
	if blocker then blocker:SetActivated(true) end
end

function modifier_item_eon_stone_visual:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	local runner = parent:FindAbilityByName("ability_ball_runner")
	if runner then runner:SetActivated(false) end

	local thrower = parent:FindAbilityByName("ability_ball_thrower")
	if thrower then thrower:SetActivated(false) end

	local blocker = parent:FindAbilityByName("ability_ball_charger")
	if blocker then blocker:SetActivated(false) end
end



modifier_item_eon_stone_proximity = class({})

function modifier_item_eon_stone_proximity:IsHidden() return true end
function modifier_item_eon_stone_proximity:IsDebuff() return false end
function modifier_item_eon_stone_proximity:IsPurgable() return false end

function modifier_item_eon_stone_proximity:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	local blocker = parent:FindAbilityByName("ability_ball_blocker")
	if blocker then blocker:SetActivated(true) end
end

function modifier_item_eon_stone_proximity:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	local blocker = parent:FindAbilityByName("ability_ball_blocker")
	if blocker then blocker:SetActivated(false) end
end



modifier_item_eon_stone_overheat = class({})

function modifier_item_eon_stone_overheat:IsHidden() return false end
function modifier_item_eon_stone_overheat:IsDebuff() return false end
function modifier_item_eon_stone_overheat:IsPurgable() return false end

function modifier_item_eon_stone_overheat:GetTexture()
	return "lina_light_strike_array"
end

function modifier_item_eon_stone_overheat:GetEffectName()
	return "particles/overheat_buff.vpcf"
end

function modifier_item_eon_stone_overheat:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_eon_stone_overheat:OnCreated()
	if IsClient() then return end

	self.current_stacks = 0

	local parent = self:GetParent()

	if parent and (not parent:IsNull()) then
		parent:EmitSound("overheat_loop.01")
	end
end

function modifier_item_eon_stone_overheat:OnStackCountChanged()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and (not parent:IsNull()) then
		local stack_count = self:GetStackCount()

		if self.current_stacks < 80 and stack_count >= 80 then
			parent:StopSound("overheat_loop.01")
			parent:StopSound("overheat_loop.02")
			parent:StopSound("overheat_loop.03")
			parent:StopSound("overheat_loop.04")

			parent:EmitSound("overheat_loop.04")
		elseif self.current_stacks < 60 and stack_count >= 60 then
			parent:StopSound("overheat_loop.01")
			parent:StopSound("overheat_loop.02")
			parent:StopSound("overheat_loop.03")
			parent:StopSound("overheat_loop.04")

			parent:EmitSound("overheat_loop.03")
		elseif self.current_stacks < 40 and stack_count >= 40 then
			parent:StopSound("overheat_loop.01")
			parent:StopSound("overheat_loop.02")
			parent:StopSound("overheat_loop.03")
			parent:StopSound("overheat_loop.04")

			parent:EmitSound("overheat_loop.02")
		end

		local player = parent:GetPlayerOwner()
		if player then
			if stack_count >= 80 then
				local screen_pfx = ParticleManager:CreateParticleForPlayer("particles/overheat_screen_04.vpcf", PATTACH_EYES_FOLLOW, parent, player)
				ParticleManager:ReleaseParticleIndex(screen_pfx)
			elseif stack_count >= 60 then
				local screen_pfx = ParticleManager:CreateParticleForPlayer("particles/overheat_screen_03.vpcf", PATTACH_EYES_FOLLOW, parent, player)
				ParticleManager:ReleaseParticleIndex(screen_pfx)
			elseif stack_count >= 40 then
				local screen_pfx = ParticleManager:CreateParticleForPlayer("particles/overheat_screen_02.vpcf", PATTACH_EYES_FOLLOW, parent, player)
				ParticleManager:ReleaseParticleIndex(screen_pfx)
			else
				local screen_pfx = ParticleManager:CreateParticleForPlayer("particles/overheat_screen_01.vpcf", PATTACH_EYES_FOLLOW, parent, player)
				ParticleManager:ReleaseParticleIndex(screen_pfx)
			end
		end

		self.current_stacks = self:GetStackCount()
	end
end

function modifier_item_eon_stone_overheat:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	if parent and (not parent:IsNull()) then
		parent:StopSound("overheat_loop.01")
		parent:StopSound("overheat_loop.02")
		parent:StopSound("overheat_loop.03")
		parent:StopSound("overheat_loop.04")
	end
end

function modifier_item_eon_stone_overheat:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_eon_stone_overheat:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount()
end

function modifier_item_eon_stone_overheat:GetModifierSpellAmplify_Percentage()
	return 0.5 * self:GetStackCount()
end



modifier_item_eon_stone_cooldown = class({})

function modifier_item_eon_stone_cooldown:IsHidden() return false end
function modifier_item_eon_stone_cooldown:IsDebuff() return false end
function modifier_item_eon_stone_cooldown:IsPurgable() return false end

function modifier_item_eon_stone_cooldown:GetTexture()
	return "crystal_maiden_brilliance_aura"
end



modifier_item_eon_stone_long_throw = class({})

function modifier_item_eon_stone_long_throw:IsHidden() return true end
function modifier_item_eon_stone_long_throw:IsDebuff() return false end
function modifier_item_eon_stone_long_throw:IsPurgable() return false end



modifier_item_eon_stone_no_overcharge = class({})

function modifier_item_eon_stone_no_overcharge:IsHidden() return true end
function modifier_item_eon_stone_no_overcharge:IsDebuff() return false end
function modifier_item_eon_stone_no_overcharge:IsPurgable() return false end