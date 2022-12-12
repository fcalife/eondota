_G.NeutralCamps = NeutralCamps or {}

function NeutralCamps:StartSpawning()
	self.camp_data = {
		[1] = {
			leader = "npc_fire_spirit",
			upgraded_leader = "npc_fire_golem",
			min_minions = 0,
			max_minions = 0,
			minimap_dummy = "npc_camp_dummy_1",
			scale = 0,
		},
	}

	self.fire_camps = {}

	for level = 1, 1 do
		for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
			table.insert(self.fire_camps, FireCamp(camp_location:GetAbsOrigin(), self.camp_data[level]))
		end
	end
end

function NeutralCamps:SpawnFireCamp()
	local camp_list = table.shuffle(self.fire_camps)
	local need_camp = true

	while #camp_list > 0 and need_camp do
		local camp = table.remove(camp_list)

		if camp and (not camp.busy) then
			camp:SpawnWarning()
			need_camp = false
		end
	end
end



if FireCamp == nil then FireCamp = class({
}) end

function FireCamp:constructor(location, data)
	self.location = location
	self.leader = data.leader
	self.upgraded_leader = data.upgraded_leader
	self.minimap_dummy = data.minimap_dummy
	self.scale = data.scale

	self.creeps = {}

	self.busy = false

	--self:Spawn()
end

function FireCamp:Spawn()
	self.creeps = {}

	local is_upgraded = GameClock:GetActualGameTime() >= FIRE_SPIRIT_UPGRADE_TIME

	local creep_name = (is_upgraded and self.upgraded_leader) or self.leader

	local creep = CreateUnitByName(creep_name, self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
	creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
	creep:SetForwardVector((Vector(0, 0, 128) - self.location):Normalized())
	creep.camp = self

	table.insert(self.creeps, creep)

	self.busy = true
end

function FireCamp:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	for _, creep in pairs(self.creeps) do
		if creep and (not creep:IsNull()) and creep:IsAlive() then
			camp_clear = false
		end
	end

	if (not camp_clear) then return end

	self.busy = false

	local is_upgraded = killed_unit:GetUnitName() == "npc_fire_golem"

	if is_upgraded then
		LaneCreeps:SpawnNeutralForTeam(team, "npc_fire_golem_lane")
		GlobalMessages:NotifyTeamKilledGolem(team)
	end

	EmitSoundOnLocationWithCaster(killed_unit:GetAbsOrigin(), "Drop.EonStone", killed_unit)

	for i = 1, ((is_upgraded and 3) or 2) do
		local essence_drop = CreateItem("item_fire_essence", nil, nil)
		local drop = CreateItemOnPositionForLaunch(killed_unit:GetAbsOrigin(), essence_drop)
		drop:SetModelScale(1.8)
		essence_drop:LaunchLoot(false, RandomInt(175, 300), 0.4, killed_unit:GetAbsOrigin() + RandomVector(120))
	end

	GoldRewards:GiveGoldToPlayersInTeam(team, (is_upgraded and FIRE_SPIRIT_UPGRADED_GOLD) or FIRE_SPIRIT_GOLD_BOUNTY, 0)
	GoldRewards:LevelupPlayersInTeam(team)
end

function FireCamp:SpawnWarning()
	EmitGlobalSound("stone.shortwarning")

	local minimap_dummy = CreateUnitByName("npc_stone_dummy", self.location, false, nil, nil, DOTA_TEAM_NEUTRALS)
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_dummy_state", {})
	minimap_dummy:AddNewModifier(minimap_dummy, nil, "modifier_not_on_minimap", {})

	for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
		MinimapEvent(team, minimap_dummy, self.location.x, self.location.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, FIRE_SPIRIT_PRESPAWN_WARNING)
	end

	local warning_pfx = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(warning_pfx, 0, self.location)
	ParticleManager:SetParticleControl(warning_pfx, 2, Vector(1, 0.6, 0))

	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.location, 400, FIRE_SPIRIT_PRESPAWN_WARNING, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.location, 400, FIRE_SPIRIT_PRESPAWN_WARNING, false)

	EmitGlobalSound("stone.countdown")

	Timers:CreateTimer(FIRE_SPIRIT_PRESPAWN_WARNING, function()
		ParticleManager:DestroyParticle(warning_pfx, false)
		ParticleManager:ReleaseParticleIndex(warning_pfx)

		StopGlobalSound("stone.countdown")
		EmitGlobalSound("stone.spawn")

		minimap_dummy:Destroy()

		self:Spawn()
	end)
end