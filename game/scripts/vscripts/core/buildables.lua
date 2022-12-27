_G.Buildables = Buildables or {}

CustomGameEventManager:RegisterListener("building_selected", function(_, event)
	Buildables:OnPlayerRequestedBuild(event)
end)

function Buildables:Init()
	self.building_slots = {}

	self.building_slots[1] = {}
	self.building_slots[2] = {}
	self.building_slots[3] = {}

	table.insert(self.building_slots[1], BuildingSlot(Vector(-3008, 1472, 32)))
	table.insert(self.building_slots[1], BuildingSlot(Vector(1472, -3008, 32)))

	table.insert(self.building_slots[2], BuildingSlot(Vector(2240, -2240, 32)))
	table.insert(self.building_slots[2], BuildingSlot(Vector(-2240, 2240, 32)))

	table.insert(self.building_slots[3], BuildingSlot(Vector(-1472, 3008, 32)))
	table.insert(self.building_slots[3], BuildingSlot(Vector(3008, -1472, 32)))
end

function Buildables:GetBuildingSlots()
	return self.building_slots or nil
end

function Buildables:BuildForTeam(team)
	local count = 2

	if team == DOTA_TEAM_GOODGUYS then
		if count > 0 and self.building_slots[1][1]:IsAvailable() then
			self.building_slots[1][1]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[1][2]:IsAvailable() then
			self.building_slots[1][2]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[2][1]:IsAvailable() then
			self.building_slots[2][1]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[2][2]:IsAvailable() then
			self.building_slots[2][2]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[3][1]:IsAvailable() then
			self.building_slots[3][1]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[3][2]:IsAvailable() then
			self.building_slots[3][2]:SpawnRandomBuilding(team)
			count = count - 1
		end
	elseif team == DOTA_TEAM_BADGUYS then
		if count > 0 and self.building_slots[3][1]:IsAvailable() then
			self.building_slots[3][1]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[3][2]:IsAvailable() then
			self.building_slots[3][2]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[2][1]:IsAvailable() then
			self.building_slots[2][1]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[2][2]:IsAvailable() then
			self.building_slots[2][2]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[1][1]:IsAvailable() then
			self.building_slots[1][1]:SpawnRandomBuilding(team)
			count = count - 1
		end

		if count > 0 and self.building_slots[1][2]:IsAvailable() then
			self.building_slots[1][2]:SpawnRandomBuilding(team)
			count = count - 1
		end
	end

	if count > 0 then
		for i = 1, count do
			self:UpgradeRandomTowerForTeam(team)
		end
	end
end

function Buildables:UpgradeRandomTowerForTeam(team)
	local slots = table.
end



if BuildingSlot == nil then BuildingSlot = class({}) end

function BuildingSlot:constructor(location)
	self.location = location
	self.team = DOTA_TEAM_NEUTRALS
end

function BuildingSlot:IsAvailable()
	if self.unit and (not self.unit:IsNull()) and self.unit:IsAlive() then return false end

	return true
end

function BuildingSlot:SpawnRandomBuilding(team)
	local names = {}

	table.insert(names, "rts_building_regen")
	table.insert(names, "rts_building_gold")
	table.insert(names, "rts_building_damage")
	table.insert(names, "rts_building_defense")

	self:SpawnBuilding(team, names[RandomInt(1, 4)])
end

function BuildingSlot:SpawnBuilding(team, building_name)
	self.team = team or self.team
	self.building_name = building_name or self.building_name

	self.unit = CreateUnitByName(self.building_name, self.location, false, nil, nil, self.team)
	self.unit.building_slot = self

	self.unit:RemoveModifierByName("modifier_invulnerable")
	self.unit:AddNewModifier(self.unit, nil, "modifier_building_state", {})

	if self.team == DOTA_TEAM_GOODGUYS then
		self.unit:SetRenderColor(150, 150, 255)
	elseif self.team == DOTA_TEAM_BADGUYS then
		self.unit:SetRenderColor(255, 150, 150)
	else
		self.unit:SetRenderColor(110, 110, 110)
	end
end