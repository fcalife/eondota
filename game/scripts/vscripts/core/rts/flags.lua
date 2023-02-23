_G.Flags = Flags or {}

FLAG_DELIVERY_RADIUS = 160

function Flags:Init()
	self.flags = {}
end

function Flags:SpawnObjectives()
	for _, spawn_point in pairs(Entities:FindAllByName("radiant_flag_delivery")) do
		FlagObjective(spawn_point:GetAbsOrigin(), DOTA_TEAM_GOODGUYS)
	end

	for _, spawn_point in pairs(Entities:FindAllByName("dire_flag_delivery")) do
		FlagObjective(spawn_point:GetAbsOrigin(), DOTA_TEAM_BADGUYS)
	end
end

function Flags:OnInitializeRound()
	for _, flag in pairs(self.flags) do
		flag:Despawn()
	end

	self.flags = {}

	for _, spawn_point in pairs(Entities:FindAllByName("flag_spawn")) do
		table.insert(self.flags, Flag(spawn_point:GetAbsOrigin()))
	end
end



if Flag == nil then Flag = class({
	location = Vector(0, 0, 0)
}) end

function Flag:constructor(location)
	self.location = location or self.location

	self.flag = CreateItem("item_flag", nil, nil)
	self.flag_container = CreateItemOnPositionForLaunch(self.location, self.flag)

	self.flag_container:SetAngles(0, -90, 0)

	self.flag.dummy = CreateUnitByName("npc_flag_dummy", self.location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	self.flag.dummy:AddNewModifier(self.flag.dummy, nil, "modifier_dummy_state", {})

	self.flag_radiant_vision = AddFOWViewer(DOTA_TEAM_GOODGUYS, self.location, 100, 99999, false)
	self.flag_dire_vision = AddFOWViewer(DOTA_TEAM_BADGUYS, self.location, 100, 99999, false)
end

function Flag:Despawn()
	if self.flag_container and (not self.flag_container:IsNull()) then self.flag_container:Destroy() end

	if self.flag and (not self.flag:IsNull()) then
		if self.flag.dummy and (not self.flag.dummy:IsNull()) then self.flag.dummy:Destroy() end

		self.flag:Destroy()
	end

	if self.flag_radiant_vision then RemoveFOWViewer(DOTA_TEAM_GOODGUYS, self.flag_radiant_vision) end
	if self.flag_dire_vision then RemoveFOWViewer(DOTA_TEAM_BADGUYS, self.flag_dire_vision) end

	self = nil
end



if FlagObjective == nil then FlagObjective = class({
	location = Vector(0, 0, 0),
	team = DOTA_TEAM_GOODGUYS,
	radius = FLAG_DELIVERY_RADIUS,
}) end

function FlagObjective:constructor(location, team)
	self.location = location or self.location
	self.team = team or self.team

	self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
		radius = self.radius
	}, {
		trigger_team = team,
		team_filter = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_NONE,
	}, function(units)
		self:OnUnitsInRange(units)
	end, {
	})
end

function FlagObjective:OnUnitsInRange(units)
	for _, unit in pairs(units) do
		local flag = unit:FindItemInInventory("item_flag")

		if flag then
			flag:Destroy()
			RoundManager:OnTeamDeliverFlag(self.team)
			return nil
		end
	end
end

