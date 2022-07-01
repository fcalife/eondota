item_eon_stone = class({})

LinkLuaModifier("modifier_item_eon_stone", "items/eon_stone", LUA_MODIFIER_MOTION_NONE)



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

function item_eon_stone:OnSpellStart(keys)
	if IsClient() then return end

	self:SetActivated(false)

	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local direction = (target - caster:GetAbsOrigin()):Normalized()
	local duration = EON_STONE_THROW_DISTANCE / EON_STONE_THROW_SPEED + 0.01

	local stone_projectile = {
		Ability				= self,
		EffectName			= "particles/eon_throw.vpcf",
		vSpawnOrigin		= caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_mouth")),
		fDistance			= EON_STONE_THROW_DISTANCE,
		fStartRadius		= EON_STONE_CATCH_RADIUS,
		fEndRadius			= EON_STONE_CATCH_RADIUS,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO,
		fExpireTime 		= GameRules:GetGameTime() + duration,
		bDeleteOnHit		= true,
		vVelocity			= Vector(direction.x, direction.y, 0) * EON_STONE_THROW_SPEED,
		bProvidesVision		= true,
		iVisionRadius 		= 350,
		iVisionTeamNumber 	= caster:GetTeam(),
	}

	ProjectileManager:CreateLinearProjectile(stone_projectile)

	caster:EmitSound("Throw.EonStone")
end

function item_eon_stone:OnProjectileHit(target, location)
	if not self then return end

	local caster = self:GetCaster() or nil

	if target and caster ~= target then
		local target_stone = target:FindItemInInventory("item_eon_stone")
		if not target_stone then
			target:AddItemByName("item_eon_stone")
			self:Destroy()
			return true
		end
	end

	if location and (not target) then
		GridNav:DestroyTreesAroundPoint(location, 300, true)
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

function modifier_item_eon_stone:GetEffectName()
	return "particles/eon_carrier.vpcf"
end

function modifier_item_eon_stone:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_item_eon_stone:OnCreated(keys)
	if IsClient() then return end

	local parent = self:GetParent()

	parent:EmitSound("Drop.EonStone")

	GameManager:OnEonStonePickedUp(parent:GetAbsOrigin())

	if self:GetAbility() then
		self:GetAbility():StartCooldown(EON_STONE_CATCH_COOLDOWN)
	end
end

function modifier_item_eon_stone:DeclareFunctions()
	if IsServer() then
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
			MODIFIER_EVENT_ON_DEATH
		}
	else
		return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
		}
	end
end

function modifier_item_eon_stone:GetModifierMoveSpeedBonus_Percentage()
	return 0
end

function modifier_item_eon_stone:GetModifierProvidesFOWVision()
	return 1
end

function modifier_item_eon_stone:OnDeath(keys)
	if (not IsServer()) or keys.unit ~= self:GetParent() then return end

	local stone = keys.unit:FindItemInInventory("item_eon_stone")

	if stone then stone:DropOnLocation(self:GetParent():GetAbsOrigin()) end
end