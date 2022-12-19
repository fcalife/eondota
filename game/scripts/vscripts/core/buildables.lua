_G.Buildables = Buildables or {}

CustomGameEventManager:RegisterListener("building_selected", function(_, event)
	Buildables:OnPlayerRequestedBuild(event)
end)

function Buildables:Init()
	self.building_slots = {}
	self.current_slot = {}

	for _, building_slot in pairs(Entities:FindAllByName("building_spot")) do
		table.insert(self.building_slots, BuildingSlot(building_slot:GetAbsOrigin()))
	end
end

function Buildables:GetBuildingSlots()
	return self.building_slots or nil
end

function Buildables:OnPlayerRequestedBuild(event)
	if event.building and event.PlayerID and self.current_slot[event.PlayerID] then
		self.current_slot[event.PlayerID]:OnPlayerRequestedBuild(event.building, event.PlayerID)
	end
end



if BuildingSlot == nil then BuildingSlot = class({}) end

function BuildingSlot:constructor(location)
	self.location = location
	self.team = DOTA_TEAM_NEUTRALS

	self:SpawnBuilding(self.team, "rts_building_placeholder")
end

function BuildingSlot:SpawnBuilding(team, building_name)
	self.team = team or self.team
	self.building_name = building_name or self.building_name

	if self.unit and (not self.unit:IsNull()) and self.unit:IsAlive() then self.unit:Destroy() end

	self.unit = CreateUnitByName(self.building_name, self.location, false, nil, nil, self.team)
	self.unit.building_slot = self

	if self.team == DOTA_TEAM_NEUTRALS then
		self.unit:AddNewModifier(self.unit, nil, "modifier_neutral_building_state", {})
	else
		self.unit:AddNewModifier(self.unit, nil, "modifier_building_state", {})
	end

	if self.team == DOTA_TEAM_GOODGUYS then
		self.unit:SetRenderColor(150, 150, 255)
	elseif self.team == DOTA_TEAM_BADGUYS then
		self.unit:SetRenderColor(255, 150, 150)
	else
		self.unit:SetRenderColor(110, 110, 110)
	end
end

function BuildingSlot:OnBuildingDestroyed()
	self:SpawnBuilding(DOTA_TEAM_NEUTRALS, "rts_building_placeholder")
end

function BuildingSlot:ShowBuildingMenu(unit)
	local player_id = unit:GetPlayerID()
	local player = PlayerResource:GetPlayer(player_id)

	Buildables.current_slot[player_id] = self

	if player then CustomGameEventManager:Send_ServerToPlayer(player, "open_building_menu", {}) end
end

function BuildingSlot:OnPlayerRequestedBuild(building_name, player_id)
	if self.unit and (not self.unit:IsNull()) and self.unit:IsAlive() and self.unit:GetTeam() ~= DOTA_TEAM_NEUTRALS then return end

	if ScoreManager:TrySpendEssence(player_id, 2) then
		self:SpawnBuilding(PlayerResource:GetTeam(player_id), "rts_building_"..building_name)
	end
end