_G.Portals = Portals or {}

PORTAL_COUNT = 2

PORTAL_ENTRY_RADIUS = 180
PORTAL_TELEPORT_DELAY = 2.0
PORTAL_TELEPORT_COOLDOWN = 5

function Portals:Spawn()
	for i = 1, PORTAL_COUNT do
		Portal(
			Entities:FindByName(nil, "portal_"..i.."_a"):GetAbsOrigin(),
			Entities:FindByName(nil, "portal_"..i.."_b"):GetAbsOrigin(),
			Entities:FindByName(nil, "portal_"..i.."_creep_a"):GetAbsOrigin(),
			Entities:FindByName(nil, "portal_"..i.."_creep_b"):GetAbsOrigin()
		)
	end
end

if Portal == nil then Portal = class({}) end

function Portal:constructor(entry, exit, entry_camp, exit_camp)
	self.active_for_team = {}
	self.active_for_team[DOTA_TEAM_GOODGUYS] = false
	self.active_for_team[DOTA_TEAM_BADGUYS] = false

	-- self.portal_pre_pfx = {}
	-- self.portal_pre_pfx[DOTA_TEAM_GOODGUYS] = {}
	-- self.portal_pre_pfx[DOTA_TEAM_GOODGUYS][1] = ParticleManager:CreateParticleForTeam(
	-- 	"particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_portal_buildup.vpcf",
	-- 	PATTACH_CUSTOMORIGIN,
	-- 	nil,
	-- 	DOTA_TEAM_GOODGUYS
	-- )
	-- ParticleManager:SetParticleControl(self.portal_pre_pfx[DOTA_TEAM_GOODGUYS][1], 1, entry)

	-- self.portal_pre_pfx[DOTA_TEAM_GOODGUYS][2] = ParticleManager:CreateParticleForTeam(
	-- 	"particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_portal_buildup.vpcf",
	-- 	PATTACH_CUSTOMORIGIN,
	-- 	nil,
	-- 	DOTA_TEAM_GOODGUYS
	-- )
	-- ParticleManager:SetParticleControl(self.portal_pre_pfx[DOTA_TEAM_GOODGUYS][2], 1, exit)

	-- self.portal_pre_pfx[DOTA_TEAM_BADGUYS] = {}
	-- self.portal_pre_pfx[DOTA_TEAM_BADGUYS][1] = ParticleManager:CreateParticleForTeam(
	-- 	"particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_portal_buildup.vpcf",
	-- 	PATTACH_CUSTOMORIGIN,
	-- 	nil,
	-- 	DOTA_TEAM_BADGUYS
	-- )
	-- ParticleManager:SetParticleControl(self.portal_pre_pfx[DOTA_TEAM_BADGUYS][1], 1, entry)

	-- self.portal_pre_pfx[DOTA_TEAM_BADGUYS][2] = ParticleManager:CreateParticleForTeam(
	-- 	"particles/econ/items/underlord/underlord_2021_immortal/underlord_2021_immortal_portal_buildup.vpcf",
	-- 	PATTACH_CUSTOMORIGIN,
	-- 	nil,
	-- 	DOTA_TEAM_BADGUYS
	-- )
	-- ParticleManager:SetParticleControl(self.portal_pre_pfx[DOTA_TEAM_BADGUYS][2], 1, exit)

	self.entry = entry
	self.exit = exit

	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.entry, 600, 6000, false)
	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.exit, 600, 6000, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.entry, 600, 6000, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.exit, 600, 6000, false)

	self.entry_camp = NeutralCamp(entry_camp, false, false, false, NeutralCamps.camp_data[4])
	self.exit_camp = NeutralCamp(exit_camp, false, false, false, NeutralCamps.camp_data[4])

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

		self.entry_unit = Entities:FindByModelWithin(nil, "models/heroes/abyssal_underlord/abyssal_underlord_portal_model.vmdl", self.entry, 200)
		self.exit_unit = Entities:FindByModelWithin(nil, "models/heroes/abyssal_underlord/abyssal_underlord_portal_model.vmdl", self.exit, 200)
	end

	if self.entry_unit then
		self.entry_unit.active_teams = self.entry_unit.active_teams or {}
		self.entry_unit.active_teams[team] = true
	end

	if self.exit_unit then
		self.exit_unit.active_teams = self.exit_unit.active_teams or {}
		self.exit_unit.active_teams[team] = true
	end
end