modifier_score_taunt = class({})

function modifier_score_taunt:IsHidden() return true end
function modifier_score_taunt:IsDebuff() return false end
function modifier_score_taunt:IsPurgable() return false end

function modifier_score_taunt:OnCreated()
	if IsClient() then return end

	local parent = self:GetParent()
	if not parent then return end

	parent:StartGesture(ACT_DOTA_VICTORY)
	parent:EmitSound("Hero.Teleport.Loop")

	self.teleport_pfx = ParticleManager:CreateParticle("particles/econ/events/fall_2021/teleport_end_fall_2021_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.teleport_pfx, 0, parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.teleport_pfx, 1, parent:GetAbsOrigin())

	self:StartIntervalThink(self:GetDuration() - 0.1)
end

function modifier_score_taunt:OnIntervalThink()
	if IsClient() then return end

	local parent = self:GetParent()
	if not parent then return end

	parent:EmitSound("Hero.Teleport.PopOut")
end

function modifier_score_taunt:OnDestroy()
	if IsClient() then return end

	if self.teleport_pfx then
		ParticleManager:DestroyParticle(self.teleport_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.teleport_pfx)
	end

	local parent = self:GetParent()
	if not parent then return end

	parent:StopSound("Hero.Teleport.Loop")

	FindClearSpaceForUnit(parent, TEAM_FOUNTAINS[parent:GetTeam()], true)
	ResolveNPCPositions(TEAM_FOUNTAINS[parent:GetTeam()], 200)

	parent:EmitSound("Hero.Teleport.PopIn")
	parent:FadeGesture(ACT_DOTA_VICTORY)

	local player = parent:GetPlayerOwner()
	if player then
		PlayerResource:SetCameraTarget(player:GetPlayerID(), parent)
		Timers:CreateTimer(0.01, function() PlayerResource:SetCameraTarget(player:GetPlayerID(), nil) end)
	end
end

function modifier_score_taunt:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR_FOR_ENEMIES] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true
		}
	end
end