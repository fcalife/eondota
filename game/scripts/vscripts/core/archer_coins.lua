_G.ArcherCoins = ArcherCoins or {}

ArcherCoins.coins = {}

function ArcherCoins:Spawn()
	local location = Vector(0, 0, 128) + RandomVector(RandomInt(500, 3600))
	local mirror_location = (-1) * Vector(location.x, location.y, -128)

	while (not (GridNav:CanFindPath(Vector(0, 0, 128), location) and GridNav:CanFindPath(Vector(0, 0, 128), mirror_location))) do
		location = Vector(0, 0, 128) + RandomVector(RandomInt(500, 3600))
		mirror_location = (-1) * Vector(location.x, location.y, -128)
	end

	ArcherCoin(location)
	ArcherCoin(mirror_location)
end



if ArcherCoin == nil then ArcherCoin = class({
	location = Vector(0, 0, 0)
}) end

function ArcherCoin:constructor(location)
	self.location = location or self.location

	self.fow_viewers = {}

	self.fow_viewers[DOTA_TEAM_GOODGUYS] = AddFOWViewer(DOTA_TEAM_GOODGUYS, self.location, 240, 30, false)
	self.fow_viewers[DOTA_TEAM_BADGUYS] = AddFOWViewer(DOTA_TEAM_BADGUYS, self.location, 240, 30, false)

	self.dummy = CreateUnitByName("npc_camp_dummy_4", self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
	self.dummy:AddNewModifier(self.dummy, nil, "modifier_dummy_state", {})

	self:SpawnWarning()
end

function ArcherCoin:Spawn()
	self.coin = CreateItem("item_fire_essence", nil, nil)
	self.coin_container = CreateItemOnPositionForLaunch(self.location, self.coin)

	Timers:CreateTimer(0.5, function()
		if self.coin and self.coin_container and (not (self.coin:IsNull() or self.coin_container:IsNull())) then
			return 0.5
		else
			if self.fow_viewers[DOTA_TEAM_GOODGUYS] then RemoveFOWViewer(self.fow_viewers[DOTA_TEAM_GOODGUYS], DOTA_TEAM_GOODGUYS) end
			if self.fow_viewers[DOTA_TEAM_BADGUYS] then RemoveFOWViewer(self.fow_viewers[DOTA_TEAM_BADGUYS], DOTA_TEAM_BADGUYS) end

			self.dummy:Destroy()
		end
	end)
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