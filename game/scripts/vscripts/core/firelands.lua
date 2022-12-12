_G.Firelord = Firelord or {}

function Firelord:Init()
	local location = Entities:FindByName(nil, "guardian_spawn"):GetAbsOrigin()

	self.location = location

	self.unit = CreateUnitByName("npc_eon_living_nexus_bad", self.location, true, nil, nil, DOTA_TEAM_NEUTRALS)

	self.unit:AddNewModifier(self.unit, nil, "modifier_firelord_state", {})
	self.unit:AddNewModifier(self.unit, nil, "modifier_nexus_attacker", {})

	AddFOWViewer(DOTA_TEAM_GOODGUYS, self.location, 450, 9999, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, self.location, 450, 9999, false)
end

function Firelord:Bombard(team)
	self.unit:AddNewModifier(self.unit, nil, "modifier_firelord_busy", {duration = 6.0})

	local ability = self.unit:FindAbilityByName("snapfire_mortimer_kisses")

	local unit_id = self.unit:entindex()
	local ability_id = ability:entindex()

	local target = NexusManager:GetNexusUnit(team):GetAbsOrigin()

	ExecuteOrderFromTable({
		unitIndex = unit_id,
		AbilityIndex = ability_id,
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = target,
		Queue = true
	})
end