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

	self.chest = CreateUnitByName("npc_treasure", self.location, true, nil, nil, team)
	self.chest:AddNewModifier(self.chest, nil, "modifier_treasure_state", {})
end