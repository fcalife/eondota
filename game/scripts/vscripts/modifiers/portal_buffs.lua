modifier_portal_teleporting = class({})

function modifier_portal_teleporting:IsHidden() return true end
function modifier_portal_teleporting:IsDebuff() return false end
function modifier_portal_teleporting:IsPurgable() return false end

function modifier_portal_teleporting:OnCreated()
	if IsClient() then return end

	local parent = self:GetParent()
	if not parent then return end

	parent:EmitSound("Hero.Teleport.Loop")

	self.teleport_pfx = ParticleManager:CreateParticle("particles/econ/events/fall_2021/teleport_end_fall_2021_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.teleport_pfx, 0, parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.teleport_pfx, 1, parent:GetAbsOrigin())

	self:StartIntervalThink(self:GetDuration() - 0.6)
end

function modifier_portal_teleporting:OnIntervalThink()
	if IsClient() then return end

	local parent = self:GetParent()
	if not parent then return end

	parent:EmitSound("Hero.Teleport.PopOut")
end

function modifier_portal_teleporting:OnDestroy()
	if IsClient() then return end

	if self.teleport_pfx then
		ParticleManager:DestroyParticle(self.teleport_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.teleport_pfx)
	end

	local parent = self:GetParent()
	if not parent then return end

	parent:StopSound("Hero.Teleport.Loop")

	parent:AddNewModifier(parent, nil, "modifier_portal_cooldown", {duration = PORTAL_TELEPORT_COOLDOWN})
end

function modifier_portal_teleporting:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
end



modifier_portal_cooldown = class({})

function modifier_portal_cooldown:IsHidden() return true end
function modifier_portal_cooldown:IsDebuff() return false end
function modifier_portal_cooldown:IsPurgable() return false end