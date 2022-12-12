_G.NexusManager = NexusManager or {}

function NexusManager:SpawnNexus()
	self.nexuses = {}

	local good_location = Entities:FindByName(nil, "radiant_nexus"):GetAbsOrigin()
	local bad_location = Entities:FindByName(nil, "dire_nexus"):GetAbsOrigin()

	if LIVING_BUILDINGS_ENABLED then
		LivingNexus(DOTA_TEAM_GOODGUYS, good_location)
		LivingNexus(DOTA_TEAM_BADGUYS, bad_location)
	else
		self.nexuses[DOTA_TEAM_GOODGUYS] = Nexus(DOTA_TEAM_GOODGUYS, good_location)
		self.nexuses[DOTA_TEAM_BADGUYS] = Nexus(DOTA_TEAM_BADGUYS, bad_location)
	end
end

function NexusManager:GetNexusUnit(team)
	return self.nexuses[team].unit
end


if Nexus == nil then Nexus = class({}) end

function Nexus:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_eon_nexus", self.location, true, nil, nil, self.team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_nexus_state", {})
end



if LivingNexus == nil then LivingNexus = class({}) end

function LivingNexus:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName(team == DOTA_TEAM_GOODGUYS and "npc_eon_living_nexus_good" or "npc_eon_living_nexus_bad", self.location, true, nil, nil, self.team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_living_nexus_state", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_rooted", {duration = LIVING_NEXUS_AWAKENING_TIME})

	Timers:CreateTimer(0.5, function()
		local unit_id = self.unit:entindex()

		ExecuteOrderFromTable({
			unitIndex = unit_id,
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = Vector(0, 0, 128),
			Queue = true
		})
	end)
end