_G.NexusManager = NexusManager or {}

function NexusManager:Spawn()
	local good_location = Entities:FindByName(nil, "good_nexus"):GetAbsOrigin()
	local bad_location = Entities:FindByName(nil, "bad_nexus"):GetAbsOrigin()

	self.good_nexus = Nexus(DOTA_TEAM_GOODGUYS, good_location)
	self.bad_nexus = Nexus(DOTA_TEAM_BADGUYS, bad_location)
end

function NexusManager:GetNexus(team)
	if team == DOTA_TEAM_GOODGUYS then
		return self.good_nexus
	elseif team == DOTA_TEAM_BADGUYS then
		return self.bad_nexus
	end

	return nil
end



if Nexus == nil then Nexus = class({}) end

function Nexus:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_eon_nexus", self.location, true, nil, nil, self.team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_nexus_state", {})

	self.unit.is_nexus = true
end