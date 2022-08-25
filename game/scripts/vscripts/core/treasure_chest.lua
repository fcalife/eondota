_G.TreasureChests = TreasureChests or {}

function TreasureChests:Spawn()
	local good_location = Entities:FindByName(nil, "treasure_spawn_good"):GetAbsOrigin()
	local bad_location = Entities:FindByName(nil, "treasure_spawn_bad"):GetAbsOrigin()

	TreasureChest(DOTA_TEAM_GOODGUYS, good_location)
	TreasureChest(DOTA_TEAM_BADGUYS, bad_location)
end



if TreasureChest == nil then TreasureChest = class({}) end

function TreasureChest:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_eon_nexus", self.location, true, nil, nil, self.team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_nexus_state", {})

	ScoreManager.nexus[team] = self.unit
end