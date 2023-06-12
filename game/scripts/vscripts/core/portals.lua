_G.Portals = Portals or {}

PORTAL_ENTRY_RADIUS = 180
PORTAL_TELEPORT_DELAY = 1.25
PORTAL_COLOR = Vector(8, 69, 229)

function Portals:OnUnitUsedPortal(unit)
	local player = unit:GetPlayerOwner()

	if player and (not CAMERA_LOCK) then
		PlayerResource:SetCameraTarget(player:GetPlayerID(), unit)
		Timers:CreateTimer(0.01, function() PlayerResource:SetCameraTarget(player:GetPlayerID(), nil) end)
	end

	Hazards:DestroyPortal()
	Hazards:RollNextPortalSpawn()
end



if PortalPair == nil then PortalPair = class({}) end

function PortalPair:constructor(entry, exit)
	self.entry = entry
	self.exit = exit

	self.caster = CreateUnitByName("npc_portal_dummy", self.entry, false, nil, nil, DOTA_TEAM_NEUTRALS)
	self.caster:AddNewModifier(self.caster, nil, "modifier_portal_caster_state", {})
	self.portal_ability = self.caster:FindAbilityByName("abyssal_underlord_dark_portal")
	if self.portal_ability then self.portal_ability:SetLevel(1) end

	self:Activate()
end

function PortalPair:Activate()
	if self.caster and (not self.caster:IsNull()) and self.portal_ability and (not self.portal_ability:IsNull()) and (not (self.entry_unit or self.exit_unit)) then
		self.caster:SetCursorPosition(self.exit)
		self.portal_ability:OnSpellStart()

		self.caster:Destroy()

		Timers:CreateTimer(1, function()
			self.entry_unit = Entities:FindByModelWithin(nil, "models/heroes/abyssal_underlord/abyssal_underlord_portal_model.vmdl", self.entry, 300)
			self.exit_unit = Entities:FindByModelWithin(nil, "models/heroes/abyssal_underlord/abyssal_underlord_portal_model.vmdl", self.exit, 300)

			if self.entry_unit then
				self.entry_team_pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(self.entry_team_pfx, 0, self.entry_unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(self.entry_team_pfx, 1, Vector(350, 0, 0))
				ParticleManager:SetParticleControl(self.entry_team_pfx, 2, self.entry_unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(self.entry_team_pfx, 60, PORTAL_COLOR)
				ParticleManager:SetParticleControl(self.entry_team_pfx, 61, Vector(1, 0, 0))
			end

			if self.exit_unit then
				self.exit_team_pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(self.exit_team_pfx, 0, self.exit_unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(self.exit_team_pfx, 1, Vector(350, 0, 0))
				ParticleManager:SetParticleControl(self.exit_team_pfx, 2, self.exit_unit:GetAbsOrigin())
				ParticleManager:SetParticleControl(self.exit_team_pfx, 60, PORTAL_COLOR)
				ParticleManager:SetParticleControl(self.exit_team_pfx, 61, Vector(1, 0, 0))
			end
		end)
	end
end

function PortalPair:Destroy()
	if self.entry_team_pfx then
		ParticleManager:DestroyParticle(self.entry_team_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.entry_team_pfx)
	end

	if self.exit_team_pfx then
		ParticleManager:DestroyParticle(self.exit_team_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.exit_team_pfx)
	end

	local portal_units = Entities:FindAllByModel("models/heroes/abyssal_underlord/abyssal_underlord_portal_model.vmdl")
	for _, unit in pairs(portal_units) do unit:Destroy() end
end