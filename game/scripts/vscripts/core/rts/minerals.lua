_G.Minerals = Minerals or {}

MINERAL_PATCH_LEFT = 1
MINERAL_PATCH_RIGHT = 2

function Minerals:Spawn()
	self.mineral_patches = {}

	self.mineral_patches[DOTA_TEAM_GOODGUYS] = {}
	self.mineral_patches[DOTA_TEAM_BADGUYS] = {}

	self.mineral_patches[DOTA_TEAM_GOODGUYS][MINERAL_PATCH_LEFT] = MineralPatch(DOTA_TEAM_GOODGUYS, GameManager:GetMapLocation("good_minerals_left"))
	self.mineral_patches[DOTA_TEAM_GOODGUYS][MINERAL_PATCH_RIGHT] = MineralPatch(DOTA_TEAM_GOODGUYS, GameManager:GetMapLocation("good_minerals_right"))

	self.mineral_patches[DOTA_TEAM_BADGUYS][MINERAL_PATCH_LEFT] = MineralPatch(DOTA_TEAM_BADGUYS, GameManager:GetMapLocation("bad_minerals_left"))
	self.mineral_patches[DOTA_TEAM_BADGUYS][MINERAL_PATCH_RIGHT] = MineralPatch(DOTA_TEAM_BADGUYS, GameManager:GetMapLocation("bad_minerals_right"))
end

function Minerals:GetMineralPatch(team, location)
	if self.mineral_patches[team] and self.mineral_patches[team][location] then
		return self.mineral_patches[team][location]
	end

	return nil
end



if MineralPatch == nil then MineralPatch = class({}) end

function MineralPatch:constructor(team, location)
	self.location = location
	self.team = team

	self.unit = CreateUnitByName("npc_eon_minerals", self.location, true, nil, nil, ENEMY_TEAM[self.team])
	self.unit:AddNewModifier(self.unit, nil, "modifier_minerals_state", {})

	self.unit.is_minerals = true

	AddFOWViewer(team, self.location, 200, 9999, false)
end