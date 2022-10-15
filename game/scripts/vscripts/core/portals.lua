_G.Portals = Portals or {}

PORTAL_COUNT = (IS_EXPERIMENTAL_MAP and 3) or 2

PORTAL_ENTRY_RADIUS = 180
PORTAL_TELEPORT_DELAY = 2.0
PORTAL_TELEPORT_COOLDOWN = 5

PORTAL_SPAWN_DELAY = {}
PORTAL_SPAWN_DELAY[1] = 0
PORTAL_SPAWN_DELAY[2] = 180
PORTAL_SPAWN_DELAY[3] = 180

PORTAL_COLOR = {}
PORTAL_COLOR[DOTA_TEAM_GOODGUYS] = Vector(8, 69, 229)
PORTAL_COLOR[DOTA_TEAM_BADGUYS] = Vector(255, 0, 0)

function Portals:Spawn()
	for i = 1, PORTAL_COUNT do
		Timers:CreateTimer(PORTAL_SPAWN_DELAY[i], function()
			Portal(
				Entities:FindByName(nil, "portal_"..i.."_a"):GetAbsOrigin(),
				Entities:FindByName(nil, "portal_"..i.."_b"):GetAbsOrigin(),
				Entities:FindByName(nil, "portal_"..i.."_creep_a"):GetAbsOrigin(),
				Entities:FindByName(nil, "portal_"..i.."_creep_b"):GetAbsOrigin()
			)
		end)
	end
end

function Portals:OnUnitUsedPortal(unit)
	local stone = unit:FindModifierByName("modifier_item_eon_stone")
	if stone then
		stone.previous_position = unit:GetAbsOrigin()
	end

	local player = unit:GetPlayerOwner()
	if player then
		PlayerResource:SetCameraTarget(player:GetPlayerID(), unit)
		Timers:CreateTimer(0.01, function() PlayerResource:SetCameraTarget(player:GetPlayerID(), nil) end)
	end

	if not (unit:HasModifier("modifier_stealth_prevention") or unit:HasModifier("modifier_major_stealth_buff")) then
		unit:AddNewModifier(unit, nil, "modifier_minor_stealth_buff", {duration = MINOR_STEALTH_BUFF_DURATION})
		unit:AddNewModifier(unit, nil, "modifier_stealth_prevention", {duration = 180})
	end
end



if Portal == nil then Portal = class({}) end

function Portal:constructor(entry, exit, entry_camp, exit_camp)
	self.active_for_team = {}
	self.active_for_team[DOTA_TEAM_GOODGUYS] = false
	self.active_for_team[DOTA_TEAM_BADGUYS] = false

	self.entry = entry
	self.exit = exit

	self.entry_camp_position = entry_camp
	self.exit_camp_position = exit_camp

	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.entry, 400, 6000, false)
	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.exit, 400, 6000, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.entry, 400, 6000, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.exit, 400, 6000, false)

	self.entry_camp = NeutralCamp(entry_camp, NeutralCamps.camp_data[4])
	self.exit_camp = NeutralCamp(exit_camp, NeutralCamps.camp_data[4])

	self.entry_camp.portal = self
	self.exit_camp.portal = self
	self.entry_camp.portal_team = DOTA_TEAM_GOODGUYS
	self.exit_camp.portal_team = DOTA_TEAM_BADGUYS

	self.caster = CreateUnitByName("npc_portal_dummy", self.entry, false, nil, nil, DOTA_TEAM_NEUTRALS)
	self.caster:AddNewModifier(self.caster, nil, "modifier_portal_caster_state", {})
	self.portal_ability = self.caster:FindAbilityByName("abyssal_underlord_dark_portal")
	if self.portal_ability then self.portal_ability:SetLevel(1) end
end

function Portal:ActivateForTeam(team)
	if self.caster and (not self.caster:IsNull()) and self.portal_ability and (not self.portal_ability:IsNull()) and (not (self.entry_unit or self.exit_unit)) then
		self.caster:SetCursorPosition(self.exit)
		self.portal_ability:OnSpellStart()

		self.caster:Destroy()

		self.entry_unit = Entities:FindByModelWithin(nil, "models/heroes/abyssal_underlord/abyssal_underlord_portal_model.vmdl", self.entry, 300)
		self.exit_unit = Entities:FindByModelWithin(nil, "models/heroes/abyssal_underlord/abyssal_underlord_portal_model.vmdl", self.exit, 300)

		if self.entry_unit then
			self.entry_unit.active_teams = self.entry_unit.active_teams or {}
			self.entry_unit.active_teams[team] = true

			self.entry_team_pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(self.entry_team_pfx, 0, self.entry_unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.entry_team_pfx, 1, Vector(350, 0, 0))
			ParticleManager:SetParticleControl(self.entry_team_pfx, 2, self.entry_unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.entry_team_pfx, 60, PORTAL_COLOR[team])
			ParticleManager:SetParticleControl(self.entry_team_pfx, 61, Vector(1, 0, 0))
		end

		if self.exit_unit then
			self.exit_unit.active_teams = self.exit_unit.active_teams or {}
			self.exit_unit.active_teams[team] = true

			self.exit_team_pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(self.exit_team_pfx, 0, self.exit_unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.exit_team_pfx, 1, Vector(350, 0, 0))
			ParticleManager:SetParticleControl(self.exit_team_pfx, 2, self.exit_unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.exit_team_pfx, 60, PORTAL_COLOR[team])
			ParticleManager:SetParticleControl(self.exit_team_pfx, 61, Vector(1, 0, 0))
		end

		Timers:CreateTimer(PORTAL_DURATION, function() self:Reset() end)

		if self.entry_camp and self.entry_camp.creeps then
			for _, creep in pairs(self.entry_camp.creeps) do
				creep:Kill(nil, creep)
			end
		end

		if self.exit_camp and self.exit_camp.creeps then
			for _, creep in pairs(self.exit_camp.creeps) do
				creep:Kill(nil, creep)
			end
		end
	end
end

function Portal:Reset()
	self.active_for_team[DOTA_TEAM_GOODGUYS] = false
	self.active_for_team[DOTA_TEAM_BADGUYS] = false

	if self.entry_team_pfx then
		ParticleManager:DestroyParticle(self.entry_team_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.entry_team_pfx)
	end

	if self.exit_team_pfx then
		ParticleManager:DestroyParticle(self.exit_team_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.exit_team_pfx)
	end

	self.entry_camp = NeutralCamp(self.entry_camp_position, NeutralCamps.camp_data[4])
	self.exit_camp = NeutralCamp(self.exit_camp_position, NeutralCamps.camp_data[4])

	self.entry_camp.portal = self
	self.exit_camp.portal = self
	self.entry_camp.portal_team = DOTA_TEAM_GOODGUYS
	self.exit_camp.portal_team = DOTA_TEAM_BADGUYS

	self.caster = CreateUnitByName("npc_portal_dummy", self.entry, false, nil, nil, DOTA_TEAM_NEUTRALS)
	self.caster:AddNewModifier(self.caster, nil, "modifier_portal_caster_state", {})
	self.portal_ability = self.caster:FindAbilityByName("abyssal_underlord_dark_portal")

	if self.portal_ability then self.portal_ability:SetLevel(1) end

	self.entry_unit = nil
	self.exit_unit = nil
end