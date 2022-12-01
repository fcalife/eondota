_G.NexusManager = NexusManager or {}

function NexusManager:SpawnNexus()
	local good_location = Entities:FindByName(nil, "radiant_nexus"):GetAbsOrigin()
	local bad_location = Entities:FindByName(nil, "dire_nexus"):GetAbsOrigin()

	Nexus(DOTA_TEAM_GOODGUYS, good_location)
	Nexus(DOTA_TEAM_BADGUYS, bad_location)
end



if Nexus == nil then Nexus = class({}) end

function Nexus:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_eon_nexus", self.location, true, nil, nil, self.team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_nexus_state", {})
end