item_knight_blink = class({})

LinkLuaModifier("modifier_item_knight_blink_buff", "items/knight_blink", LUA_MODIFIER_MOTION_NONE)

function item_knight_blink:OnSpellStart(keys)
	if IsClient() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local origin = caster:GetAbsOrigin()
	local direction = (target - origin):Normalized()
	local target_distance = (target - origin):Length2D()

	local max_range = self:GetSpecialValueFor("max_range")
	local duration = self:GetSpecialValueFor("duration")

	local destination = origin + math.max(200, math.min(target_distance, max_range)) * direction

	ProjectileManager:ProjectileDodge(caster)

	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")

	local origin_pfx = ParticleManager:CreateParticle("particles/econ/events/fall_2021/blink_dagger_fall_2021_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(origin_pfx, 0, origin)
	ParticleManager:ReleaseParticleIndex(origin_pfx)

	FindClearSpaceForUnit(caster, destination, true)
	ResolveNPCPositions(destination, 256)

	local target_pfx = ParticleManager:CreateParticle("particles/creatures/aghanim/aghanim_blink_arrival.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(target_pfx, 0, destination)
	ParticleManager:ReleaseParticleIndex(target_pfx)

	caster:AddNewModifier(caster, self, "modifier_item_knight_blink_buff", {duration = duration})

	local stone = caster:FindModifierByName("modifier_item_eon_stone")
	if stone then
		stone.previous_position = destination
		stone.distance_moved = stone.distance_moved + (destination - origin):Length2D()
	end

	self:SpendCharge()
	self:Destroy()
end



modifier_item_knight_blink_buff = class({})

function modifier_item_knight_blink_buff:IsHidden() return false end
function modifier_item_knight_blink_buff:IsDebuff() return false end
function modifier_item_knight_blink_buff:IsPurgable() return false end

function modifier_item_knight_blink_buff:OnCreated(keys)
	local ability = self:GetAbility()

	self.status_resist = ability:GetSpecialValueFor("status_resist")
end

function modifier_item_knight_blink_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
	}
end

function modifier_item_knight_blink_buff:GetModifierStatusResistanceStacking()
	return self.status_resist
end