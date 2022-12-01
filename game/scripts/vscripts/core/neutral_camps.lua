_G.NeutralCamps = NeutralCamps or {}

function NeutralCamps:StartSpawning()
	self.camp_data = {
		[1] = {
			leader = "npc_dota_neutral_kobold_taskmaster",
			minion = "npc_dota_neutral_kobold",
			min_minions = 0,
			max_minions = 0,
			minimap_dummy = "npc_camp_dummy_1",
			scale = 40,
		}
	}

	Timers:CreateTimer(NEUTRAL_CREEP_FIRST_SPAWN_TIME, function()
		for level = 1, 1 do
			for _, camp_location in pairs(Entities:FindAllByName("neutral_spawn_"..level)) do
				NeutralCamp(camp_location:GetAbsOrigin(), self.camp_data[level])
			end
		end
	end)
end



if NeutralCamp == nil then NeutralCamp = class({
	min_leaders = 1,
	max_leaders = 1,
	min_minions = 0,
	max_minions = 0,
	respawn_time = NEUTRAL_CREEP_RESPAWN_TIME
}) end

function NeutralCamp:constructor(location, data)
	self.location = location
	self.leader = data.leader
	self.minion = data.minion
	self.minimap_dummy = data.minimap_dummy
	self.scale = data.scale
	self.min_leaders = data.min_leaders or self.min_leaders
	self.max_leaders = data.max_leaders or self.max_leaders
	self.min_minions = data.min_minions or self.min_minions
	self.max_minions = data.max_minions or self.max_minions
	self.respawn_time = data.respawn_time or self.respawn_time
	self.creeps = {}

	self.dummy = CreateUnitByName(self.minimap_dummy, self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
	self.dummy:AddNewModifier(self.dummy, nil, "modifier_dummy_state", {})

	self:Spawn()
end

function NeutralCamp:Spawn()
	self.creeps = {}

	self.dummy:RemoveModifierByName("modifier_not_on_minimap")

	local leader_count = RandomInt(self.min_leaders, self.max_leaders)
	local minion_count = RandomInt(self.min_minions, self.max_minions)

	for i = 1, leader_count do
		local creep = CreateUnitByName(self.leader, self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)
		creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
		creep:SetForwardVector((Vector(0, 0, 128) - self.location):Normalized())
		creep.camp = self

		table.insert(self.creeps, creep)
	end

	if minion_count > 0 then
		local direction = self.location + RandomVector(110)

		for i = 1, minion_count do
			local minion_loc = RotatePosition(self.location, QAngle( 0, (i - 1) * 360 / minion_count, 0 ), direction)
			local creep = CreateUnitByName(self.minion, minion_loc, true, nil, nil, DOTA_TEAM_NEUTRALS)
			creep:AddNewModifier(creep, nil, "modifier_neutral_size", {scale = self.scale})
			creep.camp = self

			table.insert(self.creeps, creep)
		end
	end
end

function NeutralCamp:OnNeutralCreepDied(killer, killed_unit)
	local team = killer:GetTeam()
	local camp_clear = true

	for _, creep in pairs(self.creeps) do
		if creep and (not creep:IsNull()) and creep:IsAlive() then
			camp_clear = false
		end
	end

	if camp_clear then
		self.dummy:AddNewModifier(self.dummy, nil, "modifier_not_on_minimap", {})

		Timers:CreateTimer(self.respawn_time, function()
			self:Spawn()
		end)
	end
end