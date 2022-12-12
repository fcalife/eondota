_G.RuneSpawners = RuneSpawners or {}

RUNE_TYPE_RED = 1
RUNE_TYPE_GREEN = 2

RUNE_NAME = {}

RUNE_NAME[RUNE_TYPE_RED] = "item_red_rune"
RUNE_NAME[RUNE_TYPE_GREEN] = "item_green_rune"

function RuneSpawners:Init()
	self.rune_spawners = {}

	for _, spawn_point in pairs(Entities:FindAllByName("red_rune_spawn")) do
		table.insert(self.rune_spawners, RuneSpawner(spawn_point:GetAbsOrigin(), RUNE_TYPE_RED))
	end

	for _, spawn_point in pairs(Entities:FindAllByName("green_rune_spawn")) do
		table.insert(self.rune_spawners, RuneSpawner(spawn_point:GetAbsOrigin(), RUNE_TYPE_GREEN))
	end

	if CHARGE_TOWERS_ENABLED then
		self.essence_spawners = {}

		for _, spawn_point in pairs(Entities:FindAllByName("essence_spawn")) do
			table.insert(self.essence_spawners, EssenceSpawner(spawn_point:GetAbsOrigin()))
		end
	end
end

function RuneSpawners:OnInitializeRound()
	for _, spawner in pairs(self.rune_spawners) do
		spawner:Spawn()
	end
end

function RuneSpawners:SpawnEssence()
	local spawner_list = table.shuffle(self.essence_spawners)
	local need_spawner = true

	while #spawner_list > 0 and need_spawner do
		local spawner = table.remove(spawner_list)

		if spawner and (not spawner:IsFull()) then
			spawner:SpawnWarning()
			need_spawner = false
		end
	end
end



if RuneSpawner == nil then RuneSpawner = class({
	location = Vector(0, 0, 0),
	rune_type = RUNE_TYPE_RED
}) end

function RuneSpawner:constructor(location, rune_type)
	self.location = location or self.location
	self.rune_type = rune_type or self.rune_type
end

function RuneSpawner:Spawn()
	if self.rune and (not self.rune:IsNull()) and self.rune_container and (not self.rune_container:IsNull()) then return end

	self.rune = CreateItem(RUNE_NAME[self.rune_type], nil, nil)
	self.rune_container = CreateItemOnPositionForLaunch(self.location, self.rune)
end



if EssenceSpawner == nil then EssenceSpawner = class({
	location = Vector(0, 0, 0)
}) end

function EssenceSpawner:constructor(location)
	self.location = location or self.location

	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.location, 240, 9999, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.location, 240, 9999, false)
end

function EssenceSpawner:Spawn()
	if self:IsFull() then return end

	self.essence = CreateItem("item_charge_pickup", nil, nil)
	self.essence_container = CreateItemOnPositionForLaunch(self.location, self.essence)
end

function EssenceSpawner:IsFull()
	if self.essence and (not self.essence:IsNull()) and self.essence_container and (not self.essence_container:IsNull()) then return true end

	return false
end

function EssenceSpawner:SpawnWarning()
	EmitGlobalSound("stone.shortwarning")

	GlobalMessages:Send("An Eon Sphere is spawning in "..CHARGE_TOWER_PRESPAWN_WARNING.." seconds!")

	local minimap_dummy = CreateUnitByName("npc_stone_dummy", self.location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_dummy_state", {})
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_not_on_minimap", {})

	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		MinimapEvent(team, minimap_dummy, self.location.x, self.location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, CHARGE_TOWER_PRESPAWN_WARNING)
	end

	local warning_pfx = ParticleManager:CreateParticle("particles/econ/events/fall_2021/teleport_end_fall_2021_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(warning_pfx, 0, self.location)
	ParticleManager:SetParticleControl(warning_pfx, 1, self.location)

	EmitGlobalSound("stone.countdown")

	Timers:CreateTimer(CHARGE_TOWER_PRESPAWN_WARNING - 3, function() GlobalMessages:Send("3...") EmitGlobalSound("stone.three") end)
	Timers:CreateTimer(CHARGE_TOWER_PRESPAWN_WARNING - 2, function() GlobalMessages:Send("2...") EmitGlobalSound("stone.two") end)
	Timers:CreateTimer(CHARGE_TOWER_PRESPAWN_WARNING - 1, function() GlobalMessages:Send("1...") EmitGlobalSound("stone.one") end)

	Timers:CreateTimer(CHARGE_TOWER_PRESPAWN_WARNING, function()
		ParticleManager:DestroyParticle(warning_pfx, false)
		ParticleManager:ReleaseParticleIndex(warning_pfx)

		StopGlobalSound("stone.countdown")
		EmitGlobalSound("stone.spawn")

		minimap_dummy:Destroy()

		self:Spawn()
	end)
end