item_eon_stone = class({})

LinkLuaModifier("modifier_item_eon_stone", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_eon_stone_visual", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)

local banned_abilities = {}
banned_abilities["witch_doctor_voodoo_switcheroo"] = true

function item_eon_stone:GetIntrinsicModifierName()
	return "modifier_item_eon_stone"
end

function item_eon_stone:DropOnLocation(location)
	if self then
		EmitSoundOnLocationWithCaster(location, "Drop.EonStone", self:GetCaster())
		GameManager:SpawnEonStone(location)
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
	local distance = math.max(200, (target - caster:GetAbsOrigin()):Length2D())
	local speed = distance / EON_STONE_THROW_DURATION

	local stone_projectile = {
		Ability				= self,
		EffectName			= "particles/eon_throw.vpcf",
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_mouth")),
		fDistance			= distance,
		fStartRadius		= 0,
		fEndRadius			= 0,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO,
		fExpireTime 		= GameRules:GetGameTime() + 1.01,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x, direction.y, 0) * speed,
		bProvidesVision		= true,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
	}

	ProjectileManager:CreateLinearProjectile(stone_projectile)

	caster:RemoveModifierByName("modifier_item_eon_stone_visual")

	caster:EmitSound("Throw.EonStone")
end

function item_eon_stone:OnProjectileHit(target, location)
	if not self then return end

	local caster = self:GetCaster() or nil

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
function modifier_item_eon_stone:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_eon_stone:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	parent:EmitSound("Drop.EonStone")

	parent:AddNewModifier(parent, nil, "modifier_item_eon_stone_visual", {})

	for banned_ability, _ in pairs(banned_abilities) do
		local this_ability = parent:FindAbilityByName(banned_ability)
		if this_ability then this_ability:SetActivated(false) end
	end

	GameManager:OnEonStonePickedUp(parent:GetAbsOrigin())

	self.previous_position = parent:GetAbsOrigin()

	self.minimap_dummy = CreateUnitByName("npc_stone_dummy", self.previous_position, false, nil, nil, parent:GetTeam())
	self.minimap_dummy:AddNewModifier(self.minimap_dummy, nil, "modifier_dummy_state", {})

	self:StartIntervalThink(0.03)
end

function modifier_item_eon_stone:OnDestroy()
	if IsClient() then return end

	local parent = self:GetParent()

	parent:RemoveModifierByName("modifier_item_eon_stone_visual")

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

	if self.minimap_dummy and (not self.minimap_dummy:IsNull()) then self.minimap_dummy:SetAbsOrigin(current_position) end

	if (distance > 200) then
		local stone = parent:FindItemInInventory("item_eon_stone")

		if stone and stone:IsActivated() then stone:DropOnLocation(self.previous_position) end
	end

	if self then self.previous_position = parent:GetAbsOrigin() end
end

function modifier_item_eon_stone:CheckState()
	return { [MODIFIER_STATE_NOT_ON_MINIMAP] = true }
end

function modifier_item_eon_stone:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
			MODIFIER_EVENT_ON_DEATH
		}
	else
		return {
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
		}
	end
end

function modifier_item_eon_stone:GetModifierProvidesFOWVision()
	return 1
end

function modifier_item_eon_stone:OnDeath(keys)
	if (not IsServer()) or keys.unit ~= self:GetParent() then return end

	local stone = keys.unit:FindItemInInventory("item_eon_stone")

	if stone and stone:IsActivated() then stone:DropOnLocation(self:GetParent():GetAbsOrigin()) end
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