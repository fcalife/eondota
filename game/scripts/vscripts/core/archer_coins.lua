_G.ArcherCoins = ArcherCoins or {}

SPAWN_BOX_WIDTH = 2816
SPAWN_BOX_HEIGHT = 2100

SPAWN_BOX_VERT_START = 275

ArcherCoins.coins = {}

function ArcherCoins:Init()
	self.spawn_box = {}

	self.spawn_box[DOTA_TEAM_GOODGUYS] = {}
	self.spawn_box[DOTA_TEAM_BADGUYS] = {}

	self.spawn_box[DOTA_TEAM_GOODGUYS].v_dir = Vector(1, 1, 0)
	self.spawn_box[DOTA_TEAM_GOODGUYS].h_dir = Vector(-1, 1, 0)

	self.spawn_box[DOTA_TEAM_BADGUYS].v_dir = Vector(-1, -1, 0)
	self.spawn_box[DOTA_TEAM_BADGUYS].h_dir = Vector(1, -1, 0)

	self.spawn_box[DOTA_TEAM_GOODGUYS].start = Vector(1408, -1408, 0) + SPAWN_BOX_VERT_START * self.spawn_box[DOTA_TEAM_GOODGUYS].v_dir
	self.spawn_box[DOTA_TEAM_BADGUYS].start = Vector(-1408, 1408, 0) + SPAWN_BOX_VERT_START * self.spawn_box[DOTA_TEAM_BADGUYS].v_dir
end

function ArcherCoins:GetRandomSpawnPositionForTeam(team)
	local position = self.spawn_box[team].start + RandomInt(0, SPAWN_BOX_HEIGHT) * self.spawn_box[team].v_dir + RandomInt(0, SPAWN_BOX_WIDTH) * self.spawn_box[team].h_dir

	return GetGroundPosition(position, nil)
end

function ArcherCoins:Spawn()
	local location = self:GetRandomSpawnPositionForTeam(DOTA_TEAM_GOODGUYS)
	local mirror_location = GetGroundPosition(Vector(-location.x, -location.y, 0), nil)
	local center = GetGroundPosition(Vector(0, 0, 0), nil)

	while (not GridNav:CanFindPath(center, location)) or (not GridNav:CanFindPath(center, mirror_location)) do
		location = self:GetRandomSpawnPositionForTeam(DOTA_TEAM_GOODGUYS)
		mirror_location = GetGroundPosition(Vector(-location.x, -location.y, 0), nil)
	end

	ArcherCoin(location, DOTA_TEAM_GOODGUYS)
	ArcherCoin(mirror_location, DOTA_TEAM_BADGUYS)
end



if ArcherCoin == nil then ArcherCoin = class({
	location = Vector(0, 0, 0)
}) end

function ArcherCoin:constructor(location, team)
	self.location = location or self.location
	self.team = team or DOTA_TEAM_GOODGUYS
	self.item_name = ((self.team == DOTA_TEAM_GOODGUYS) and "item_blue_essence") or "item_red_essence"

	self.fow_viewers = {}

	self.fow_viewers[DOTA_TEAM_GOODGUYS] = AddFOWViewer(DOTA_TEAM_GOODGUYS, self.location, 240, 30, false)
	self.fow_viewers[DOTA_TEAM_BADGUYS] = AddFOWViewer(DOTA_TEAM_BADGUYS, self.location, 240, 30, false)

	self.dummy = CreateUnitByName("npc_camp_dummy_4", self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
	self.dummy:AddNewModifier(self.dummy, nil, "modifier_dummy_state", {})

	self:SpawnWarning()
end

function ArcherCoin:OnUnitsInRange(units)
	if units[1] and (not units[1]:IsNull()) then
		if self.coin then self.coin:Destroy() end
		if self.coin_container then self.coin_container:Destroy() end

		if self.fow_viewers[DOTA_TEAM_GOODGUYS] then RemoveFOWViewer(self.fow_viewers[DOTA_TEAM_GOODGUYS], DOTA_TEAM_GOODGUYS) end
		if self.fow_viewers[DOTA_TEAM_BADGUYS] then RemoveFOWViewer(self.fow_viewers[DOTA_TEAM_BADGUYS], DOTA_TEAM_BADGUYS) end

		if self.dummy then self.dummy:Destroy() end
		if self.trigger then self.trigger:Stop() end

		units[1]:EmitSound("Drop.EonStone")
		units[1]:AddItemByName("item_fire_essence")
	end
end

function ArcherCoin:Spawn()
	self.coin = CreateItem(self.item_name, nil, nil)
	self.coin_container = CreateItemOnPositionForLaunch(self.location, self.coin)

	self.coin_container:SetModelScale(0.8)

	self.trigger = MapTrigger(self.location, TRIGGER_TYPE_CIRCLE, {
		radius = 200
	}, {
		trigger_team = self.team,
		team_filter = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		unit_filter = DOTA_UNIT_TARGET_HERO,
		flag_filter = DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
	}, function(units)
		self:OnUnitsInRange(units)
	end, {
		tick_when_empty = false,
	})
end

function ArcherCoin:SpawnWarning()
	EmitGlobalSound("stone.shortwarning")

	local minimap_dummy = CreateUnitByName("npc_stone_dummy", self.location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_dummy_state", {})
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_not_on_minimap", {})

	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		MinimapEvent(team, minimap_dummy, self.location.x, self.location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, COIN_WARNING_TIME)
	end

	local warning_pfx = ParticleManager:CreateParticle("particles/econ/events/ti5/teleport_start_lvl2_ti5.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(warning_pfx, 0, self.location)
	ParticleManager:SetParticleControl(warning_pfx, 1, self.location)

	EmitGlobalSound("stone.countdown")

	Timers:CreateTimer(COIN_WARNING_TIME, function()
		ParticleManager:DestroyParticle(warning_pfx, false)
		ParticleManager:ReleaseParticleIndex(warning_pfx)

		StopGlobalSound("stone.countdown")
		EmitGlobalSound("stone.spawn")

		minimap_dummy:Destroy()

		self:Spawn()
	end)
end